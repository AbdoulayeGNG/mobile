import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/course_model.dart';
import '../services/database_service.dart';

class LearningDashboardScreen extends StatefulWidget {
  static const String routeName = '/learning-dashboard';

  const LearningDashboardScreen({Key? key}) : super(key: key);

  @override
  State<LearningDashboardScreen> createState() => _LearningDashboardScreenState();
}

class _LearningDashboardScreenState extends State<LearningDashboardScreen> {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;
  List<Course> _recentCourses = [];
  Map<String, double> _subjectProgress = {};
  List<Course> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final progressBySubject = await _db.getUserProgressBySubject(user.id);
      final recentCourses = await _db.getRecentCourses(user.id);
      final recommendations = await _db.getRecommendedCourses(user.id);
      
      if (mounted) {
        setState(() {
          _subjectProgress = progressBySubject;
          _recentCourses = recentCourses;
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Apprentissage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Afficher les notifications
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // En-tête avec progression globale
                  _buildOverallProgress(),
                  const SizedBox(height: 24),

                  // Progression par matière
                  _buildSubjectProgress(),
                  const SizedBox(height: 24),

                  // Derniers cours consultés
                  _buildRecentCourses(),
                  const SizedBox(height: 24),

                  // Recommandations
                  _buildRecommendations(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverallProgress() {
    final overallProgress = _subjectProgress.isEmpty
        ? 0.0
        : _subjectProgress.values.reduce((a, b) => a + b) /
            _subjectProgress.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progression Globale',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: overallProgress,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(overallProgress * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectProgress() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progression par Matière',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._subjectProgress.entries.map((entry) {
              final color = _getSubjectColor(entry.key);
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      Text(
                        '${(entry.value * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: entry.value,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCourses() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Derniers Cours Consultés',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _recentCourses.isEmpty
                ? const Text('Aucun cours consulté récemment')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentCourses.length,
                    itemBuilder: (context, index) {
                      final course = _recentCourses[index];
                      return ListTile(
                        title: Text(course.title),
                        subtitle: Row(
                          children: [
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 8),
                            Text(course.lastAccessedAt ?? 'Jamais consulté'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_circle_outline),
                          onPressed: () {
                            // TODO: Naviguer vers le cours
                            Navigator.pushNamed(
                              context,
                              '/course-detail',
                              arguments: course,
                            );
                          },
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommandations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _recommendations.isEmpty
                ? const Text('Aucune recommandation pour le moment')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recommendations.length,
                    itemBuilder: (context, index) {
                      final course = _recommendations[index];
                      return ListTile(
                        leading: Icon(
                          _getIconForCourseType(course.type),
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(course.title),
                        subtitle: Text(course.description),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/course-detail',
                              arguments: course,
                            );
                          },
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    // Couleurs associées aux matières
    const colors = {
      'Mathématiques': Colors.blue,
      'Physique': Colors.purple,
      'Français': Colors.red,
      'Anglais': Colors.green,
      'Histoire': Colors.orange,
      'Géographie': Colors.brown,
      'SVT': Colors.teal,
      'Chimie': Colors.pink,
    };
    return colors[subject] ?? Colors.grey;
  }

  IconData _getIconForCourseType(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'video':
        return Icons.play_circle_outline;
      case 'quiz':
        return Icons.quiz;
      default:
        return Icons.article;
    }
  }
}
