// features/auth/widgets/login_form.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_form_field.dart';
import 'login_button.dart';
import 'login_divider.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final bool isPasswordVisible;
  final bool rememberMe;
  final String? emailError;
  final String? passwordError;
  final String? generalError;
  final bool isLoading;
  final VoidCallback? onLogin; // מתוקן: VoidCallback?
  final VoidCallback onPasswordVisibilityToggle;
  final ValueChanged<bool> onRememberMeToggle;
  final VoidCallback onForgotPassword;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.isPasswordVisible,
    required this.rememberMe,
    required this.emailError,
    required this.passwordError,
    required this.generalError,
    required this.isLoading,
    required this.onLogin, // VoidCallback?
    required this.onPasswordVisibilityToggle,
    required this.onRememberMeToggle,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // שדה אימייל
          LoginFormField(
            controller: emailController,
            focusNode: emailFocusNode,
            label: 'אימייל',
            error: emailError,
            keyboardType: TextInputType.emailAddress,
            onTogglePasswordVisibility: () {}, // לא רלוונטי כאן
            validator: (v) => emailError,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 16),
          // שדה סיסמה
          LoginFormField(
            controller: passwordController,
            focusNode: passwordFocusNode,
            label: 'סיסמה',
            error: passwordError,
            isPassword: true,
            isPasswordVisible: isPasswordVisible,
            onTogglePasswordVisibility: onPasswordVisibilityToggle,
            validator: (v) => passwordError,
            autofillHints: const [AutofillHints.password],
          ),
          const SizedBox(height: 8),

          // זכור אותי + שכחת סיסמה
          Row(
            children: [
              Checkbox(
                value: rememberMe,
                onChanged: isLoading
                    ? null
                    : (val) => onRememberMeToggle(val ?? false),
              ),
              Text(
                'זכור אותי',
                style: GoogleFonts.assistant(
                  fontSize: 14,
                  color: colors.onSurface.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: isLoading ? null : onForgotPassword,
                child: Text(
                  'שכחת סיסמה?',
                  style: GoogleFonts.assistant(
                    fontSize: 14,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),

          // שגיאה כללית (אם יש)
          if (generalError != null && generalError!.isNotEmpty) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.error.withOpacity(0.18)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: colors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      generalError!,
                      style: GoogleFonts.assistant(
                        color: colors.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // כפתור התחברות
          LoginButton(
            onPressed: isLoading ? null : onLogin, // אין אזהרה כי הוא nullable
            label: 'התחבר',
            isLoading: isLoading,
          ),

          const SizedBox(height: 16),
          // מחיצה ויזואלית
          const LoginDivider(text: 'או התחברו עם'),
        ],
      ),
    );
  }
}
