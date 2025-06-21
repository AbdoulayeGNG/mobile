import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/student_tracking_service.dart';

class StudentTrackingScreen extends StatefulWidget {
  final String teacherId;
  final String classId;

  const StudentTrackingScreen({
    Key? key,
    required this.teacherId,
    required this.classId,
  }) : super(key: key);

  @override
  State<StudentTrackingScreen> createState() => _StudentTrackingScreenState();
}

class _StudentTrackingScreenState extends State<StudentTrackingScreen> {
  final StudentTrackingService _trackingService = StudentTrackingService();
  List<User> _students = [];
  Map<String, Map<String, dynamic>> _progressData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final students = await _trackingService.getStudentsByClass(
        widget.classId,
      );

      // Charger les données de progression pour chaque élève
      final progressData = <String, Map<String, dynamic>>{};
      for (var student in students) {
        progressData[student.id] = await _trackingService.getStudentProgress(
          student.id,
        );
      }

      setState(() {
        _students = students;
        _progressData = progressData;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des élèves : $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi des élèves'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStudents),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final student = _students[index];
                  final progress = _progressData[student.id] ?? {};

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          student.name
                              .split(' ')
                              .map((part) => part[0])
                              .take(2)
                              .join(''),
                        ),
                      ),
                      title: Text(student.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progression moyenne : ${(progress['averageProgress'] * 100).toStringAsFixed(1)}%',
                          ),
                          Text(
                            'Score moyen aux quiz : ${(progress['averageQuizScore']).toStringAsFixed(1)}/100',
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/teacher/student-detail',
                          arguments: {
                            'student': student,
                            'teacherId': widget.teacherId,
                          },
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
