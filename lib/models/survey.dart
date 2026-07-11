import 'package:cloud_firestore/cloud_firestore.dart';
import 'question.dart';

class Survey {
  const Survey({
    this.id = '',
    required this.title,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.questions,
  });

  final String id;
  final String title;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final List<Question> questions;

  Survey copyWith({
    String? id,
    String? title,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    List<Question>? questions,
  }) {
    return Survey(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      questions: questions ?? this.questions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  factory Survey.fromDocument(String id, Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    return Survey(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.now(),
      questions: ((map['questions'] as List<dynamic>?) ?? [])
          .map((q) => Question.fromMap(q as Map<String, dynamic>))
          .toList(),
    );
  }
}
