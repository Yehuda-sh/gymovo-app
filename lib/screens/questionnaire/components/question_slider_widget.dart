// lib/screens/questionnaire/components/question_slider_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymovo_app/models/question_model.dart';
import 'package:gymovo_app/theme/app_theme.dart';
import 'question_header_widget.dart';

class SliderQuestionWidget extends StatefulWidget {
  final Question question;
  final dynamic value;
  final TextEditingController? controller;
  final Function(dynamic) onChanged;
  final bool isEnabled;
  final String? errorText;

  const SliderQuestionWidget({
    super.key,
    required this.question,
    this.value,
    this.controller,
    required this.onChanged,
    this.isEnabled = true,
    this.errorText,
  });

  @override
  State<SliderQuestionWidget> createState() => _SliderQuestionWidgetState();
}

class _SliderQuestionWidgetState extends State<SliderQuestionWidget>
    with TickerProviderStateMixin {
  late double _currentValue;
  late TextEditingController _textController;
  bool _isManualInput = false;
  String? _validationError;

  // Animation controllers
  late AnimationController _valueAnimationController;
  late AnimationController _shakeAnimationController;
  late Animation<double> _valueAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeValue();
    _setupTextController();
  }

  void _setupAnimations() {
    _valueAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shakeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _valueAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _valueAnimationController,
      curve: Curves.elasticOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shakeAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeValue() {
    final validation = widget.question.validation;
    final defaultValue = widget.question.defaultValue;

    double initialValue;

    if (widget.value != null) {
      initialValue = (widget.value is int)
          ? (widget.value as int).toDouble()
          : (widget.value as double);
    } else if (defaultValue != null) {
      initialValue = (defaultValue is int)
          ? (defaultValue as int).toDouble()
          : (defaultValue as double);
    } else {
      initialValue = validation?.minValue?.toDouble() ?? 0.0;
    }

    _currentValue = initialValue;
  }

  void _setupTextController() {
    _textController = widget.controller ?? TextEditingController();
    _textController.text = _currentValue.toInt().toString();

    _textController.addListener(() {
      if (!_isManualInput) return;
      _validateAndUpdateFromText();
    });
  }

  void _validateAndUpdateFromText() {
    final text = _textController.text;
    final validation = widget.question.validation;

    if (text.isEmpty) {
      setState(() {
        _validationError = null;
      });
      return;
    }

    final value = double.tryParse(text);
    if (value == null) {
      setState(() {
        _validationError = 'נא להזין מספר תקין';
      });
      _triggerShakeAnimation();
      return;
    }

    final minValue = validation?.minValue?.toDouble() ?? 0;
    final maxValue = validation?.maxValue?.toDouble() ?? 100;

    if (value < minValue || value > maxValue) {
      setState(() {
        _validationError =
            'הערך חייב להיות בין ${minValue.toInt()} ל-${maxValue.toInt()}';
      });
      _triggerShakeAnimation();
      return;
    }

    setState(() {
      _currentValue = value;
      _validationError = null;
    });

    _triggerValueAnimation();
    widget.onChanged(_getFormattedValue(value));
  }

  void _triggerValueAnimation() {
    _valueAnimationController.reset();
    _valueAnimationController.forward();
  }

  void _triggerShakeAnimation() {
    _shakeAnimationController.reset();
    _shakeAnimationController.forward();
    HapticFeedback.heavyImpact();
  }

  dynamic _getFormattedValue(double value) {
    // Return as int if the question expects integer values
    if (widget.question.type == QuestionType.number ||
        widget.question.metadata?['returnType'] == 'int') {
      return value.toInt();
    }
    return value;
  }

  @override
  void dispose() {
    _valueAnimationController.dispose();
    _shakeAnimationController.dispose();
    if (widget.controller == null) {
      _textController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final validation = widget.question.validation;
    final unit = widget.question.metadata?['unit'] ?? '';
    final showSteps = widget.question.metadata?['showSteps'] as bool? ?? false;
    final stepValue = widget.question.metadata?['stepValue'] as double? ?? 1.0;

    if (validation?.minValue == null || validation?.maxValue == null) {
      return _buildErrorWidget('שגיאה: לא הוגדרו גבולות לסליידר');
    }

    final minValue = validation!.minValue!.toDouble();
    final maxValue = validation.maxValue!.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionHeaderWidget(question: widget.question),
        const SizedBox(height: 20),

        // תצוגת הערך הנוכחי עם אנימציה
        AnimatedBuilder(
          animation: _valueAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _valueAnimation.value,
              child: _buildValueDisplay(colors, unit),
            );
          },
        ),

        const SizedBox(height: 24),

        // הסליידר עם תכונות מתקדמות
        _buildAdvancedSlider(
            colors, minValue, maxValue, stepValue, unit, showSteps),

        const SizedBox(height: 20),

        // כפתורי קיצור דרך (אם הוגדרו)
        if (widget.question.metadata?['quickValues'] != null)
          _buildQuickValuesButtons(colors, unit),

        const SizedBox(height: 16),

        // שדה הזנה ידנית עם ולידציה
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                  _shakeAnimation.value *
                      10 *
                      ((_shakeAnimation.value * 4).floor() % 2 == 0 ? 1 : -1),
                  0),
              child: _buildManualInput(colors, minValue, maxValue, unit),
            );
          },
        ),

        // הצגת שגיאת ולידציה
        if (_validationError != null || widget.errorText != null)
          _buildErrorMessage(colors),
      ],
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.assistant(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueDisplay(AppColors colors, String unit) {
    return Hero(
      tag: '${widget.question.id}_display',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary.withOpacity(0.15),
              colors.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.primary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${_currentValue.toInt()}',
                  style: GoogleFonts.assistant(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                    height: 1.0,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: GoogleFonts.assistant(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colors.primary.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
            if (widget.question.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.question.subtitle!,
                style: GoogleFonts.assistant(
                  fontSize: 14,
                  color: colors.text.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSlider(AppColors colors, double minValue,
      double maxValue, double stepValue, String unit, bool showSteps) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // הסליידר עצמו
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colors.primary,
              inactiveTrackColor: colors.primary.withOpacity(0.2),
              thumbColor: colors.primary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
              overlayColor: colors.primary.withOpacity(0.2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              trackHeight: 8,
              valueIndicatorColor: colors.primary,
              valueIndicatorTextStyle: GoogleFonts.assistant(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Slider(
              value: _currentValue.clamp(minValue, maxValue),
              min: minValue,
              max: maxValue,
              divisions: showSteps
                  ? ((maxValue - minValue) / stepValue).round()
                  : null,
              label: '${_currentValue.toInt()} $unit',
              onChanged: widget.isEnabled
                  ? (value) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _currentValue = value;
                        _isManualInput = false;
                        _textController.text = value.toInt().toString();
                        _validationError = null;
                      });
                      _triggerValueAnimation();
                      widget.onChanged(_getFormattedValue(value));
                    }
                  : null,
            ),
          ),

          const SizedBox(height: 12),

          // תצוגת טווח עם אייקונים
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRangeLabel(colors, minValue, unit, Icons.remove),
              if (showSteps)
                Text(
                  'צעד: ${stepValue.toInt()}',
                  style: GoogleFonts.assistant(
                    fontSize: 12,
                    color: colors.text.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              _buildRangeLabel(colors, maxValue, unit, Icons.add),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRangeLabel(
      AppColors colors, double value, String unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.primary.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text(
            '${value.toInt()} $unit',
            style: GoogleFonts.assistant(
              fontSize: 12,
              color: colors.text.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickValuesButtons(AppColors colors, String unit) {
    final quickValues = widget.question.metadata!['quickValues'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ערכים נפוצים:',
          style: GoogleFonts.assistant(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.text.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickValues.map((value) {
            final numValue =
                (value is int) ? value.toDouble() : value as double;
            final isSelected = _currentValue == numValue;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _currentValue = numValue;
                  _textController.text = numValue.toInt().toString();
                  _validationError = null;
                });
                _triggerValueAnimation();
                widget.onChanged(_getFormattedValue(numValue));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary
                      : colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.primary.withOpacity(isSelected ? 1.0 : 0.3),
                  ),
                ),
                child: Text(
                  '${numValue.toInt()} $unit',
                  style: GoogleFonts.assistant(
                    color: isSelected ? Colors.white : colors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildManualInput(
      AppColors colors, double minValue, double maxValue, String unit) {
    return TextField(
      controller: _textController,
      enabled: widget.isEnabled,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        LengthLimitingTextInputFormatter(10),
      ],
      style: GoogleFonts.assistant(
        color: colors.text,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: 'הזנה ידנית',
        hintText: 'הכנס ערך...',
        helperText: 'טווח תקין: ${minValue.toInt()}-${maxValue.toInt()} $unit',
        helperStyle: GoogleFonts.assistant(
          color: colors.text.withOpacity(0.6),
          fontSize: 12,
        ),
        prefixIcon: Icon(
          widget.question.icon ?? Icons.edit,
          color: colors.primary,
        ),
        suffixIcon: unit.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  unit,
                  style: GoogleFonts.assistant(
                    color: colors.text.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : null,
        hintStyle: GoogleFonts.assistant(
          color: colors.text.withOpacity(0.5),
        ),
        labelStyle: GoogleFonts.assistant(
          color: colors.text.withOpacity(0.7),
        ),
        filled: true,
        fillColor: colors.surface,
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
          borderSide: BorderSide(
            color: colors.error,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.error,
            width: 2,
          ),
        ),
      ),
      onTap: () {
        setState(() {
          _isManualInput = true;
        });
      },
      onChanged: (text) {
        setState(() {
          _isManualInput = true;
        });
      },
    );
  }

  Widget _buildErrorMessage(AppColors colors) {
    final errorText = _validationError ?? widget.errorText!;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: colors.error,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              errorText,
              style: GoogleFonts.assistant(
                color: colors.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
