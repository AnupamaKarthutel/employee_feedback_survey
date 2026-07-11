import 'package:cloud_firestore/cloud_firestore.dart';

class SurveyResponse {
  const SurveyResponse({
    this.id = '',
    required this.surveyId,
    required this.employeeId,
    required this.employeeName,
    required this.submittedAt,
    required this.answers,
  });

  final String id;
  final String surveyId;
  final String employeeId;
  final String employeeName;
  final DateTime submittedAt;
  final Map<String, dynamic> answers;

  SurveyResponse copyWith({
    String? id,
    String? surveyId,
    String? employeeId,
    String? employeeName,
    DateTime? submittedAt,
    Map<String, dynamic>? answers,
  }) {
    return SurveyResponse(
      id: id ?? this.id,
      surveyId: surveyId ?? this.surveyId,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      submittedAt: submittedAt ?? this.submittedAt,
      answers: answers ?? this.answers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'surveyId': surveyId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'answers': answers,
    };
  }

  factory SurveyResponse.fromDocument(String id, Map<String, dynamic> map) {
    final submittedAt = map['submittedAt'];
    return SurveyResponse(
      id: id,
      surveyId: map['surveyId'] as String? ?? '',
      employeeId: map['employeeId'] as String? ?? '',
      employeeName: map['employeeName'] as String? ?? '',
      submittedAt: submittedAt is Timestamp
          ? submittedAt.toDate()
          : DateTime.now(),
      answers: Map<String, dynamic>.from(
        (map['answers'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}
