class TeacherComment {
  final String id;
  final String teacherId;
  final String studentId;
  final String comment;
  final DateTime createdAt;
  final String? courseId; // Optional - can be null if it's a general comment
  final String?
  quizId; // Optional - can be null if it's not related to a specific quiz

  TeacherComment({
    required this.id,
    required this.teacherId,
    required this.studentId,
    required this.comment,
    required this.createdAt,
    this.courseId,
    this.quizId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'student_id': studentId,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'course_id': courseId,
      'quiz_id': quizId,
    };
  }

  factory TeacherComment.fromMap(Map<String, dynamic> map) {
    return TeacherComment(
      id: map['id'],
      teacherId: map['teacher_id'],
      studentId: map['student_id'],
      comment: map['comment'],
      createdAt: DateTime.parse(map['created_at']),
      courseId: map['course_id'],
      quizId: map['quiz_id'],
    );
  }
}
