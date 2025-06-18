// lib/screens/questionnaire/components/question_multiple_choice_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymovo_app/models/question_model.dart';
import 'package:gymovo_app/theme/app_theme.dart';
import 'question_header_widget.dart';

class MultipleChoiceQuestionWidget extends StatelessWidget {
  final Question question;
  final List<String> selectedValues;
  final Function(List<String>) onChanged;

  const MultipleChoiceQuestionWidget({
    super.key,
    required this.question,
    required this.selectedValues,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final maxSelections = question.validation?.maxSelections;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionHeaderWidget(question: question),
        if (maxSelections != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'בחר עד $maxSelections אפשרויות',
              style: GoogleFonts.assistant(
                fontSize: 12,
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: question.options.map((option) {
            final isSelected = selectedValues.contains(option.value);
            final canSelect = isSelected ||
                maxSelections == null ||
                selectedValues.length < maxSelections;

            return AnimatedScale(
              scale: isSelected ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (option.icon != null) ...[
                      Icon(
                        option.icon!,
                        size: 16,
                        color: isSelected ? Colors.white : colors.primary,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      option.displayText,
                      style: GoogleFonts.assistant(
                        color: isSelected ? Colors.white : colors.text,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                selectedColor: colors.primary,
                backgroundColor: colors.surface,
                disabledColor: colors.surface.withOpacity(0.5),
                checkmarkColor: Colors.white,
                elevation: isSelected ? 4 : 1,
                pressElevation: 8,
                side: BorderSide(
                  color: isSelected
                      ? colors.primary
                      : colors.text.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
                onSelected: canSelect
                    ? (selected) {
                        HapticFeedback.selectionClick();
                        final newValues = List<String>.from(selectedValues);
                        if (selected) {
                          newValues.add(option.value);
                        } else {
                          newValues.remove(option.value);
                        }
                        onChanged(newValues);
                      }
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
