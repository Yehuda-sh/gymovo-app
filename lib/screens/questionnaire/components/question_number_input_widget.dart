// lib/screens/questionnaire/components/question_number_input_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymovo_app/models/question_model.dart';
import 'package:gymovo_app/theme/app_theme.dart';
import 'question_header_widget.dart';

class NumberInputQuestionWidget extends StatelessWidget {
  final Question question;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function(int?) onChanged;

  const NumberInputQuestionWidget({
    super.key,
    required this.question,
    this.controller,
    this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final validation = question.validation;
    final unit = question.metadata?['unit'] ?? '';

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
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.assistant(
              color: colors.text,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: validation != null
                  ? '${validation.minValue}-${validation.maxValue} $unit'
                  : 'הזן ערך $unit',
              prefixIcon: Icon(
                question.icon ?? Icons.numbers,
                color: colors.primary,
              ),
              suffixText: unit.isNotEmpty ? unit : null,
              suffixStyle: GoogleFonts.assistant(
                color: colors.text.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
            ),
            onChanged: (text) {
              final val = int.tryParse(text);
              onChanged(val);
            },
          ),
        ),
        if (validation != null) ...[
          const SizedBox(height: 8),
          Text(
            'טווח תקין: ${validation.minValue}-${validation.maxValue} $unit',
            style: GoogleFonts.assistant(
              fontSize: 12,
              color: colors.text.withOpacity(0.6),
            ),
          ),
        ],
      ],
    );
  }
}
