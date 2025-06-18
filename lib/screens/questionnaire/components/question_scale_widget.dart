// lib/screens/questionnaire/components/question_scale_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymovo_app/models/question_model.dart';
import 'package:gymovo_app/theme/app_theme.dart';
import 'question_header_widget.dart';

class ScaleQuestionWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final validation = question.validation;
    final minValue = validation?.minValue ?? 1;
    final maxValue = validation?.maxValue ?? 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionHeaderWidget(question: question),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(maxValue - minValue + 1, (index) {
            final value = minValue + index;
            final isSelected = selectedValue == value;

            return GestureDetector(
              onTap: () {
                onChanged(value);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : colors.surface,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? colors.primary
                        : colors.text.withOpacity(0.3),
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    value.toString(),
                    style: GoogleFonts.assistant(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : colors.text,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'נמוך',
              style: GoogleFonts.assistant(
                fontSize: 12,
                color: colors.text.withOpacity(0.6),
              ),
            ),
            Text(
              'גבוה',
              style: GoogleFonts.assistant(
                fontSize: 12,
                color: colors.text.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
