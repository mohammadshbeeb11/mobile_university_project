import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final String? hintText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String? Function(String?)? validator;

  const CustomFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  // Factory constructors for common field types
  factory CustomFormField.title({
    Key? key,
    required TextEditingController controller,
  }) {
    return CustomFormField(
      key: key,
      controller: controller,
      labelText: 'Title',
      prefixIcon: Icons.title,
      validator:
          (value) =>
              value?.trim().isEmpty ?? true ? 'Please enter a title' : null,
    );
  }

  factory CustomFormField.description({
    Key? key,
    required TextEditingController controller,
  }) {
    return CustomFormField(
      key: key,
      controller: controller,
      labelText: 'Description',
      prefixIcon: Icons.description,
      maxLines: 3,
      validator:
          (value) =>
              value?.trim().isEmpty ?? true
                  ? 'Please enter a description'
                  : null,
    );
  }

  factory CustomFormField.price({
    Key? key,
    required TextEditingController controller,
  }) {
    return CustomFormField(
      key: key,
      controller: controller,
      labelText: 'Price',
      prefixIcon: Icons.attach_money,
      hintText: '100',
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value?.trim().isEmpty ?? true) return 'Please enter a price';
        final parsed = double.tryParse(value!.trim());
        if (parsed == null) return 'Please enter a valid number';
        if (parsed <= 0) return 'Price must be greater than 0';
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(prefixIcon),
        hintText: hintText,
      ),
      validator: validator,
    );
  }
}
