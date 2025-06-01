import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  final String? label;
  final String? Function(String?)? validate;
  final bool isObscured;
  TextEditingController controller;

  MyTextFormField({
    super.key,
    this.label,
    this.validate,
    this.isObscured = false,
    required this.controller
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUnfocus,
      validator: validate,
      obscureText: isObscured,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
      ),
    );
  }
}
