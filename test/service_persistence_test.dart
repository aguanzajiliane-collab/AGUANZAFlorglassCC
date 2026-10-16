import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:florglassaluminum/main.dart';
import 'package:florglassaluminum/service_storage.dart';

class ControlledStorage extends ServiceStorage {
  String? snapshot;
  bool failWrite = false;
  bool failRead = false;
  Completer<String?>? pendingRead;

  @override
  Future<String?> read() async {
    if (failRead) throw StateError('Storage unavailable');
    if (pendingRead != null) return pendingRead!.future;
    return snapshot;
  }

  @override
  Future<void> write(String value) async {
    if (failWrite) throw StateError('Storage unavailable');
    snapshot = value;
  }
}

http.Client api() =>
    MockClient((_) async => http.Response('{"products":[]}', 200));

Future<void> launch(WidgetTester tester, {ServiceStorage? storage}) async {
  await tester.pumpWidget(const SizedBox());
  await tester
      .pumpWidget(FlorglassAluminumApp(client: api(), serviceStorage: storage));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Services').last);
  await tester.pumpAndSettle();
}

Future<void> add(WidgetTester tester) async {
  await tester.tap(find.text('Add service'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).at(0), 'Persistent repair');
  await tester.enterText(find.byType(TextField).at(1), 'Steel');
  await tester.enterText(find.byType(TextField).at(2), 'Saved description');
  await tester.enterText(find.byType(TextField).at(3), '725.50');
  await tester.tap(find.widgetWithText(FilledButton, 'Add service'));
  await tester.pumpAndSettle();
}

Future<void> reveal(WidgetTester tester, String name) async {
  await tester.scrollUntilVisible(find.text(name), 180,
      scrollable: find.byType(Scrollable).last);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
      'Shared preferences: add, reload, delete, reload without duplicates',
      (tester) async {
    await launch(tester);
    await add(tester);
    final prefs = await SharedPreferences.getInstance();
    final stored = jsonDecode(prefs.getString(ServiceStorage.key)!) as List;
    expect(stored, hasLength(5));
    expect(stored.last, containsPair('name', 'Persistent repair'));
    expect(stored.last, containsPair('price', 725.5));
    expect(stored.last, containsPair('category', 'Steel'));
    expect(stored.last, containsPair('description', 'Saved description'));

    await launch(tester);
    await reveal(tester, 'Persistent repair');
    expect(find.text('Persistent repair'), findsOneWidget);
    expect(find.text('From ₱725.50'), findsOneWidget);
    final tile = find.ancestor(
        of: find.text('Persistent repair'), matching: find.byType(ServiceTile));
    await tester.tap(
        find.descendant(of: tile, matching: find.byTooltip('Delete service')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(jsonDecode(prefs.getString(ServiceStorage.key)!), hasLength(5));
    await tester.tap(
        find.descendant(of: tile, matching: find.byTooltip('Delete service')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await launch(tester);
    expect(find.text('Persistent repair'), findsNothing);
    final restored = jsonDecode(prefs.getString(ServiceStorage.key)!) as List;
    expect(restored, hasLength(4));
    expect(restored.map((s) => s['name']).toSet(), hasLength(4));
    expect(restored.any((s) => s['name'] == 'Persistent repair'), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Deleted initial services and an empty list stay deleted',
      (tester) async {
    await launch(tester);
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byTooltip('Delete service').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      if (i == 0) {
        await launch(tester);
        expect(find.text('Aluminum Windows'), findsNothing);
      }
    }
    await launch(tester);
    expect(find.text('No services yet'), findsOneWidget);
    expect(
        (await SharedPreferences.getInstance()).getString(ServiceStorage.key),
        '[]');
  });

  testWidgets('Loading prevents editing until restoration finishes',
      (tester) async {
    final storage = ControlledStorage()..pendingRead = Completer<String?>();
    await tester.pumpWidget(
        FlorglassAluminumApp(client: api(), serviceStorage: storage));
    await tester.tap(find.text('Services').last);
    await tester.pump();
    expect(find.text('Loading saved services…'), findsOneWidget);
    expect(
        tester
            .widget<FloatingActionButton>(find.byType(FloatingActionButton))
            .onPressed,
        isNull);
    storage.pendingRead!.complete(null);
    await tester.pumpAndSettle();
    expect(find.text('Our services'), findsOneWidget);
  });

  testWidgets('Corrupt saved data is preserved and can be retried',
      (tester) async {
    final storage = ControlledStorage()..snapshot = 'not JSON';
    await launch(tester, storage: storage);
    expect(find.text('Unable to load services'), findsOneWidget);
    expect(storage.snapshot, 'not JSON');
    storage.snapshot = '[]';
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('No services yet'), findsOneWidget);
  });

  testWidgets('Storage read failure offers retry without overwriting data',
      (tester) async {
    final storage = ControlledStorage()..failRead = true;
    await launch(tester, storage: storage);
    expect(find.text('Unable to load services'), findsOneWidget);
    storage.failRead = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Our services'), findsOneWidget);
    expect(storage.snapshot, isNull);
  });

  testWidgets('Failed add or delete does not report success or change services',
      (tester) async {
    final storage = ControlledStorage()..failWrite = true;
    await launch(tester, storage: storage);
    await add(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Service added successfully.'), findsNothing);
    expect(find.textContaining('Could not save services'), findsOneWidget);
    expect(storage.snapshot, isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete service').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Aluminum Windows'), findsOneWidget);
    expect(find.text('Service deleted.'), findsNothing);
    storage.failWrite = false;
    await add(tester);
    await launch(tester, storage: storage);
    await reveal(tester, 'Persistent repair');
    expect(find.text('Persistent repair'), findsOneWidget);
  });
}
