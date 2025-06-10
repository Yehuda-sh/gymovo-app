import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../models/exercise.dart';

class ExerciseMediaSection extends StatefulWidget {
  final Exercise exercise;

  const ExerciseMediaSection({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  @override
  State<ExerciseMediaSection> createState() => _ExerciseMediaSectionState();
}

class _ExerciseMediaSectionState extends State<ExerciseMediaSection> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (widget.exercise.videoUrl != null &&
        widget.exercise.videoUrl!.isNotEmpty) {
      _videoController =
          VideoPlayerController.network(widget.exercise.videoUrl!);
      await _videoController!.initialize();

      if (mounted) {
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: false,
          looping: true,
          aspectRatio: _videoController!.value.aspectRatio,
          placeholder: Container(
            color: Colors.black12,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Container(
              color: Colors.black12,
              child: const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 42,
                ),
              ),
            );
          },
        );
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exercise.imageUrl != null &&
        widget.exercise.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: CachedNetworkImage(
          imageUrl: widget.exercise.imageUrl!,
          height: 190,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (ctx, url) => Container(
            height: 190,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (ctx, url, error) => Container(
            height: 190,
            color: Colors.grey[200],
            child: const Icon(Icons.image_not_supported, size: 54),
          ),
        ),
      );
    }

    if (widget.exercise.videoUrl != null &&
        widget.exercise.videoUrl!.isNotEmpty) {
      if (_chewieController != null &&
          _chewieController!.videoPlayerController.value.isInitialized) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: _chewieController!.aspectRatio ?? 16 / 9,
            child: Chewie(controller: _chewieController!),
          ),
        );
      } else {
        return Container(
          height: 190,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    }

    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.grey[100],
      ),
      child: const Center(
        child: Icon(Icons.fitness_center, size: 60, color: Colors.blueGrey),
      ),
    );
  }
}
