// lib/screens/login/login_form_field.dart
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
  final List<String>? autofillHints;

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
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final labelColor = colors.onSurface.withOpacity(0.7);
    final iconColor = colors.onSurface.withOpacity(0.7);
    final borderRadius = BorderRadius.circular(12);

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
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.assistant(color: labelColor),
        errorText: error,
        errorStyle: GoogleFonts.assistant(
          color: colors.error,
          fontSize: 12,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: iconColor,
                  semanticLabel:
                      isPasswordVisible ? 'הסתר סיסמה' : 'הראה סיסמה',
                ),
                onPressed: onTogglePasswordVisibility,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.onSurface.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.onSurface.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        filled: true,
        fillColor: colors.surface,
      ),
      validator: validator,
    );
  }
}
