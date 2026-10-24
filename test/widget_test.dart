import 'package:flutter_test/flutter_test.dart';
import 'package:ace_attendiq/main.dart';

void main() {
  testWidgets('ACE AttendIQ login screen renders', (tester) async {
    await tester.pumpWidget(const AceAttendIQApp());
    expect(find.text('ACE AttendIQ'), findsOneWidget);
    expect(find.text('Faculty Login'), findsOneWidget);
  });
}
