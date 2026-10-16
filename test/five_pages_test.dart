import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:florglassaluminum/main.dart';

Future<void> openContact(WidgetTester tester) async {
  await tester.pumpWidget(FlorglassAluminumApp(
      client: MockClient((_) async => http.Response('{"products":[]}', 200))));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(NavigationDestination).at(4));
  await tester.pumpAndSettle();
}

Future<void> submit(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'Submit Demo Inquiry');
  await tester.scrollUntilVisible(button, 180,
      scrollable: find
          .descendant(
              of: find.byType(ContactUsPage), matching: find.byType(Scrollable))
          .first);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> fill(WidgetTester tester, int index, String text) async {
  final field = find.byType(TextFormField).at(index);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final size in [
    const Size(320, 568),
    const Size(360, 640),
    const Size(390, 844),
    const Size(640, 360),
    const Size(1280, 800)
  ]) {
    testWidgets('Exactly five destinations navigate without overflow at $size',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(FlorglassAluminumApp(
          client:
              MockClient((_) async => http.Response('{"products":[]}', 200))));
      await tester.pumpAndSettle();
      final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(nav.destinations, hasLength(5));
      expect(nav.destinations.cast<NavigationDestination>().map((d) => d.label),
          ['Home', 'Services', 'Online items', 'About Us', 'Contact Us']);
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byType(NavigationDestination).at(i));
        await tester.pumpAndSettle();
        expect(
            tester
                .widget<NavigationBar>(find.byType(NavigationBar))
                .selectedIndex,
            i);
        switch (i) {
          case 0:
            expect(find.text('BUILD WITH CONFIDENCE'), findsOneWidget);
          case 1:
            expect(find.text('Our services'), findsOneWidget);
          case 2:
            expect(find.text('No online items'), findsOneWidget);
          case 3:
            expect(find.byType(AboutUsPage), findsOneWidget);
          case 4:
            expect(find.byType(ContactUsPage), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      }
      await submit(tester);
      expect(find.text('Enter your full name.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'About page includes offerings and an explicitly proposed mission',
      (tester) async {
    await openContact(tester);
    await tester.tap(find.byType(NavigationDestination).at(3));
    await tester.pumpAndSettle();
    expect(find.text('Flor Glass & Aluminum Works'), findsOneWidget);
    expect(
        find.text('Villanueva, Tubigon, Bohol, Philippines.'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Proposed mission'), 200,
        scrollable: find.byType(Scrollable).last);
    expect(
        find.text(
            'Proposed application copy — not a verified official company statement.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Contact validates required fields and invalid contact details',
      (tester) async {
    await openContact(tester);
    await submit(tester);
    expect(find.text('Enter your full name.'), findsOneWidget);
    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Enter your inquiry message.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    await fill(tester, 0, 'Demo Visitor');
    await fill(tester, 1, 'invalid-contact');
    await fill(tester, 2, 'Please provide a sample quote.');
    await submit(tester);
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    await fill(tester, 1, '+63 912 345 6789');
    await submit(tester);
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  for (final contact in ['demo@example.com', 'visitor@example.org']) {
    testWidgets(
        'Demo inquiry accepts $contact, explains no delivery and clears input',
        (tester) async {
      await openContact(tester);
      await fill(tester, 0, 'Demo Visitor');
      await fill(tester, 1, contact);
      await fill(tester, 2, 'Please provide a sample quote.');
      await submit(tester);
      expect(find.text('Demo inquiry — not sent'), findsOneWidget);
      expect(
          find.textContaining('no inquiry was sent or saved'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      for (final field
          in tester.widgetList<TextFormField>(find.byType(TextFormField))) {
        expect(field.controller!.text, isEmpty);
      }
      expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}
