enum QuestionType {
  text,
  rating,
  singleChoice,
  multiChoice,
}

extension QuestionTypeName on QuestionType {
  String get displayName {
    switch (this) {
      case QuestionType.text:
        return 'Text';
      case QuestionType.rating:
        return 'Rating';
      case QuestionType.singleChoice:
        return 'Single Choice';
      case QuestionType.multiChoice:
        return 'Multiple Choice';
    }
  }
}

class Question {
  const Question({
    required this.id,
    required this.text,
    required this.type,
    this.options = const [],
    this.isRequired = true,
  });

  final String id;
  final String text;
  final QuestionType type;
  final List<String> options;
  final bool isRequired;

  Question copyWith({
    String? id,
    String? text,
    QuestionType? type,
    List<String>? options,
    bool? isRequired,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      options: options ?? this.options,
      isRequired: isRequired ?? this.isRequired,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'type': type.name,
      'options': options,
      'isRequired': isRequired,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as String? ?? '',
      text: map['text'] as String? ?? '',
      type: QuestionType.values.byName(
        (map['type'] as String?) ?? 'text',
      ),
      options: List<String>.from((map['options'] as List<dynamic>?) ?? []),
      isRequired: map['isRequired'] as bool? ?? true,
    );
  }
}
