// lib/screens/questionnaire/components/question_slider_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymovo_app/models/question_model.dart';
import 'package:gymovo_app/theme/app_theme.dart';
import 'question_header_widget.dart';

class SliderQuestionWidget extends StatefulWidget {
  final Question question;
  final int? value;
  final TextEditingController? controller;
  final Function(int) onChanged;

  const SliderQuestionWidget({
    super.key,
    required this.question,
    this.value,
    this.controller,
    required this.onChanged,
  });

  @override
  State<SliderQuestionWidget> createState() => _SliderQuestionWidgetState();
}

class _SliderQuestionWidgetState extends State<SliderQuestionWidget> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    final validation = widget.question.validation;
    final defaultValue =
        widget.value?.toDouble() ?? (validation?.minValue?.toDouble() ?? 0.0);
    _currentValue = defaultValue;

    if (widget.controller != null) {
      widget.controller!.text = _currentValue.toInt().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final validation = widget.question.validation;
    final unit = widget.question.metadata?['unit'] ?? '';

    if (validation == null) {
      return const Text('שגיאה: לא הוגדרו גבולות לסליידר');
    }

    final minValue = validation.minValue!.toDouble();
    final maxValue = validation.maxValue!.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionHeaderWidget(question: widget.question),
        const SizedBox(height: 20),

        // תצוגת הערך הנוכחי
        Hero(
          tag: '${widget.question.id}_display',
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primary.withOpacity(0.1),
                  colors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.primary.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '${_currentValue.toInt()}',
                  style: GoogleFonts.assistant(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                Text(
                  unit,
                  style: GoogleFonts.assistant(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.primary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // הסליידר
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: colors.primary,
                  inactiveTrackColor: colors.primary.withOpacity(0.2),
                  thumbColor: colors.primary,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 12),
                  overlayColor: colors.primary.withOpacity(0.2),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _currentValue.clamp(minValue, maxValue),
                  min: minValue,
                  max: maxValue,
                  divisions: (maxValue - minValue).toInt(),
                  label: '${_currentValue.toInt()} $unit',
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _currentValue = value;
                      widget.controller?.text = value.toInt().toString();
                    });
                    widget.onChanged(value.toInt());
                  },
                ),
              ),

              // תצוגת טווח
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${minValue.toInt()} $unit',
                    style: GoogleFonts.assistant(
                      fontSize: 12,
                      color: colors.text.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    '${maxValue.toInt()} $unit',
                    style: GoogleFonts.assistant(
                      fontSize: 12,
                      color: colors.text.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // שדה הזנה ידנית
        if (widget.controller != null)
          TextField(
            controller: widget.controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.assistant(
              color: colors.text,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: '${widget.question.title} ב$unit',
              hintText: 'הכנס ערך...',
              helperText:
                  'טווח תקין: ${minValue.toInt()}-${maxValue.toInt()} $unit',
              helperStyle: GoogleFonts.assistant(
                color: colors.text.withOpacity(0.6),
                fontSize: 12,
              ),
              prefixIcon: Icon(widget.question.icon, color: colors.primary),
              hintStyle: GoogleFonts.assistant(
                color: colors.text.withOpacity(0.5),
              ),
              labelStyle: GoogleFonts.assistant(
                color: colors.text.withOpacity(0.7),
              ),
              filled: true,
              fillColor: colors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colors.primary,
                  width: 2,
                ),
              ),
            ),
            onChanged: (text) {
              final val = double.tryParse(text);
              if (val != null && val >= minValue && val <= maxValue) {
                setState(() {
                  _currentValue = val;
                });
                widget.onChanged(val.toInt());
              }
            },
          ),
      ],
    );
  }
}
