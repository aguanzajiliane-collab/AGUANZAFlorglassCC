import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:florglassaluminum/main.dart';

http.Client responseClient(Object body, {int status = 200}) =>
    MockClient((request) async {
      expect(request.url.host, 'dummyjson.com');
      expect(request.url.path, '/c/0050-66a2-4330-bd48');
      return http.Response(jsonEncode(body), status);
    });

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('Fetches API products and shows correct currency',
      (tester) async {
    await tester.pumpWidget(FlorglassAluminumApp(
        client: responseClient({
      'products': [
        {
          'title': 'Steel Square Tube',
          'description': 'Fetched JSON',
          'price': 12.5,
          'thumbnail': ''
        }
      ]
    })));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(NavigationDestination).at(2));
    await tester.pumpAndSettle();
    expect(find.text('Steel Square Tube'), findsOneWidget);
    expect(find.text('₱12.50'), findsOneWidget);
    expect(find.textContaining('USD'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Loading, failure, offline fallback and retry', (tester) async {
    final pending = Completer<http.Response>();
    var calls = 0;
    final client = MockClient((_) {
      calls++;
      return calls == 1
          ? pending.future
          : Future.value(http.Response('{"products":[]}', 200));
    });
    await tester.pumpWidget(FlorglassAluminumApp(client: client));
    await tester.tap(find.byType(NavigationDestination).at(2));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(http.Response('Unavailable', 503));
    await tester.pumpAndSettle();
    expect(find.text('Unable to load items'), findsOneWidget);
    await tester.tap(find.text('Open offline demo catalog'));
    await tester.pumpAndSettle();
    expect(find.text('Aluminum Jalousie Window'), findsOneWidget);
    expect(find.text('Offline demo: glass, aluminum and steel • PHP'),
        findsOneWidget);
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pumpAndSettle();
    expect(find.text('No online items'), findsOneWidget);
    expect(calls, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Validates, adds, cancels deletion and confirms deletion',
      (tester) async {
    await tester.pumpWidget(
        FlorglassAluminumApp(client: responseClient({'products': []})));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add service'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Add service'));
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'Custom repair');
    await tester.enterText(find.byType(TextField).at(3), 'NaN');
    await tester.tap(find.widgetWithText(FilledButton, 'Add service'));
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(3), '500');
    await tester.tap(find.widgetWithText(FilledButton, 'Add service'));
    await tester.pumpAndSettle();
    final list = find
        .descendant(
            of: find.byType(HomeScreen), matching: find.byType(ListView))
        .last;
    await tester.scrollUntilVisible(find.text('Custom repair'), 150,
        scrollable:
            find.descendant(of: list, matching: find.byType(Scrollable)).first);
    final tile = find.ancestor(
        of: find.text('Custom repair'), matching: find.byType(ServiceTile));
    await tester.tap(
        find.descendant(of: tile, matching: find.byTooltip('Delete service')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Custom repair'), findsOneWidget);
    await tester.tap(
        find.descendant(of: tile, matching: find.byTooltip('Delete service')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Custom repair'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
