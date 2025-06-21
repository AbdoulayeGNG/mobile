import 'package:flutter/material.dart';
import '../services/quiz_service.dart';

class QuizStatsScreen extends StatefulWidget {
  static const String routeName = '/quiz-stats';

  const QuizStatsScreen({Key? key}) : super(key: key);

  @override
  State<QuizStatsScreen> createState() => _QuizStatsScreenState();
}

class _QuizStatsScreenState extends State<QuizStatsScreen> {
  final QuizService _quizService = QuizService();
  bool _isLoading = true;
  Map<String, Map<String, dynamic>> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final userId = "current_user_id"; // À remplacer par l'ID réel de l'utilisateur
      final stats = await _quizService.getStatsBySubject(userId);
      
      if (mounted) {
        setState(() {
          _stats = stats;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques des Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats.isEmpty
              ? const Center(
                  child: Text('Aucune statistique disponible'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vue d'ensemble
                      _buildOverview(),
                      const SizedBox(height: 24),

                      // Stats par matière
                      Text(
                        'Par matière',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ..._stats.entries.map((entry) => _buildSubjectCard(
                            entry.key,
                            entry.value,
                          )),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOverview() {
    if (_stats.isEmpty) return const SizedBox();

    int totalAttempts = 0;
    double totalScore = 0;
    int totalPassed = 0;

    _stats.values.forEach((stat) {
      totalAttempts += stat['attempts'] as int;
      totalScore += (stat['averageScore'] as double) * (stat['attempts'] as int);
      totalPassed += stat['passedCount'] as int;
    });

    final averageScore = totalScore / totalAttempts;
    final passRate = (totalPassed / totalAttempts) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vue d\'ensemble',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildStatRow('Quiz complétés', '$totalAttempts'),
            _buildStatRow('Score moyen', '${averageScore.toStringAsFixed(1)}%'),
            _buildStatRow('Taux de réussite', '${passRate.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(String subject, Map<String, dynamic> stats) {
    final attempts = stats['attempts'] as int;
    final averageScore = stats['averageScore'] as double;
    final bestScore = stats['bestScore'] as double;
    final passedCount = stats['passedCount'] as int;
    final passRate = (passedCount / attempts) * 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subject,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${averageScore.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _getScoreColor(averageScore),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: averageScore / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getScoreColor(averageScore),
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            _buildStatRow('Tentatives', '$attempts'),
            _buildStatRow('Meilleur score', '${bestScore.toStringAsFixed(1)}%'),
            _buildStatRow('Taux de réussite', '${passRate.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
