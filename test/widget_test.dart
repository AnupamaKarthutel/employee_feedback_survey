// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:employee_feedback_survey/main.dart';
import 'package:employee_feedback_survey/services/in_memory_survey_service.dart';

void main() {
  testWidgets('Home screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(service: InMemorySurveyService()),
    );

    expect(find.text('Employee Feedback'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('No surveys yet. Create the first one!'), findsOneWidget);
  });
}
