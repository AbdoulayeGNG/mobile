import 'package:flutter/material.dart';
import '../../models/teacher_comment_model.dart';
import '../../models/user_model.dart';
import '../../services/student_tracking_service.dart';

class StudentDetailScreen extends StatefulWidget {
  final User student;
  final String teacherId;

  const StudentDetailScreen({
    Key? key,
    required this.student,
    required this.teacherId,
  }) : super(key: key);

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final StudentTrackingService _trackingService = StudentTrackingService();
  final TextEditingController _commentController = TextEditingController();

  Map<String, dynamic>? _progress;
  List<Map<String, dynamic>>? _exercises;
  List<TeacherComment>? _comments;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    setState(() => _isLoading = true);
    try {
      final progress = await _trackingService.getStudentProgress(
        widget.student.id,
      );
      final exercises = await _trackingService.getStudentExerciseDetails(
        widget.student.id,
      );
      final comments = await _trackingService.getStudentComments(
        widget.student.id,
      );

      setState(() {
        _progress = progress;
        _exercises = exercises;
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des données : $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final comment = TeacherComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      teacherId: widget.teacherId,
      studentId: widget.student.id,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await _trackingService.addComment(comment);
      _commentController.clear();
      _loadStudentData(); // Recharger les commentaires
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout du commentaire : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.student.name)),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Carte de progression
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Progression globale',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Cours complétés : ${_progress?['completedCourses'] ?? 0}',
                              ),
                              Text(
                                'Progression moyenne : ${((_progress?['averageProgress'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                              ),
                              Text(
                                'Quiz complétés : ${_progress?['completedQuizzes'] ?? 0}',
                              ),
                              Text(
                                'Score moyen aux quiz : ${(_progress?['averageQuizScore'] ?? 0.0).toStringAsFixed(1)}/100',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Liste des exercices
                      const Text(
                        'Détail des exercices',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_exercises?.isEmpty ?? true)
                        const Text('Aucun exercice complété')
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _exercises?.length ?? 0,
                          itemBuilder: (context, index) {
                            final exercise = _exercises![index];
                            return ListTile(
                              title: Text(exercise['quiz_title']),
                              subtitle: Text(exercise['course_title']),
                              trailing: Text(
                                'Score: ${exercise['score'].toStringAsFixed(1)}/100',
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 16),

                      // Section commentaires
                      const Text(
                        'Commentaires',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Champ d'ajout de commentaire
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                hintText: 'Ajouter un commentaire...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _addComment,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Liste des commentaires
                      if (_comments?.isEmpty ?? true)
                        const Text('Aucun commentaire')
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _comments?.length ?? 0,
                          itemBuilder: (context, index) {
                            final comment = _comments![index];
                            return Card(
                              child: ListTile(
                                title: Text(comment.comment),
                                subtitle: Text(
                                  'Le ${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year}',
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
    );
  }
}
