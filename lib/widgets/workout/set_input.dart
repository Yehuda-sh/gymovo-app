// lib/widgets/workout/set_input.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class SetInput extends StatelessWidget {
  final int currentSet;
  final int totalSets;
  final TextEditingController weightController;
  final TextEditingController repsController;
  final VoidCallback onComplete;

  const SetInput({
    super.key,
    required this.currentSet,
    required this.totalSets,
    required this.weightController,
    required this.repsController,
    required this.onComplete,
  });

  bool get _isInputValid =>
      (weightController.text.isNotEmpty &&
          double.tryParse(weightController.text) != null) &&
      (repsController.text.isNotEmpty &&
          int.tryParse(repsController.text) != null);

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Semantics(
      label: 'הזנת סט $currentSet מתוך $totalSets',
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surface.withOpacity(0.99),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(16),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: colors.primary.withAlpha(36),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fitness_center, color: colors.primary, size: 22),
                const SizedBox(width: 9),
                Text(
                  'סט $currentSet מתוך $totalSets',
                  style: GoogleFonts.assistant(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: colors.headline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: weightController,
                    label: 'משקל (ק"ג)',
                    keyboardType: TextInputType.number,
                    color: colors,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildInputField(
                    controller: repsController,
                    label: 'חזרות',
                    keyboardType: TextInputType.number,
                    color: colors,
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AnimatedOpacity(
                opacity: _isInputValid ? 1 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: _isInputValid ? onComplete : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  label: Text(
                    'סיים סט',
                    style: GoogleFonts.assistant(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    required dynamic color,
    TextInputAction? textInputAction,
  }) {
    return Semantics(
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.assistant(
              fontSize: 14,
              color: color.headline.withOpacity(0.78),
            ),
          ),
          const SizedBox(height: 7),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: TextAlign.center,
            style: GoogleFonts.assistant(
              fontSize: 18,
              color: color.headline,
            ),
            textInputAction: textInputAction,
            decoration: InputDecoration(
              filled: true,
              fillColor: color.background.withOpacity(0.90),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
