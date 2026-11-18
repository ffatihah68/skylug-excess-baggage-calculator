
import 'package:flutter_test/flutter_test.dart';
import 'package:excess_baggage_calculator/main.dart';

void main() {
  testWidgets('SkyLug app loads successfully',
      (WidgetTester tester) async {

    // Build the SkyLug application
    await tester.pumpWidget(const SkyLugApp());

    // Check whether the app title appears
    expect(find.text('skylug.'), findsOneWidget);

    // Check whether the calculator button exists
    expect(find.text('Calculate Fee'), findsOneWidget);

    // Check whether the reset button exists
    expect(find.text('Reset Calculator'), findsOneWidget);
  });
}
