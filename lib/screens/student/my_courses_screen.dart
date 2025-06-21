import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../services/database_service.dart';
import '../../widgets/download_button.dart';
//import '../../providers/auth_provider.dart';

class MyCoursesScreen extends StatefulWidget {
  static const String routeName = '/my-courses';

  const MyCoursesScreen({Key? key}) : super(key: key);

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  final DatabaseService _db = DatabaseService();
  List<Course> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final courses = await _db.getAllCourses();

      if (mounted) {
        setState(() {
          _courses = courses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Cours'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCourses,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadCourses,
                child:
                    _courses.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.school_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Aucun cours disponible',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              TextButton(
                                onPressed: _loadCourses,
                                child: const Text('Rafraîchir'),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _courses.length,
                          itemBuilder: (context, index) {
                            final course = _courses[index];
                            return Card(
                              child: ListTile(
                                leading: _getLeadingIcon(course.type),
                                title: Text(course.title),
                                subtitle: Text(course.description),
                                trailing: DownloadButton(course: course),
                                onTap: () {
                                  // TODO: Naviguer vers le détail du cours
                                },
                              ),
                            );
                          },
                        ),
              ),
    );
  }

  Widget _getLeadingIcon(String type) {
    IconData iconData;
    switch (type.toLowerCase()) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        break;
      case 'video':
        iconData = Icons.video_library;
        break;
      case 'quiz':
        iconData = Icons.quiz;
        break;
      default:
        iconData = Icons.description;
    }
    return CircleAvatar(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Icon(iconData, color: Theme.of(context).primaryColor),
    );
  }
}
