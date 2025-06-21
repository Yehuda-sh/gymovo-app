// lib/screens/questionnaire/components/question_scale_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymovo_app/models/question_model.dart';
import 'package:gymovo_app/theme/app_theme.dart';
import 'question_header_widget.dart';

class ScaleQuestionWidget extends StatefulWidget {
  final Question question;
  final int? selectedValue;
  final Function(int) onChanged;

  const ScaleQuestionWidget({
    super.key,
    required this.question,
    this.selectedValue,
    required this.onChanged,
  });

  @override
  State<ScaleQuestionWidget> createState() => _ScaleQuestionWidgetState();
}

class _ScaleQuestionWidgetState extends State<ScaleQuestionWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int? _previousValue;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didUpdateWidget(ScaleQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != _previousValue) {
      _previousValue = widget.selectedValue;
      if (widget.selectedValue != null) {
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final validation = widget.question.validation;
    final minValue = validation?.minValue ?? 1;
    final maxValue = validation?.maxValue ?? 5;
    final range = maxValue - minValue + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionHeaderWidget(question: widget.question),
        const SizedBox(height: 24),
        _buildScaleWidget(
            colors, minValue.toInt(), maxValue.toInt(), range.toInt()),
        const SizedBox(height: 16),
        _buildLabels(colors, minValue.toInt(), maxValue.toInt()),
        if (widget.selectedValue != null) ...[
          const SizedBox(height: 16),
          _buildSelectedValueIndicator(colors),
        ],
      ],
    );
  }

  Widget _buildScaleWidget(
    dynamic colors,
    int minValue,
    int maxValue,
    int range,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.text.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Scale options with better spacing
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 32) / range;
              final effectiveItemWidth = itemWidth.clamp(50.0, 70.0) as double;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(range, (index) {
                  final value = minValue + index;
                  return _buildScaleItem(
                    value: value,
                    colors: colors,
                    width: effectiveItemWidth,
                  );
                }),
              );
            },
          ),

          // Visual scale indicator
          const SizedBox(height: 20),
          _buildVisualScaleIndicator(colors, minValue, maxValue),
        ],
      ),
    );
  }

  Widget _buildScaleItem({
    required int value,
    required dynamic colors,
    required double width,
  }) {
    final isSelected = widget.selectedValue == value;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        final scale = isSelected && widget.selectedValue == value
            ? _scaleAnimation.value
            : 1.0;

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onChanged(value);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              width: width,
              height: width,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.primary,
                          colors.primary.withOpacity(0.8),
                        ],
                      )
                    : null,
                color: isSelected ? null : colors.background,
                borderRadius: BorderRadius.circular(width / 2),
                border: Border.all(
                  color: isSelected
                      ? colors.primary
                      : colors.text.withOpacity(0.2),
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: colors.primary.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      value.toString(),
                      style: GoogleFonts.assistant(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : colors.text,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisualScaleIndicator(
      dynamic colors, int minValue, int maxValue) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: LinearGradient(
          colors: [
            colors.text.withOpacity(0.3),
            colors.primary.withOpacity(0.5),
            colors.primary,
          ],
        ),
      ),
      child: widget.selectedValue != null
          ? LayoutBuilder(
              builder: (context, constraints) {
                final progress =
                    (widget.selectedValue! - minValue) / (maxValue - minValue);
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      left: progress * (constraints.maxWidth - 12),
                      top: -3,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildLabels(dynamic colors, int minValue, int maxValue) {
    final labels = _getScaleLabels(minValue, maxValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels['min'] ?? 'נמוך',
                  style: GoogleFonts.assistant(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.text.withOpacity(0.7),
                  ),
                ),
                Text(
                  '($minValue)',
                  style: GoogleFonts.assistant(
                    fontSize: 11,
                    color: colors.text.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          if (maxValue - minValue >= 4)
            Text(
              'בינוני',
              style: GoogleFonts.assistant(
                fontSize: 12,
                color: colors.text.withOpacity(0.6),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  labels['max'] ?? 'גבוה',
                  style: GoogleFonts.assistant(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.text.withOpacity(0.7),
                  ),
                ),
                Text(
                  '($maxValue)',
                  style: GoogleFonts.assistant(
                    fontSize: 11,
                    color: colors.text.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedValueIndicator(dynamic colors) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: widget.selectedValue != null ? 1.0 : 0.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: colors.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'נבחר: ${widget.selectedValue}',
              style: GoogleFonts.assistant(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> _getScaleLabels(int minValue, int maxValue) {
    // יכול להיות מותאם בהתאם לסוג השאלה
    final range = maxValue - minValue;

    if (range <= 2) {
      return {'min': 'לא', 'max': 'כן'};
    } else if (range <= 4) {
      return {'min': 'נמוך מאוד', 'max': 'גבוה מאוד'};
    } else {
      return {'min': 'בכלל לא', 'max': 'במידה רבה מאוד'};
    }
  }
}
