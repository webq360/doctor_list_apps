import 'package:flutter_test/flutter_test.dart';
import 'package:doctor_list/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DoctorListApp());
    expect(find.byType(DoctorListApp), findsOneWidget);
  });
}
