class Quiz {
  final String id;
  final String courseId;
  final String title;
  final List<Question> questions;
  final int passingScore;
  final int timeLimit; // en secondes, 0 = pas de limite

  Quiz({
    required this.id,
    required this.courseId,
    required this.title,
    required this.questions,
    required this.passingScore,
    this.timeLimit = 0,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
      passingScore: json['passing_score'] as int,
      timeLimit: json['time_limit'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'course_id': courseId,
        'title': title,
        'questions': questions.map((q) => q.toJson()).toList(),
        'passing_score': passingScore,
        'time_limit': timeLimit,
      };
}

class Question {
  final String id;
  final String text;
  final List<Answer> answers;
  final String? explanation;
  final QuestionType type;
  final int points;

  Question({
    required this.id,
    required this.text,
    required this.answers,
    this.explanation,
    required this.type,
    this.points = 1,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      answers: (json['answers'] as List)
          .map((a) => Answer.fromJson(a))
          .toList(),
      explanation: json['explanation'] as String?,
      type: QuestionType.values.firstWhere(
        (e) => e.toString() == 'QuestionType.${json['type']}',
        orElse: () => QuestionType.singleChoice,
      ),
      points: json['points'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'answers': answers.map((a) => a.toJson()).toList(),
        'explanation': explanation,
        'type': type.toString().split('.').last,
        'points': points,
      };
}

class Answer {
  final String id;
  final String text;
  final bool isCorrect;
  final String? explanation;

  Answer({
    required this.id,
    required this.text,
    required this.isCorrect,
    this.explanation,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] as String,
      text: json['text'] as String,
      isCorrect: json['is_correct'] as bool,
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'is_correct': isCorrect,
        'explanation': explanation,
      };
}

enum QuestionType {
  singleChoice,
  multipleChoice,
  trueFalse,
  shortAnswer,
}
