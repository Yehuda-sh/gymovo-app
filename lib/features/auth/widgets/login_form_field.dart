// features/auth/widgets/login_form_field.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String? error;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback onTogglePasswordVisibility;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<String>? autofillHints; // חדש! תמיכה באוטופיל

  const LoginFormField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    this.error,
    this.isPassword = false,
    this.isPasswordVisible = false,
    required this.onTogglePasswordVisibility,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.autofillHints, // חדש! חובה להעביר ב־login_form.dart
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: isPassword && !isPasswordVisible,
      keyboardType: keyboardType,
      textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
      style: GoogleFonts.assistant(
        fontSize: 16,
        color: colors.onSurface,
      ),
      autofillHints: autofillHints, // השורה שמאפשרת אוטופיל!
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.assistant(
          color: colors.onSurface.withValues(alpha: 0.7),
        ),
        errorText: error,
        errorStyle: GoogleFonts.assistant(
          color: colors.error,
          fontSize: 12,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: colors.onSurface.withValues(alpha: 0.7),
                ),
                onPressed: onTogglePasswordVisibility,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.onSurface.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.onSurface.withValues(alpha: 0.2),
          ),
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
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.error,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: colors.surface,
      ),
      validator: validator,
    );
  }
}
