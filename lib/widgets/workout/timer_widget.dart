// lib/widgets/timer_widget.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class TimerWidget extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onComplete;
  final bool isActive;

  const TimerWidget({
    super.key,
    required this.initialSeconds,
    required this.onComplete,
    this.isActive = true,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;
  late int _remainingSeconds;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    if (widget.isActive) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (!_isPaused && _remainingSeconds > 0) {
          _remainingSeconds--;
        }
        if (_remainingSeconds == 0) {
          timer.cancel();
          widget.onComplete();
        }
      });
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _timer?.cancel();
      } else {
        _startTimer();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.97),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.primary.withAlpha(46),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'זמן מנוחה',
            style: GoogleFonts.assistant(
              fontSize: 17,
              color: colors.primary.withOpacity(0.93),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(_remainingSeconds),
            style: GoogleFonts.assistant(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: colors.headline,
              letterSpacing: 1.5,
            ),
          ),
          if (widget.isActive) ...[
            const SizedBox(height: 14),
            IconButton(
              tooltip: _isPaused ? 'הפעל טיימר' : 'השהה טיימר',
              onPressed: _togglePause,
              icon: Icon(
                _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: colors.primary,
                size: 36,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
