// lib/screens/login/login_screen.dart

import 'package:flutter/material.dart';
import 'login_header.dart';
import 'login_form.dart';

class LoginScreen extends StatelessWidget {
  final String? prefilledEmail;

  const LoginScreen({super.key, this.prefilledEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  const LoginHeader(),
                  const SizedBox(height: 40),
                  LoginForm(prefilledEmail: prefilledEmail),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
