// lib/models/question_model.dart
import 'package:flutter/material.dart';

enum QuestionType {
  singleChoice('בחירה יחידה', Icons.radio_button_checked),
  multipleChoice('בחירה מרובה', Icons.check_box),
  number('מספר', Icons.numbers),
  slider('מחוון', Icons.tune),
  scale('סולם דירוג', Icons.star_rate),
  text('טקסט חופשי', Icons.text_fields),
  dropdown('תפריט נפתח', Icons.arrow_drop_down),
  date('תאריך', Icons.calendar_today),
  time('שעה', Icons.access_time),
  image('בחירת תמונה', Icons.image),
  yesNo('כן/לא', Icons.check_circle),
  rating('דירוג כוכבים', Icons.star),
  range('טווח ערכים', Icons.linear_scale),
  color('בחירת צבע', Icons.color_lens),
  file('העלאת קובץ', Icons.attach_file);

  const QuestionType(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}

enum QuestionCategory {
  personal('אישי', Icons.person, Color(0xFF2196F3)),
  fitness('כושר', Icons.fitness_center, Color(0xFF4CAF50)),
  health('בריאות', Icons.favorite, Color(0xFFF44336)),
  nutrition('תזונה', Icons.restaurant, Color(0xFFFF9800)),
  goals('מטרות', Icons.flag, Color(0xFF9C27B0)),
  preferences('העדפות', Icons.settings, Color(0xFF607D8B)),
  experience('ניסיון', Icons.timeline, Color(0xFF795548)),
  equipment('ציוד', Icons.build, Color(0xFF3F51B5)),
  schedule('לוח זמנים', Icons.schedule, Color(0xFF009688)),
  medical('רפואי', Icons.local_hospital, Color(0xFFE91E63));

  const QuestionCategory(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}

enum ValidationRule {
  required('שדה חובה'),
  email('כתובת אימייל תקינה'),
  phone('מספר טלפון תקין'),
  minLength('אורך מינימלי'),
  maxLength('אורך מקסימלי'),
  positiveNumber('מספר חיובי'),
  integerOnly('מספר שלם בלבד'),
  dateRange('טווח תאריכים'),
  uniqueValues('ערכים ייחודיים'),
  custom('בדיקה מותאמת אישית');

  const ValidationRule(this.description);
  final String description;
}

class QuestionAnswer {
  final String questionId;
  final dynamic value;
  final DateTime answeredAt;
  final bool isValid;
  final String? errorMessage;

  QuestionAnswer({
    required this.questionId,
    required this.value,
    required this.answeredAt,
    this.isValid = true,
    this.errorMessage,
  });

