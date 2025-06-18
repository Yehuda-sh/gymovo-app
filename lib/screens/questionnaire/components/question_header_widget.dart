// lib/screens/questionnaire/components/question_header_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymovo_app/theme/app_theme.dart';
import 'package:gymovo_app/models/question_model.dart';

class QuestionHeaderWidget extends StatelessWidget {
  final Question question;
  final bool isRequired;

  const QuestionHeaderWidget({
    super.key,
    required this.question,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (question.icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  question.icon!,
                  color: colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          question.title,
                          style: GoogleFonts.assistant(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ),
                      ),
                      if (isRequired && question.isRequired)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'חובה',
                            style: GoogleFonts.assistant(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colors.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (question.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      question.subtitle!,
                      style: GoogleFonts.assistant(
                        fontSize: 14,
                        color: colors.text.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (question.explanation != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colors.primary.withOpacity(0.1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: colors.primary.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question.explanation!,
                    style: GoogleFonts.assistant(
                      fontSize: 13,
                      color: colors.text.withOpacity(0.8),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
