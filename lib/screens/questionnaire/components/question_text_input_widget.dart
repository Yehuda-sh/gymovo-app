// lib/screens/questionnaire/components/question_text_input_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymovo_app/models/question_model.dart';
import 'package:gymovo_app/theme/app_theme.dart';
import 'question_header_widget.dart';

class TextInputQuestionWidget extends StatefulWidget {
  final Question question;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function(String) onChanged;
  final String? errorText;

  const TextInputQuestionWidget({
    super.key,
    required this.question,
    this.controller,
    this.focusNode,
    required this.onChanged,
    this.errorText,
  });

  @override
  State<TextInputQuestionWidget> createState() =>
      _TextInputQuestionWidgetState();
}

class _TextInputQuestionWidgetState extends State<TextInputQuestionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _borderColorAnimation;
  late TextEditingController _internalController;
  late FocusNode _internalFocusNode;

  bool _isFocused = false;
  String _currentText = '';

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _internalController = widget.controller ?? TextEditingController();
    _internalFocusNode = widget.focusNode ?? FocusNode();

    // Initialize current text
    _currentText = _internalController.text;

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    final colors = AppTheme.colors;
    _borderColorAnimation = ColorTween(
      begin: colors.text.withOpacity(0.2),
      end: colors.primary,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Focus listener
    _internalFocusNode.addListener(() {
      setState(() {
        _isFocused = _internalFocusNode.hasFocus;
      });

      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final validation = widget.question.validation;
    final isMultiline = widget.question.metadata?['multiline'] == true;
    final hasError = widget.errorText?.isNotEmpty == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionHeaderWidget(question: widget.question),
        const SizedBox(height: 16),

        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasError
                        ? colors.error ?? Colors.red
                        : _borderColorAnimation.value ??
                            colors.text.withOpacity(0.2),
                    width: _isFocused || hasError ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isFocused
                          ? colors.primary.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: _isFocused ? 12 : 8,
                      spreadRadius: _isFocused ? 2 : 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _internalController,
                      focusNode: _internalFocusNode,
                      maxLines: isMultiline ? null : 1,
                      minLines: isMultiline ? 3 : 1,
                      maxLength: _getMaxLength(validation),
                      keyboardType: _getKeyboardType(),
                      textInputAction: isMultiline
                          ? TextInputAction.newline
                          : TextInputAction.done,
                      inputFormatters: _getInputFormatters(validation),
                      style: GoogleFonts.assistant(
                        color: colors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText: _getHintText(),
                        prefixIcon: _buildPrefixIcon(colors),
                        suffixIcon: _buildSuffixIcon(colors),
                        hintStyle: GoogleFonts.assistant(
                          color: colors.text.withOpacity(0.5),
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isMultiline ? 16 : 12,
                        ),
                        counterText: '', // Hide default counter
                      ),
                      onChanged: (value) {
                        setState(() {
                          _currentText = value;
                        });
                        widget.onChanged(value);
                      },
                    ),

                    // Custom character counter and validation info
                    if (_shouldShowBottomInfo(validation))
                      _buildBottomInfo(colors, validation),
                  ],
                ),
              ),
            );
          },
        ),

        // Error message
        if (hasError) ...[
          const SizedBox(height: 8),
          _buildErrorMessage(colors),
        ],

        // Helper text
        if (widget.question.metadata?['helperText'] != null) ...[
          const SizedBox(height: 8),
          _buildHelperText(colors),
        ],
      ],
    );
  }

  Widget _buildPrefixIcon(dynamic colors) {
    final iconData =
        _getIconForInputType() ?? widget.question.icon ?? Icons.text_fields;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Icon(
        iconData,
        color: _isFocused ? colors.primary : colors.text.withOpacity(0.6),
        size: 22,
      ),
    );
  }

  Widget? _buildSuffixIcon(dynamic colors) {
    if (_currentText.isEmpty) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Character count for short inputs
        if (!_isMultiline() &&
            _getMaxLength(widget.question.validation) != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colors.text.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_currentText.length}/${_getMaxLength(widget.question.validation)}',
              style: GoogleFonts.assistant(
                fontSize: 11,
                color: colors.text.withOpacity(0.6),
              ),
            ),
          ),
        const SizedBox(width: 8),

        // Clear button
        GestureDetector(
          onTap: () {
            _internalController.clear();
            setState(() {
              _currentText = '';
            });
            widget.onChanged('');
            HapticFeedback.lightImpact();
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.text.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.close,
              size: 16,
              color: colors.text.withOpacity(0.6),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBottomInfo(dynamic colors, QuestionValidation? validation) {
    final maxLength = _getMaxLength(validation);
    final minLength = validation?.minLength;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Validation info
          if (minLength != null)
            Text(
              'מינימום $minLength תווים',
              style: GoogleFonts.assistant(
                fontSize: 12,
                color: _currentText.length >= minLength
                    ? colors.primary
                    : colors.text.withOpacity(0.5),
              ),
            )
          else
            const SizedBox.shrink(),

          // Character counter
          if (maxLength != null)
            Text(
              '${_currentText.length}/$maxLength',
              style: GoogleFonts.assistant(
                fontSize: 12,
                color: _currentText.length > maxLength * 0.9
                    ? colors.error ?? Colors.orange
                    : colors.text.withOpacity(0.5),
                fontWeight: _currentText.length > maxLength * 0.9
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(dynamic colors) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: widget.errorText?.isNotEmpty == true ? 1.0 : 0.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: (colors.error ?? Colors.red).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (colors.error ?? Colors.red).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              size: 16,
              color: colors.error ?? Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.errorText ?? '',
                style: GoogleFonts.assistant(
                  fontSize: 13,
                  color: colors.error ?? Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelperText(dynamic colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: colors.text.withOpacity(0.6),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              widget.question.metadata?['helperText'] ?? '',
              style: GoogleFonts.assistant(
                fontSize: 12,
                color: colors.text.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getHintText() {
    final placeholder = widget.question.metadata?['placeholder'];
    if (placeholder != null) return placeholder;

    final inputType = widget.question.metadata?['inputType'];
    switch (inputType) {
      case 'email':
        return 'הכנס כתובת אימייל...';
      case 'phone':
        return 'הכנס מספר טלפון...';
      case 'number':
        return 'הכנס מספר...';
      case 'url':
        return 'הכנס קישור...';
      default:
        return _isMultiline() ? 'הכנס תשובה מפורטת...' : 'הכנס תשובה...';
    }
  }

  IconData? _getIconForInputType() {
    final inputType = widget.question.metadata?['inputType'];
    switch (inputType) {
      case 'email':
        return Icons.email_outlined;
      case 'phone':
        return Icons.phone_outlined;
      case 'number':
        return Icons.numbers;
      case 'url':
        return Icons.link;
      default:
        return _isMultiline() ? Icons.notes : Icons.text_fields;
    }
  }

  TextInputType _getKeyboardType() {
    final inputType = widget.question.metadata?['inputType'];
    switch (inputType) {
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      case 'number':
        return TextInputType.number;
      case 'url':
        return TextInputType.url;
      default:
        return _isMultiline() ? TextInputType.multiline : TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters(QuestionValidation? validation) {
    final formatters = <TextInputFormatter>[];

    final inputType = widget.question.metadata?['inputType'];

    // Max length formatter
    final maxLength = _getMaxLength(validation);
    if (maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(maxLength));
    }

    // Type-specific formatters
    switch (inputType) {
      case 'number':
        formatters.add(FilteringTextInputFormatter.digitsOnly);
        break;
      case 'phone':
        formatters
            .add(FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')));
        break;
    }

    return formatters;
  }

  int? _getMaxLength(QuestionValidation? validation) {
    return validation?.maxLength ?? widget.question.metadata?['maxLength'];
  }

  bool _isMultiline() {
    return widget.question.metadata?['multiline'] == true;
  }

  bool _shouldShowBottomInfo(QuestionValidation? validation) {
    return _isMultiline() &&
        (validation?.minLength != null || _getMaxLength(validation) != null);
  }
}
