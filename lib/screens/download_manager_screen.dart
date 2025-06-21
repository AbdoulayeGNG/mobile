import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/download_service.dart';
import '../services/database_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DownloadManagerScreen extends StatefulWidget {
  static const String routeName = '/download-manager';

  const DownloadManagerScreen({Key? key}) : super(key: key);

  @override
  State<DownloadManagerScreen> createState() => _DownloadManagerScreenState();
}

class _DownloadManagerScreenState extends State<DownloadManagerScreen> {
  final DownloadService _downloadService = DownloadService();
  final DatabaseService _databaseService = DatabaseService();
  List<Course> _downloadedCourses = [];
  bool _isLoading = true;
  String _storageInfo = '';

  @override
  void initState() {
    super.initState();
    _loadDownloadedCourses();
    _calculateStorageUsage();
  }

  Future<void> _loadDownloadedCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final courses = await _databaseService.getDownloadedCourses();
      if (mounted) {
        setState(() {
          _downloadedCourses = courses;
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

  Future<void> _calculateStorageUsage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final coursesDir = Directory('${directory.path}/courses');

      if (await coursesDir.exists()) {
        int totalSize = 0;
        await for (var entity in coursesDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }

        String sizeText = '';
        if (totalSize > 1024 * 1024 * 1024) {
          sizeText =
              '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
        } else if (totalSize > 1024 * 1024) {
          sizeText = '${(totalSize / (1024 * 1024)).toStringAsFixed(2)} MB';
        } else if (totalSize > 1024) {
          sizeText = '${(totalSize / 1024).toStringAsFixed(2)} KB';
        } else {
          sizeText = '$totalSize bytes';
        }

        if (mounted) {
          setState(() {
            _storageInfo = 'Espace utilisé: $sizeText';
          });
        }
      }
    } catch (e) {
      print('Erreur lors du calcul de l\'espace utilisé: $e');
    }
  }

  Future<void> _deleteCourse(Course course) async {
    try {
      await _downloadService.deleteCourseFile(course.id);
      _loadDownloadedCourses();
      _calculateStorageUsage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cours supprimé avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Téléchargements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadDownloadedCourses();
              _calculateStorageUsage();
            },
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec info stockage
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.storage),
                const SizedBox(width: 8),
                Text(
                  _storageInfo,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          // Liste des cours téléchargés
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _downloadedCourses.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download_done,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun cours téléchargé',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _downloadedCourses.length,
                      itemBuilder: (context, index) {
                        final course = _downloadedCourses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: _getFileTypeIcon(course.type),
                            title: Text(course.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(course.description),
                                if (course.filePath != null)
                                  Text(
                                    'Téléchargé le: ${course.updatedAt}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.open_in_new),
                                  onPressed: () async {
                                    if (course.filePath != null) {
                                      // Ouvrir le fichier
                                    }
                                  },
                                  tooltip: 'Ouvrir',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _deleteCourse(course),
                                  tooltip: 'Supprimer',
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _getFileTypeIcon(String type) {
    IconData iconData;
    Color color;

    switch (type.toLowerCase()) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'video':
        iconData = Icons.video_library;
        color = Colors.blue;
        break;
      case 'quiz':
        iconData = Icons.quiz;
        color = Colors.orange;
        break;
      default:
        iconData = Icons.description;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(iconData, color: color),
    );
  }
}
