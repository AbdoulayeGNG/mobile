import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  final Duration initialPosition;
  final Function(Duration position, Duration duration) onProgressChanged;

  const VideoPlayerWidget({
    Key? key,
    required this.videoPath,
    required this.initialPosition,
    required this.onProgressChanged,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {    _videoPlayerController = VideoPlayerController.file(
      File(widget.videoPath),
    );

    try {
      await _videoPlayerController!.initialize();
      
      if (widget.initialPosition > Duration.zero) {
        await _videoPlayerController!.seekTo(widget.initialPosition);
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowPlaybackSpeedChanging: true,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );

      // Mettre à jour la progression toutes les secondes
      _videoPlayerController!.addListener(_onProgressUpdate);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation du lecteur vidéo: $e');
    }
  }

  void _onProgressUpdate() {
    if (_videoPlayerController != null && 
        _videoPlayerController!.value.isInitialized &&
        _videoPlayerController!.value.isPlaying) {
      widget.onProgressChanged(
        _videoPlayerController!.value.position,
        _videoPlayerController!.value.duration,
      );
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_onProgressUpdate);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _isInitialized && _chewieController != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Chewie(controller: _chewieController!),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
