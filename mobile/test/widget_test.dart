import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('ShoppeFake renders authentication screen on launch',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title and login CTA are displayed.
    expect(find.text('ShoppeFake'), findsOneWidget);
    expect(find.text('ENTER THE LOOP'), findsOneWidget);
  });
}
