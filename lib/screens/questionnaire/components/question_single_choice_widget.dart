// lib/screens/questionnaire/components/question_single_choice_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymovo_app/models/question_model.dart';
import 'package:gymovo_app/theme/app_theme.dart';
import 'question_header_widget.dart';

class SingleChoiceQuestionWidget extends StatefulWidget {
  final Question question;
  final String? selectedValue;
  final Function(String?) onChanged;
  final bool showAsCards;
  final bool showAsRadio;

  const SingleChoiceQuestionWidget({
    super.key,
    required this.question,
    this.selectedValue,
    required this.onChanged,
    this.showAsCards = false,
    this.showAsRadio = false,
  });

  @override
  State<SingleChoiceQuestionWidget> createState() =>
      _SingleChoiceQuestionWidgetState();
}

class _SingleChoiceQuestionWidgetState extends State<SingleChoiceQuestionWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  String? _previousSelection;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    // Start animation on init
    _animationController.forward();
  }

  @override
  void didUpdateWidget(SingleChoiceQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != _previousSelection) {
      _previousSelection = widget.selectedValue;
      // Trigger a small bounce animation when selection changes
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionHeaderWidget(question: widget.question),
        const SizedBox(height: 20),

        if (widget.showAsRadio)
          _buildRadioList(colors)
        else if (widget.showAsCards)
          _buildCardOptions(colors)
        else
          _buildChipOptions(colors),

        // Selection summary
        if (widget.selectedValue != null) ...[
          const SizedBox(height: 16),
          _buildSelectionSummary(colors),
        ],
      ],
    );
  }

  Widget _buildChipOptions(dynamic colors) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.question.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 200 + (index * 100)),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: _buildEnhancedChip(option, colors),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedChip(QuestionOption option, dynamic colors) {
    final isSelected = widget.selectedValue == option.value;
    final isRecommended = option.isRecommended;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onChanged(option.value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary,
                    colors.primary.withOpacity(0.8),
                  ],
                )
              : null,
          color: isSelected
              ? null
              : isRecommended
                  ? colors.primary.withOpacity(0.08)
                  : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : isRecommended
                    ? colors.primary.withOpacity(0.4)
                    : colors.text.withOpacity(0.15),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            if (isSelected) ...[
              BoxShadow(
                color: colors.primary.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: colors.primary.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ] else ...[
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      option.icon!,
                      size: 24,
                      color: isSelected ? Colors.white : colors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  option.displayText,
                  style: GoogleFonts.assistant(
                    color: isSelected ? Colors.white : colors.text,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (option.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    option.description!,
                    style: GoogleFonts.assistant(
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : colors.text.withOpacity(0.7),
                      fontSize: 12,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),

            // Recommended badge
            if (isRecommended)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.orange.shade700],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'מומלץ',
                        style: GoogleFonts.assistant(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Selection indicator
            if (isSelected)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardOptions(dynamic colors) {
    return Column(
      children: widget.question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 150)),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(50 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCardOption(option, colors),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildCardOption(QuestionOption option, dynamic colors) {
    final isSelected = widget.selectedValue == option.value;
    final isRecommended = option.isRecommended;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onChanged(option.value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : isRecommended
                    ? colors.primary.withOpacity(0.3)
                    : colors.text.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? colors.primary.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (option.icon != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  option.icon!,
                  color: isSelected ? Colors.white : colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          option.displayText,
                          style: GoogleFonts.assistant(
                            color: isSelected ? Colors.white : colors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isRecommended)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
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
                    ],
                  ),
                  if (option.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      option.description!,
                      style: GoogleFonts.assistant(
                        color: isSelected
                            ? Colors.white.withOpacity(0.9)
                            : colors.text.withOpacity(0.7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? Colors.white : colors.text.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: colors.primary,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioList(dynamic colors) {
    return Column(
      children: widget.question.options.map((option) {
        final isSelected = widget.selectedValue == option.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: RadioListTile<String>(
            title: Text(
              option.displayText,
              style: GoogleFonts.assistant(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: option.description != null
                ? Text(
                    option.description!,
                    style: GoogleFonts.assistant(
                      color: colors.text.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  )
                : null,
            value: option.value,
            groupValue: widget.selectedValue,
            activeColor: colors.primary,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              widget.onChanged(value);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor:
                isSelected ? colors.primary.withOpacity(0.1) : colors.surface,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectionSummary(dynamic colors) {
    final selectedOption = widget.question.options
        .firstWhere((option) => option.value == widget.selectedValue);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary.withOpacity(0.1),
              colors.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'נבחר: ${selectedOption.displayText}',
                    style: GoogleFonts.assistant(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: colors.primary,
                    ),
                  ),
                  if (selectedOption.description != null)
                    Text(
                      selectedOption.description!,
                      style: GoogleFonts.assistant(
                        fontSize: 13,
                        color: colors.text.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
