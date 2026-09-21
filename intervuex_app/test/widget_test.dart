import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intervuex_app/main.dart';

void main() {
  testWidgets('IntervueXApp basic smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: IntervueXApp()));
    await tester.pumpAndSettle();

    // Verify brand title exists
    expect(find.text('InterVueX'), findsWidgets);
    expect(find.text('Ready for your next interview?'), findsWidgets);
  });
}
