import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String? label;
  final String? hintText;
  final Icon icon;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final String? initialValue;

  const MyTextfield({
    super.key,
    required this.icon,
    required this.controller,
    this.validator,
    this.label,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.enabled = true,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    if (initialValue != null && controller.text.isEmpty) {
      controller.text = initialValue!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: 16),
        obscureText: obscureText,
        keyboardType: keyboardType,
        enabled: enabled,
        cursorColor: Colors.white,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: icon,
          labelText: label ?? hintText,
          labelStyle: const TextStyle(color: Colors.black, fontSize: 15),
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintStyle: TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.blueGrey,
          errorStyle: const TextStyle(color: Colors.red),
        ),
        validator: validator ?? _defaultValidator,
      ),
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'این فیلد ضروری است';
    }
    return null;
  }
}