  QuestionAnswer copyWith({
    String? questionId,
    dynamic value,
    DateTime? answeredAt,
    bool? isValid,
    String? errorMessage,
  }) {
    return QuestionAnswer(
      questionId: questionId ?? this.questionId,
      value: value ?? this.value,
      answeredAt: answeredAt ?? this.answeredAt,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'value': value,
      'answeredAt': answeredAt.toIso8601String(),
      'isValid': isValid,
      'errorMessage': errorMessage,
    };
  }

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionAnswer(
      questionId: json['questionId'] as String,
      value: json['value'],
      answeredAt: DateTime.parse(json['answeredAt'] as String),
      isValid: json['isValid'] as bool? ?? true,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

class QuestionOption {
  final String value;
  final String displayText;
  final String? description;
  final IconData? icon;
  final Color? color;
  final bool isRecommended;
  final bool isDefault;
  final Map<String, dynamic>? metadata;
  final String? imageUrl;
  final List<String>? tags;

  QuestionOption({
    required this.value,
    required this.displayText,
    this.description,
    this.icon,
    this.color,
    this.isRecommended = false,
    this.isDefault = false,
    this.metadata,
    this.imageUrl,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'displayText': displayText,
      'description': description,
      'icon': icon?.codePoint,
      'color': color?.value,
      'isRecommended': isRecommended,
      'isDefault': isDefault,
      'metadata': metadata,
      'imageUrl': imageUrl,
      'tags': tags,
    };
  }

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      value: json['value'] as String,
      displayText: json['displayText'] as String,
      description: json['description'] as String?,
      icon: json['icon'] != null
          ? IconData(json['icon'], fontFamily: 'MaterialIcons')
          : null,
      color: json['color'] != null ? Color(json['color']) : null,
      isRecommended: json['isRecommended'] as bool? ?? false,
      isDefault: json['isDefault'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  @override
  String toString() =>
      'QuestionOption(value: $value, displayText: $displayText)';
}

class QuestionValidation {
  final bool isRequired;
  final int? minSelections;
  final int? maxSelections;
  final num? minValue;
  final num? maxValue;
  final int? minLength;
  final int? maxLength;
  final String? pattern; // Regex pattern
  final List<ValidationRule> rules;
  final String? Function(dynamic)? customValidator;
  final Map<String, dynamic>? validationMetadata;

  QuestionValidation({
    this.isRequired = false,
    this.minSelections,
    this.maxSelections,
    this.minValue,
    this.maxValue,
    this.minLength,
    this.maxLength,
    this.pattern,
    this.rules = const [],
    this.customValidator,
    this.validationMetadata,
  });

  String? validate(dynamic value) {
    // Check if required
    if (isRequired && (value == null || value.toString().trim().isEmpty)) {
      return 'שדה זה הוא חובה';
    }

    if (value == null) return null;

    // Check min/max selections for lists
    if (value is List) {
      if (minSelections != null && value.length < minSelections!) {
        return 'יש לבחור לפחות $minSelections אפשרויות';
      }
      if (maxSelections != null && value.length > maxSelections!) {
        return 'ניתן לבחור עד $maxSelections אפשרויות בלבד';
      }
    }

    // Check numeric values
    if (value is num) {
      if (minValue != null && value < minValue!) {
        return 'הערך חייב להיות לפחות $minValue';
      }
      if (maxValue != null && value > maxValue!) {
        return 'הערך חייב להיות עד $maxValue';
      }
    }

    // Check string length
    if (value is String) {
      if (minLength != null && value.length < minLength!) {
        return 'הטקסט חייב להכיל לפחות $minLength תווים';
      }
      if (maxLength != null && value.length > maxLength!) {
        return 'הטקסט חייב להכיל עד $maxLength תווים';
      }

      // Check pattern
      if (pattern != null && !RegExp(pattern!).hasMatch(value)) {
        return 'הפורמט לא תקין';
      }

      // Check validation rules
      for (final rule in rules) {
        final error = _validateRule(rule, value);
        if (error != null) return error;
      }
    }

    // Custom validation
    if (customValidator != null) {
      return customValidator!(value);
    }

    return null;
  }

  String? _validateRule(ValidationRule rule, String value) {
    switch (rule) {
      case ValidationRule.email:
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'כתובת אימייל לא תקינה';
        }
        break;
      case ValidationRule.phone:
        if (!RegExp(r'^\+?[0-9]{9,15}$')
            .hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
          return 'מספר טלפון לא תקין';
        }
        break;
      case ValidationRule.positiveNumber:
        final num? number = num.tryParse(value);
        if (number == null || number <= 0) {
          return 'חייב להיות מספר חיובי';
        }
        break;
      case ValidationRule.integerOnly:
        if (int.tryParse(value) == null) {
          return 'חייב להיות מספר שלם';
        }
        break;
      default:
        break;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'isRequired': isRequired,
      'minSelections': minSelections,
      'maxSelections': maxSelections,
      'minValue': minValue,
      'maxValue': maxValue,
      'minLength': minLength,
      'maxLength': maxLength,
      'pattern': pattern,
      'rules': rules.map((r) => r.name).toList(),
      'validationMetadata': validationMetadata,
    };
  }

  factory QuestionValidation.fromJson(Map<String, dynamic> json) {
    return QuestionValidation(
      isRequired: json['isRequired'] as bool? ?? false,
      minSelections: json['minSelections'] as int?,
      maxSelections: json['maxSelections'] as int?,
      minValue: json['minValue'] as num?,
      maxValue: json['maxValue'] as num?,
      minLength: json['minLength'] as int?,
      maxLength: json['maxLength'] as int?,
      pattern: json['pattern'] as String?,
      rules: (json['rules'] as List?)
              ?.map((r) =>
                  ValidationRule.values.firstWhere((rule) => rule.name == r))
              .toList() ??
          [],
      validationMetadata: json['validationMetadata'] as Map<String, dynamic>?,
    );
  }
}

class QuestionDependency {
  final String questionId;
  final String operand; // equals, not_equals, contains, greater_than, etc.
  final dynamic value;
  final bool showIfTrue;

  QuestionDependency({
    required this.questionId,
    required this.operand,
    required this.value,
    this.showIfTrue = true,
  });

  bool evaluate(Map<String, dynamic> answers) {
    final answer = answers[questionId];
    if (answer == null) return !showIfTrue;

    bool result = false;
    switch (operand) {
      case 'equals':
        result = answer == value;
        break;
      case 'not_equals':
        result = answer != value;
        break;
      case 'contains':
        result = answer is List
            ? answer.contains(value)
            : answer.toString().contains(value.toString());
        break;
      case 'greater_than':
        result = (answer is num && value is num) ? answer > value : false;
        break;
      case 'less_than':
        result = (answer is num && value is num) ? answer < value : false;
        break;
      case 'not_empty':
        result = answer.toString().trim().isNotEmpty;
        break;
      default:
        result = false;
    }

    return showIfTrue ? result : !result;
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'operand': operand,
      'value': value,
      'showIfTrue': showIfTrue,
    };
  }

  factory QuestionDependency.fromJson(Map<String, dynamic> json) {
    return QuestionDependency(
      questionId: json['questionId'] as String,
      operand: json['operand'] as String,
      value: json['value'],
      showIfTrue: json['showIfTrue'] as bool? ?? true,
    );
  }
}

class Question {
  final String id;
  final String title;
  final String? subtitle;
  final String? explanation;
  final String? helpText;
  final QuestionType type;
  final QuestionCategory category;
  final bool isRequired;
  final IconData? icon;
  final Color? color;
  final List<QuestionOption> options;
  final QuestionValidation? validation;
  final List<QuestionDependency> dependencies;
  final Map<String, dynamic>? metadata;
  final int order;
  final bool isEnabled;
  final dynamic defaultValue;
  final String? placeholder;
  final bool allowOther; // Allow "Other" option
  final int? maxFileSize; // For file uploads
  final List<String>? allowedFileTypes;

