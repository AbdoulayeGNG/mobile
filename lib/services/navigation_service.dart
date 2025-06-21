import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/database_service.dart';
import '../screens/course_detail_screen.dart';
import '../screens/forum_screen.dart';
//import '../screens/notifications_screen.dart';
import '../screens/quiz_stats_screen.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final DatabaseService _db = DatabaseService();

  Future<void> navigateToContent(BuildContext context, {
    required String contentId,
    required String type,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      switch (type.toLowerCase()) {
        case 'course':
          await _navigateToCourse(context, contentId);
          break;
        
        case 'quiz':
          await _navigateToQuiz(context, contentId);
          break;
        
        case 'forum':
          _navigateToForum(context, contentId, additionalData);
          break;
        
        case 'achievement':
          _navigateToAchievement(context, contentId);
          break;
        
        default:
          print('Type de contenu non géré: $type');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de navigation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToCourse(BuildContext context, String courseId) async {
    try {
      // Récupérer les détails du cours
      final Course? course = await _db.getCourse(courseId);
      if (course == null) {
        throw Exception('Cours non trouvé');
      }

      if (context.mounted) {
        Navigator.pushNamed(
          context,
          CourseDetailScreen.routeName,
          arguments: course,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _navigateToQuiz(BuildContext context, String quizId) async {
    try {
      // Récupérer les détails du quiz
      final courseId = await _db.getCourseIdForQuiz(quizId);
      if (courseId == null) {
        throw Exception('Quiz non trouvé');
      }

      // D'abord naviguer vers le cours
      await _navigateToCourse(context, courseId);
    } catch (e) {
      rethrow;
    }
  }

  void _navigateToForum(
    BuildContext context,
    String threadId,
    Map<String, dynamic>? additionalData,
  ) {
    Navigator.pushNamed(
      context,
      ForumScreen.routeName,
      arguments: {
        'threadId': threadId,
        if (additionalData != null) ...additionalData,
      },
    );
  }

  void _navigateToAchievement(BuildContext context, String achievementId) {
    Navigator.pushNamed(
      context,
      QuizStatsScreen.routeName,
      arguments: achievementId,
    );
  }
}
