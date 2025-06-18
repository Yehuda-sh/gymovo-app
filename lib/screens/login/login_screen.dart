// lib/screens/login/login_screen.dart

import 'package:flutter/material.dart';
import 'login_header.dart';
import 'login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                SizedBox(height: 40),
                LoginHeader(),
                SizedBox(height: 40),
                LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
