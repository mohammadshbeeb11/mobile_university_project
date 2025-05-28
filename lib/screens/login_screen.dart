import 'package:flutter/material.dart';
import 'package:khat_husseini/utils/my_button.dart';
import 'package:khat_husseini/utils/my_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final admin = {'email': 'admin@admin.com', 'password': '1234567'};

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _onLoginPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!_formKey.currentState!.validate()) return;

    final isValidUser = _areCredentialsCorrect(email, password);

    if (isValidUser) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    }
  }

  bool _areCredentialsCorrect(String email, String password) {
    return email == admin['email'] && password == admin['password'];
  }

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) return 'Email is required';
    if (!email.contains('@')) return 'Email must contain @';
    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) return 'Password is required';
    if (password.length <= 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 30),
                MyTextFormField(
                  controller: _emailController,
                  label: "Email",
                  validate: (emailField) => _validateEmail(emailField),
                ),
                const SizedBox(height: 20),
                MyTextFormField(
                  controller: _passwordController,
                  label: "Password",
                  validate: (passwordField) => _validatePassword(passwordField),
                  isObscured: true,
                ),
                const SizedBox(height: 20),
                MyButton(title: "Login", onPressed: () => _onLoginPressed()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
