import 'package:flutter_test/flutter_test.dart';
import 'package:split_spend/main.dart';

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    await tester.pumpWidget(const SplitSpendApp());
    await tester.pump();
    expect(find.byType(SplitSpendApp), findsOneWidget);
  });
}
