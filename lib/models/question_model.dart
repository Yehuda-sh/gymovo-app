// lib/models/question_model.dart

import 'package:flutter/material.dart';

enum QuestionType {
  singleChoice,
  multipleChoice,
  number,
  slider,
  scale,
  text,
}

class Question {
  final String id;
  final String title;
  final String? subtitle;
  final String? explanation;
  final QuestionType type;
  final bool isRequired;
  final IconData? icon;
  final List<QuestionOption> options;
  final QuestionValidation? validation;
  final Map<String, dynamic>? metadata;

  Question({
    required this.id,
    required this.title,
    this.subtitle,
    this.explanation,
    required this.type,
    this.isRequired = false,
    this.icon,
    this.options = const [],
    this.validation,
    this.metadata,
  });
}

class QuestionOption {
  final String value;
  final String displayText;
  final String? description;
  final IconData? icon;
  final bool isRecommended;

  QuestionOption({
    required this.value,
    required this.displayText,
    this.description,
    this.icon,
    this.isRecommended = false,
  });
}

class QuestionValidation {
  final int? minSelections;
  final int? maxSelections;
  final int? minValue;
  final int? maxValue;
  final String? Function(dynamic)? customValidator;

  QuestionValidation({
    this.minSelections,
    this.maxSelections,
    this.minValue,
    this.maxValue,
    this.customValidator,
  });
}
