import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/download_service.dart';
import 'package:open_file/open_file.dart';

class DownloadButton extends StatefulWidget {
  final Course course;

  const DownloadButton({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  final DownloadService _downloadService = DownloadService();
  bool _isDownloading = false;
  double _progress = 0;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final isDownloaded = await _downloadService.isCourseDownloaded(widget.course.id);
    if (mounted) {
      setState(() {
        _isDownloaded = isDownloaded;
      });
    }
  }

  Future<void> _downloadCourse() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    try {
      final filePath = await _downloadService.downloadCourse(
        widget.course,
        (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isDownloaded = filePath != null;
        });

        if (filePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Téléchargement terminé')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _deleteCourse() async {
    final success = await _downloadService.deleteCourseFile(widget.course.id);
    if (mounted) {
      setState(() {
        _isDownloaded = !success;
      });
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cours supprimé')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDownloading) {
      return Column(
        children: [
          CircularProgressIndicator(value: _progress),
          Text('${(_progress * 100).toStringAsFixed(0)}%'),
        ],
      );
    }

    if (_isDownloaded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteCourse,
            tooltip: 'Supprimer',
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () async {
              if (widget.course.filePath != null) {
                await OpenFile.open(widget.course.filePath!);
              }
            },
            tooltip: 'Ouvrir',
          ),
        ],
      );
    }

    return IconButton(
      icon: const Icon(Icons.download),
      onPressed: _downloadCourse,
      tooltip: 'Télécharger',
    );
  }
}
