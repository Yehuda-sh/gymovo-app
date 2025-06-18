// lib/screens/questionnaire/components/question_text_input_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymovo_app/models/question_model.dart';
import 'package:gymovo_app/theme/app_theme.dart';
import 'question_header_widget.dart';

class TextInputQuestionWidget extends StatelessWidget {
  final Question question;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function(String) onChanged;

  const TextInputQuestionWidget({
    super.key,
    required this.question,
    this.controller,
    this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionHeaderWidget(question: question),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: question.metadata?['multiline'] == true ? 3 : 1,
            style: GoogleFonts.assistant(
              color: colors.text,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: question.metadata?['placeholder'] ?? 'הכנס תשובה...',
              prefixIcon: Icon(
                question.icon ?? Icons.text_fields,
                color: colors.primary,
              ),
              hintStyle: GoogleFonts.assistant(
                color: colors.text.withOpacity(0.5),
              ),
              filled: true,
              fillColor: Colors.transparent,
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
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
