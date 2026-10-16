import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:florglassaluminum/main.dart';

http.Client catalogClient() => MockClient((_) async => http.Response(
    jsonEncode({
      'products': [
        {
          'title': 'Steel Flat Bar',
          'description': 'Sample material',
          'price': 450,
          'thumbnail': ''
        }
      ]
    }),
    200));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('Home summary cards open the existing sections', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(FlorglassAluminumApp(client: catalogClient()));
    await tester.pumpAndSettle();

    final services = find.widgetWithText(SummaryCard, 'Services');
    await tester.ensureVisible(services);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Services, 4'), findsOneWidget);
    await tester.tap(services);
    await tester.pumpAndSettle();
    expect(find.text('Our services'), findsOneWidget);
    expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        1);

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    final online = find.widgetWithText(SummaryCard, 'Online items');
    await tester.ensureVisible(online);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Online items, 1'), findsOneWidget);
    await tester.tap(online);
    await tester.pumpAndSettle();
    expect(find.text('Steel Flat Bar'), findsOneWidget);
    expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        2);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  for (final size in [
    const Size(320, 568),
    const Size(360, 640),
    const Size(390, 844),
    const Size(640, 360),
    const Size(1280, 800),
  ]) {
    testWidgets('Screens and add form fit $size', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(FlorglassAluminumApp(client: catalogClient()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Explore services'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Explore services'));
      await tester.pumpAndSettle();
      expect(find.text('Our services'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Add service'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Online items').last);
      await tester.pumpAndSettle();
      expect(find.text('Steel Flat Bar'), findsOneWidget);
      expect(find.text('₱450.00'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Home').last);
      await tester.pumpAndSettle();
      expect(find.text('BUILD WITH CONFIDENCE'), findsOneWidget);
    });
  }

  testWidgets('Error actions fit a landscape viewport', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(640, 360);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(FlorglassAluminumApp(
        client: MockClient((_) async => http.Response('Unavailable', 503))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Online items').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Open offline demo catalog'));
    await tester.tap(find.text('Open offline demo catalog'));
    await tester.pumpAndSettle();
    expect(find.text('Offline demo: glass, aluminum and steel • PHP'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Deleting every service shows the empty state', (tester) async {
    await tester.pumpWidget(FlorglassAluminumApp(client: catalogClient()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Services').last);
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byTooltip('Delete service').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
    }
    expect(find.text('No services yet'), findsOneWidget);
    expect(find.text('Add service'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Failed refresh keeps previous products and shows an error',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(FlorglassAluminumApp(client: MockClient((_) async {
      calls++;
      return calls == 1
          ? http.Response(
              '{"products":[{"title":"Clear Glass","price":1200,"thumbnail":"assets/images/clear-glass.png"}]}',
              200)
          : http.Response('Unavailable', 503);
    })));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Online items').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pumpAndSettle();
    expect(find.text('Clear Glass'), findsOneWidget);
    expect(
        find.textContaining('Could not fetch online products'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Malformed API response shows error and retry', (tester) async {
    await tester.pumpWidget(FlorglassAluminumApp(
        client: MockClient((_) async => http.Response('not JSON', 200))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Online items').last);
    await tester.pumpAndSettle();
    expect(find.text('Unable to load items'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Open offline demo catalog'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('All three supplied steel photographs decode', (tester) async {
    for (final entry in {
      'Steel Flat Bar': 'assets/images/steelflatbar.jpg',
      'Steel Square Tube': 'assets/images/steelsquaretube.jpg',
      'Steel Angle Bar': 'assets/images/steel-bar.png',
    }.entries) {
      expect(
          (await rootBundle.load(entry.value)).lengthInBytes, greaterThan(0));
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: RemoteProductTile(
                  product: RemoteProduct(
                      title: entry.key,
                      description: '',
                      price: 1,
                      thumbnail: '')))));
      await tester.pumpAndSettle();
      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, entry.value);
      expect(find.byIcon(Icons.image_not_supported_outlined), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });
}
