import 'package:flutter/material.dart';
import 'package:gymovo_app/models/question_model.dart';
import 'question_header_widget.dart';
import 'question_single_choice_widget.dart';
import 'question_multiple_choice_widget.dart';
import 'question_number_input_widget.dart';
import 'question_slider_widget.dart';
import 'question_scale_widget.dart';
import 'question_text_input_widget.dart';

class QuestionWidgetFactory {
  static Widget buildQuestion({
    required Question question,
    required Map<String, dynamic> answers,
    required Function(String questionId, dynamic value) onAnswerChanged,
    TextEditingController? controller,
    FocusNode? focusNode,
  }) {
    switch (question.type) {
      case QuestionType.singleChoice:
        return SingleChoiceQuestionWidget(
          question: question,
          selectedValue: answers[question.id],
          onChanged: (value) => onAnswerChanged(question.id, value),
        );
      case QuestionType.multipleChoice:
        return MultipleChoiceQuestionWidget(
          question: question,
          selectedValues: answers[question.id] ?? [],
          onChanged: (values) => onAnswerChanged(question.id, values),
        );
      case QuestionType.number:
        return NumberInputQuestionWidget(
          question: question,
          controller: controller,
          focusNode: focusNode,
          onChanged: (value) => onAnswerChanged(question.id, value),
        );
      case QuestionType.slider:
        return SliderQuestionWidget(
          question: question,
          value: answers[question.id],
          controller: controller,
          onChanged: (value) => onAnswerChanged(question.id, value),
        );
      case QuestionType.scale:
        return ScaleQuestionWidget(
          question: question,
          selectedValue: answers[question.id],
          onChanged: (value) => onAnswerChanged(question.id, value),
        );
      case QuestionType.text:
        return TextInputQuestionWidget(
          question: question,
          controller: controller,
          focusNode: focusNode,
          onChanged: (value) => onAnswerChanged(question.id, value),
        );
      case QuestionType.dropdown:
        // For now, treat dropdown as single choice
        return SingleChoiceQuestionWidget(
          question: question,
          selectedValue: answers[question.id],
          onChanged: (value) => onAnswerChanged(question.id, value),
        );
      case QuestionType.date:
        // For now, treat date as text input
        return TextInputQuestionWidget(
          question: question,
          controller: controller,
          focusNode: focusNode,
          onChanged: (value) => onAnswerChanged(question.id, value),
        );
      default:
        // Handle any other question types as text input for now
        return TextInputQuestionWidget(
          question: question,
          controller: controller,
          focusNode: focusNode,
          onChanged: (value) => onAnswerChanged(question.id, value),
        );
    }
    throw UnimplementedError('Unknown question type: ${question.type}');
  }
}