  Question({
    required this.id,
    required this.title,
    this.subtitle,
    this.explanation,
    this.helpText,
    required this.type,
    this.category = QuestionCategory.personal,
    this.isRequired = false,
    this.icon,
    this.color,
    this.options = const [],
    this.validation,
    this.dependencies = const [],
    this.metadata,
    this.order = 0,
    this.isEnabled = true,
    this.defaultValue,
    this.placeholder,
    this.allowOther = false,
    this.maxFileSize,
    this.allowedFileTypes,
  });

  bool shouldShow(Map<String, dynamic> answers) {
    if (dependencies.isEmpty) return true;
    return dependencies.every((dep) => dep.evaluate(answers));
  }

  String? validate(dynamic value) {
    return validation?.validate(value);
  }

  bool get hasOptions => options.isNotEmpty;
  bool get hasIcon => icon != null;
  bool get hasHelp => helpText != null || explanation != null;

  List<QuestionOption> get defaultOptions {
    return options.where((opt) => opt.isDefault).toList();
  }

  List<QuestionOption> get recommendedOptions {
    return options.where((opt) => opt.isRecommended).toList();
  }

  Question copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? explanation,
    String? helpText,
    QuestionType? type,
    QuestionCategory? category,
    bool? isRequired,
    IconData? icon,
    Color? color,
    List<QuestionOption>? options,
    QuestionValidation? validation,
    List<QuestionDependency>? dependencies,
    Map<String, dynamic>? metadata,
    int? order,
    bool? isEnabled,
    dynamic defaultValue,
    String? placeholder,
    bool? allowOther,
    int? maxFileSize,
    List<String>? allowedFileTypes,
  }) {
    return Question(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      explanation: explanation ?? this.explanation,
      helpText: helpText ?? this.helpText,
      type: type ?? this.type,
      category: category ?? this.category,
      isRequired: isRequired ?? this.isRequired,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      options: options ?? this.options,
      validation: validation ?? this.validation,
      dependencies: dependencies ?? this.dependencies,
      metadata: metadata ?? this.metadata,
      order: order ?? this.order,
      isEnabled: isEnabled ?? this.isEnabled,
      defaultValue: defaultValue ?? this.defaultValue,
      placeholder: placeholder ?? this.placeholder,
      allowOther: allowOther ?? this.allowOther,
      maxFileSize: maxFileSize ?? this.maxFileSize,
      allowedFileTypes: allowedFileTypes ?? this.allowedFileTypes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'explanation': explanation,
      'helpText': helpText,
      'type': type.name,
      'category': category.name,
      'isRequired': isRequired,
      'icon': icon?.codePoint,
      'color': color?.value,
      'options': options.map((opt) => opt.toJson()).toList(),
      'validation': validation?.toJson(),
      'dependencies': dependencies.map((dep) => dep.toJson()).toList(),
      'metadata': metadata,
      'order': order,
      'isEnabled': isEnabled,
      'defaultValue': defaultValue,
      'placeholder': placeholder,
      'allowOther': allowOther,
      'maxFileSize': maxFileSize,
      'allowedFileTypes': allowedFileTypes,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      explanation: json['explanation'] as String?,
      helpText: json['helpText'] as String?,
      type: QuestionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => QuestionType.text,
      ),
      category: QuestionCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => QuestionCategory.personal,
      ),
      isRequired: json['isRequired'] as bool? ?? false,
      icon: json['icon'] != null
          ? IconData(json['icon'], fontFamily: 'MaterialIcons')
          : null,
      color: json['color'] != null ? Color(json['color']) : null,
      options: (json['options'] as List?)
              ?.map((opt) => QuestionOption.fromJson(opt))
              .toList() ??
          [],
      validation: json['validation'] != null
          ? QuestionValidation.fromJson(json['validation'])
          : null,
      dependencies: (json['dependencies'] as List?)
              ?.map((dep) => QuestionDependency.fromJson(dep))
              .toList() ??
          [],
      metadata: json['metadata'] as Map<String, dynamic>?,
      order: json['order'] as int? ?? 0,
      isEnabled: json['isEnabled'] as bool? ?? true,
      defaultValue: json['defaultValue'],
      placeholder: json['placeholder'] as String?,
      allowOther: json['allowOther'] as bool? ?? false,
      maxFileSize: json['maxFileSize'] as int?,
      allowedFileTypes: json['allowedFileTypes'] != null
          ? List<String>.from(json['allowedFileTypes'])
          : null,
    );
  }

  // Factory methods for common question types
  factory Question.yesNo({
    required String id,
    required String title,
    String? subtitle,
    bool isRequired = false,
    QuestionCategory category = QuestionCategory.personal,
  }) {
    return Question(
      id: id,
      title: title,
      subtitle: subtitle,
      type: QuestionType.yesNo,
      category: category,
      isRequired: isRequired,
      icon: Icons.help_outline,
      options: [
        QuestionOption(value: 'yes', displayText: 'כן', icon: Icons.check),
        QuestionOption(value: 'no', displayText: 'לא', icon: Icons.close),
      ],
    );
  }

  factory Question.multipleChoice({
    required String id,
    required String title,
    required List<QuestionOption> options,
    String? subtitle,
    bool isRequired = false,
    QuestionCategory category = QuestionCategory.personal,
    int? maxSelections,
  }) {
    return Question(
      id: id,
      title: title,
      subtitle: subtitle,
      type: QuestionType.multipleChoice,
      category: category,
      isRequired: isRequired,
      options: options,
      validation: QuestionValidation(
        isRequired: isRequired,
        maxSelections: maxSelections,
      ),
    );
  }

  factory Question.slider({
    required String id,
    required String title,
    required double min,
    required double max,
    String? subtitle,
    bool isRequired = false,
    QuestionCategory category = QuestionCategory.personal,
    double? defaultValue,
  }) {
    return Question(
      id: id,
      title: title,
      subtitle: subtitle,
      type: QuestionType.slider,
      category: category,
      isRequired: isRequired,
      defaultValue: defaultValue ?? min,
      validation: QuestionValidation(
        isRequired: isRequired,
        minValue: min,
        maxValue: max,
      ),
    );
  }

  factory Question.text({
    required String id,
    required String title,
    String? subtitle,
    String? placeholder,
    bool isRequired = false,
    QuestionCategory category = QuestionCategory.personal,
    int? maxLength,
    List<ValidationRule>? rules,
  }) {
    return Question(
      id: id,
      title: title,
      subtitle: subtitle,
      placeholder: placeholder,
      type: QuestionType.text,
      category: category,
      isRequired: isRequired,
      validation: QuestionValidation(
        isRequired: isRequired,
        maxLength: maxLength,
        rules: rules ?? [],
      ),
    );
  }

  @override
  String toString() =>
      'Question(id: $id, title: $title, type: ${type.displayName})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
