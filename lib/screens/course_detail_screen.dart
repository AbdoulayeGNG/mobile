import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../models/course_model.dart';
import '../models/quiz_model.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../widgets/pdf_viewer_widget.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/quiz_widget.dart';

class CourseDetailScreen extends StatefulWidget {
  static const String routeName = '/course-detail';

  const CourseDetailScreen({Key? key}) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final DatabaseService _db = DatabaseService();
  Map<String, dynamic>? _progress;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final course = ModalRoute.of(context)!.settings.arguments as Course;
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final progress = await _db.getCourseProgress(user.id, course.id);
      if (mounted) {
        setState(() {
          _progress = progress;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _updateProgress(Course course, double progress, {String? position}) async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    try {
      await _db.updateCourseProgress(
        user.id,
        course.id,
        progress,
        lastPosition: position,
      );
      await _loadProgress();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de mise à jour: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = ModalRoute.of(context)!.settings.arguments as Course;

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProgress,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barre de progression en haut
                  LinearProgressIndicator(
                    value: (_progress?['progress'] as num?)?.toDouble() ?? 0.0,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête du cours
                        Text(
                          course.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          course.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),

                        // Contenu principal du cours
                        _buildCourseContent(course),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCourseContent(Course course) {
    // Position sauvegardée pour les vidéos/PDFs
    final lastPosition = _progress?['last_position'];

    switch (course.type.toLowerCase()) {
      case 'pdf':
        if (course.filePath == null) {
          return const Center(child: Text('Fichier PDF non disponible'));
        }
        return PDFViewerWidget(
          filePath: course.filePath!,
          initialPage: lastPosition != null ? int.tryParse(lastPosition) ?? 1 : 1,
          onPageChanged: (page) {
            final totalPages = 1; // À remplacer par le nombre réel de pages
            _updateProgress(
              course,
              page / totalPages,
              position: page.toString(),
            );
          },
        );

      case 'video':
        if (course.filePath == null) {
          return const Center(child: Text('Fichier vidéo non disponible'));
        }
        return VideoPlayerWidget(
          videoPath: course.filePath!,
          initialPosition: lastPosition != null 
            ? Duration(milliseconds: int.tryParse(lastPosition) ?? 0) 
            : Duration.zero,
          onProgressChanged: (position, duration) {
            if (duration.inMilliseconds > 0) {
              _updateProgress(
                course,
                position.inMilliseconds / duration.inMilliseconds,
                position: position.inMilliseconds.toString(),
              );
            }
          },
        );

      case 'quiz':
        return _buildQuizContent(course);

      default:
        return SingleChildScrollView(
          child: Column(
            children: [
              Text(
                course.content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _updateProgress(course, 1.0),
                child: const Text('Marquer comme terminé'),
              ),
            ],
          ),
        );
    }
  }
  Widget _buildQuizContent(Course course) {
    try {
      final quizData = jsonDecode(course.content);
      final quiz = Quiz.fromJson(quizData);
      
      return QuizWidget(
        quiz: quiz,
        onQuizCompleted: (score, totalQuestions) {
          // La progression est basée sur le score obtenu
          final progress = score / 100.0;
          _updateProgress(
            course,
            progress,
            position: score.toString(), // Sauvegarder le score comme position
          );
        },
      );
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement du quiz',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              e.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}
