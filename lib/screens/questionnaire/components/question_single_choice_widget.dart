// lib/screens/questionnaire/components/question_single_choice_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymovo_app/models/question_model.dart';
import 'package:gymovo_app/theme/app_theme.dart';
import 'question_header_widget.dart';

class SingleChoiceQuestionWidget extends StatelessWidget {
  final Question question;
  final String? selectedValue;
  final Function(String?) onChanged;

  const SingleChoiceQuestionWidget({
    super.key,
    required this.question,
    this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // כותרת השאלה
        QuestionHeaderWidget(question: question),
        const SizedBox(height: 16),

        // אפשרויות לבחירה (צ'יפים)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: question.options.map((option) {
            final isSelected = selectedValue == option.value;
            final isRecommended = option.isRecommended;

            return Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: FilterChip(
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (option.icon != null) ...[
                          Icon(
                            option.icon!,
                            size: 20,
                            color: isSelected ? Colors.white : colors.primary,
                          ),
                          const SizedBox(height: 4),
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
                        if (option.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            option.description!,
                            style: GoogleFonts.assistant(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : colors.text.withOpacity(0.6),
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: colors.primary,
                    backgroundColor: isRecommended
                        ? colors.primary.withOpacity(0.1)
                        : colors.surface,
                    checkmarkColor: Colors.white,
                    elevation: isSelected ? 4 : 1,
                    pressElevation: 8,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? colors.primary
                          : isRecommended
                              ? colors.primary.withOpacity(0.3)
                              : colors.text.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      onChanged(option.value);
                    },
                  ),
                ),
                if (isRecommended && !isSelected)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        'מומלץ',
                        style: GoogleFonts.assistant(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
