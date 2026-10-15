import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:florglassaluminum/main.dart';

void main() {
  testWidgets('App loads products and bundled images', (tester) async {
    await tester.pumpWidget(const FlorglassAluminumApp());
    await tester.pumpAndSettle();
    expect(find.text('FlorglassAluminum'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Online items').last);
    await tester.pumpAndSettle();
    expect(find.text('Aluminum Jalousie Window'), findsOneWidget);
    final state = tester.state(find.byType(HomeScreen)) as dynamic;
    final products = state.remoteProducts as List<RemoteProduct>;
    expect(products, hasLength(8));
    for (final product in products) {
      final bytes = await rootBundle.load(product.thumbnail);
      expect(bytes.lengthInBytes, greaterThan(0));
      await tester.pumpWidget(MaterialApp(home: Image.asset(product.thumbnail)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
