import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../models/exercise.dart';
import '../../theme/app_theme.dart';

class ExerciseInfo extends StatefulWidget {
  final Exercise exercise;
  final int currentSet;
  final int totalSets;

  const ExerciseInfo({
    super.key,
    required this.exercise,
    required this.currentSet,
    required this.totalSets,
  });

  @override
  State<ExerciseInfo> createState() => _ExerciseInfoState();
}

class _ExerciseInfoState extends State<ExerciseInfo> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _preloadMedia();
  }

  Future<void> _preloadMedia() async {
    setState(() => _isLoading = true);

    // Preload image if exists
    if (widget.exercise.imageUrl != null &&
        widget.exercise.imageUrl!.isNotEmpty) {
      precacheImage(NetworkImage(widget.exercise.imageUrl!), context);
    }

    // Initialize video if exists
    if (widget.exercise.videoUrl != null &&
        widget.exercise.videoUrl!.isNotEmpty) {
      await _initializeVideo();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.network(widget.exercise.videoUrl!);
    try {
      await _videoController!.initialize();
      // Pre-buffer the video
      await _videoController!.setLooping(true);
      await _videoController!.setVolume(0.0);
      await _videoController!.play();
      await Future.delayed(const Duration(seconds: 1));
      await _videoController!.pause();
      await _videoController!.seekTo(Duration.zero);

      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void didUpdateWidget(ExerciseInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.id != widget.exercise.id) {
      // Stop video when changing exercises
      _videoController?.pause();
      _videoController?.seekTo(Duration.zero);
      _preloadMedia();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _showFullScreenVideo() {
    if (_videoController == null || !_isVideoInitialized) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      _videoController?.pause();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _videoController!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 50,
                        ),
                        onPressed: () {
                          setState(() {
                            _videoController!.value.isPlaying
                                ? _videoController!.pause()
                                : _videoController!.play();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    if (_isLoading) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (widget.exercise.videoUrl != null &&
        widget.exercise.videoUrl!.isNotEmpty &&
        _isVideoInitialized) {
      return GestureDetector(
        onTap: _showFullScreenVideo,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_circle_outline,
                        color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'לחץ למסך מלא',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (widget.exercise.imageUrl != null &&
        widget.exercise.imageUrl!.isNotEmpty) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              widget.exercise.imageUrl!,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
          if (widget.exercise.videoUrl != null &&
              widget.exercise.videoUrl!.isNotEmpty)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'וידאו זמין',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  String _getMuscleEmoji(String muscle) {
    switch (muscle.toLowerCase()) {
      case 'chest':
        return '💪';
      case 'back':
        return '🦾';
      case 'legs':
        return '🦵';
      case 'shoulders':
        return '👔';
      case 'arms':
        return '💪';
      case 'core':
        return '🎯';
      default:
        return '💪';
    }
  }

  Color _getMuscleColor(String muscle) {
    switch (muscle.toLowerCase()) {
      case 'chest':
        return Colors.blue.withOpacity(0.2);
      case 'back':
        return Colors.green.withOpacity(0.2);
      case 'legs':
        return Colors.purple.withOpacity(0.2);
      case 'shoulders':
        return Colors.orange.withOpacity(0.2);
      case 'arms':
        return Colors.red.withOpacity(0.2);
      case 'core':
        return Colors.teal.withOpacity(0.2);
      default:
        return AppTheme.colors.primary.withOpacity(0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.colors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMediaSection(),
          if (widget.exercise.videoUrl != null &&
                  widget.exercise.videoUrl!.isNotEmpty ||
              widget.exercise.imageUrl != null &&
                  widget.exercise.imageUrl!.isNotEmpty)
            const SizedBox(height: 16),
          Text(
            widget.exercise.nameHe,
            style: GoogleFonts.assistant(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.exercise.instructionsHe.join('\n'),
            style: GoogleFonts.assistant(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                icon: Icons.fitness_center,
                label: widget.exercise.mainMuscles.first,
                emoji: _getMuscleEmoji(widget.exercise.mainMuscles.first),
                backgroundColor:
                    _getMuscleColor(widget.exercise.mainMuscles.first),
              ),
              _buildInfoChip(
                icon: Icons.repeat,
                label: '${widget.currentSet}/${widget.totalSets} סטים',
              ),
              _buildInfoChip(
                icon: Icons.sports_gymnastics,
                label: widget.exercise.equipment.join(", "),
              ),
              _buildInfoChip(
                icon: Icons.trending_up,
                label: widget.exercise.equipment.join(", "),
              ),
            ],
          ),
          if (widget.totalSets > 1) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: widget.currentSet / widget.totalSets,
              backgroundColor: Colors.white12,
              color: AppTheme.colors.primary,
              minHeight: 4,
            ),
          ],
          if (widget.exercise.secondaryMuscles?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            Text(
              'שרירים משניים:',
              style: GoogleFonts.assistant(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.exercise.secondaryMuscles?.map((muscle) {
                    return _buildInfoChip(
                      icon: Icons.fitness_center,
                      label: muscle,
                      emoji: _getMuscleEmoji(muscle),
                      backgroundColor: _getMuscleColor(muscle).withOpacity(0.1),
                      isSmall: true,
                    );
                  }).toList() ??
                  [],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    String? emoji,
    Color? backgroundColor,
    bool isSmall = false,
  }) {
    return Tooltip(
      message: label,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 8 : 12,
          vertical: isSmall ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.colors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.colors.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji, style: TextStyle(fontSize: isSmall ? 12 : 15)),
              const SizedBox(width: 3),
            ],
            Icon(
              icon,
              size: isSmall ? 14 : 16,
              color: AppTheme.colors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.assistant(
                fontSize: isSmall ? 12 : 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
