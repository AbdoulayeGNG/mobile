import 'package:sqflite/sqflite.dart';
import '../models/teacher_comment_model.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class StudentTrackingService {
  final DatabaseService _db = DatabaseService();

  // Récupérer la liste des élèves par classe
  Future<List<User>> getStudentsByClass(String classId) async {
    final db = await _db.database;
    final results = await db.query(
      'users',
      where: 'role = ? AND class_id = ?',
      whereArgs: ['student', classId],
      orderBy: 'last_name, first_name',
    );

    return results.map((map) => User.fromJson(map)).toList();
  }

  // Obtenir la progression globale d'un élève
  Future<Map<String, dynamic>> getStudentProgress(String studentId) async {
    final db = await _db.database;

    final results = await db.rawQuery(
      '''
      SELECT 
        COUNT(DISTINCT cr.course_id) as completed_courses,
        AVG(cr.progress) as average_progress,
        COUNT(DISTINCT qr.quiz_id) as completed_quizzes,
        AVG(qr.score) as average_quiz_score
      FROM course_progress cr
      LEFT JOIN quiz_results qr ON qr.user_id = cr.user_id
      WHERE cr.user_id = ?
    ''',
      [studentId],
    );

    if (results.isNotEmpty) {
      return {
        'completedCourses': results.first['completed_courses'] as int,
        'averageProgress':
            (results.first['average_progress'] as num?)?.toDouble() ?? 0.0,
        'completedQuizzes': results.first['completed_quizzes'] as int,
        'averageQuizScore':
            (results.first['average_quiz_score'] as num?)?.toDouble() ?? 0.0,
      };
    }
    return {
      'completedCourses': 0,
      'averageProgress': 0.0,
      'completedQuizzes': 0,
      'averageQuizScore': 0.0,
    };
  }

  // Obtenir les détails des exercices d'un élève
  Future<List<Map<String, dynamic>>> getStudentExerciseDetails(
    String studentId,
  ) async {
    final db = await _db.database;

    return await db.rawQuery(
      '''
      SELECT 
        c.title as course_title,
        q.title as quiz_title,
        qr.score,
        qr.completed_at,
        qr.is_practice_mode
      FROM quiz_results qr
      JOIN courses c ON c.id = qr.course_id
      JOIN quizzes q ON q.id = qr.quiz_id
      WHERE qr.user_id = ?
      ORDER BY qr.completed_at DESC
    ''',
      [studentId],
    );
  }

  // Ajouter un commentaire
  Future<TeacherComment> addComment(TeacherComment comment) async {
    final db = await _db.database;

    await db.insert('teacher_comments', comment.toMap());
    return comment;
  }

  // Récupérer les commentaires d'un élève
  Future<List<TeacherComment>> getStudentComments(String studentId) async {
    final db = await _db.database;

    final results = await db.query(
      'teacher_comments',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'created_at DESC',
    );

    return results.map((map) => TeacherComment.fromMap(map)).toList();
  }

  // Mettre à jour la table de la base de données
  Future<void> createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS teacher_comments (
        id TEXT PRIMARY KEY,
        teacher_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        comment TEXT NOT NULL,
        created_at TEXT NOT NULL,
        course_id TEXT,
        quiz_id TEXT,
        FOREIGN KEY (teacher_id) REFERENCES users (id),
        FOREIGN KEY (student_id) REFERENCES users (id),
        FOREIGN KEY (course_id) REFERENCES courses (id),
        FOREIGN KEY (quiz_id) REFERENCES quizzes (id)
      )
    ''');
  }
}
