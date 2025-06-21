import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../models/course_model.dart';
import 'database_service.dart';

class DownloadService {
  final DatabaseService _db = DatabaseService();
  final Dio _dio = Dio();
  static DownloadService? _instance;

  DownloadService._();

  factory DownloadService() {
    _instance ??= DownloadService._();
    return _instance!;
  }

  Future<String?> downloadCourse(
    Course course, 
    void Function(int received, int total)? onProgress
  ) async {
    try {
      // Créer le dossier de téléchargement s'il n'existe pas
      final dir = await getApplicationDocumentsDirectory();
      final coursesDir = Directory('${dir.path}/courses');
      if (!await coursesDir.exists()) {
        await coursesDir.create(recursive: true);
      }

      // Définir le chemin du fichier
      final fileName = '${course.id}_${DateTime.now().millisecondsSinceEpoch}${_getFileExtension(course.type)}';
      final filePath = '${coursesDir.path}/$fileName';

      // Télécharger le fichier
      await _dio.download(
        course.content,
        filePath,
        onReceiveProgress: onProgress,
      );

      // Mettre à jour le statut dans la base de données
      await _db.updateCourseDownloadStatus(
        courseId: course.id,
        isDownloaded: true,
        filePath: filePath,
      );

      return filePath;
    } catch (e) {
      print('Erreur lors du téléchargement: $e');
      return null;
    }
  }

  Future<bool> deleteCourseFile(String courseId) async {
    try {
      final course = await _db.getCourse(courseId);
      if (course != null && course.filePath != null) {
        final file = File(course.filePath!);
        if (await file.exists()) {
          await file.delete();
        }
        await _db.updateCourseDownloadStatus(
          courseId: courseId,
          isDownloaded: false,
          filePath: null,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la suppression: $e');
      return false;
    }
  }

  Future<List<Course>> getDownloadedCourses() async {
    try {
      return await _db.getDownloadedCourses();
    } catch (e) {
      print('Erreur lors de la récupération des cours téléchargés: $e');
      return [];
    }
  }

  Future<bool> isCourseDownloaded(String courseId) async {
    try {
      final course = await _db.getCourse(courseId);
      return course?.isDownloaded ?? false;
    } catch (e) {
      print('Erreur lors de la vérification du téléchargement: $e');
      return false;
    }
  }

  String _getFileExtension(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return '.pdf';
      case 'video':
        return '.mp4';
      case 'quiz':
        return '.json';
      default:
        return '.txt';
    }
  }
}