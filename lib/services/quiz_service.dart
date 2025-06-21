import 'dart:convert';
//import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';
//import '../models/quiz_model.dart';

class QuizService {
  final DatabaseService _db = DatabaseService();

  // Sauvegarder le résultat d'un quiz
  Future<void> saveQuizResult({
    required String userId,
    required String courseId,
    required String quizId,
    required double score,
    required Map<String, List<String>> userAnswers,
    required bool isPracticeMode,
  }) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();      await db.insert(
      'quiz_results',
      {
        'user_id': userId,
        'course_id': courseId,
        'quiz_id': quizId,
        'score': score,
        'user_answers': jsonEncode(userAnswers),
        'is_practice_mode': isPracticeMode ? 1 : 0,
        'completed_at': now,
      },
    );
  }

  // Obtenir les statistiques par matière
  Future<Map<String, Map<String, dynamic>>> getStatsBySubject(String userId) async {
    final db = await _db.database;
    
    final results = await db.rawQuery('''
      SELECT 
        s.id as subject_id,
        s.name as subject_name,
        COUNT(qr.id) as attempts,
        AVG(qr.score) as average_score,
        MAX(qr.score) as best_score,
        SUM(CASE WHEN qr.score >= q.passing_score THEN 1 ELSE 0 END) as passed_count
      FROM subjects s
      JOIN courses c ON c.subject_id = s.id
      JOIN quiz_results qr ON qr.course_id = c.id
      JOIN quizzes q ON q.id = qr.quiz_id
      WHERE qr.user_id = ? AND qr.is_practice_mode = 0
      GROUP BY s.id, s.name
    ''', [userId]);

    Map<String, Map<String, dynamic>> stats = {};
    for (var row in results) {
      stats[row['subject_name'] as String] = {
        'attempts': row['attempts'] as int,
        'averageScore': (row['average_score'] as num).toDouble(),
        'bestScore': (row['best_score'] as num).toDouble(),
        'passedCount': row['passed_count'] as int,
      };
    }
    return stats;
  }

  // Obtenir l'historique des quiz pour un cours
  Future<List<Map<String, dynamic>>> getQuizHistory(String userId, String courseId) async {
    final db = await _db.database;
    
    return await db.query(
      'quiz_results',
      where: 'user_id = ? AND course_id = ?',
      whereArgs: [userId, courseId],
      orderBy: 'completed_at DESC',
    );
  }

  // Obtenir les réponses sauvegardées d'un quiz spécifique
  Future<Map<String, List<String>>?> getSavedAnswers(
    String userId,
    String quizId,
  ) async {
    final db = await _db.database;
    
    final result = await db.query(
      'quiz_results',
      where: 'user_id = ? AND quiz_id = ?',
      whereArgs: [userId, quizId],
      orderBy: 'completed_at DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {      final answersStr = result.first['user_answers'] as String;      Map<String, List<String>> map = {};
      try {
        // Décoder la chaîne JSON en Map
        final Map<String, dynamic> jsonMap = json.decode(answersStr);
        
        // Convertir les valeurs dynamiques en List<String>
        jsonMap.forEach((key, value) {
          if (value is List) {
            map[key] = value.map((e) => e.toString()).toList();
          }
        });
      } catch (e) {
        print('Erreur lors de la conversion des réponses: $e');
      }      return map;
    }
    return null;
  }
}
