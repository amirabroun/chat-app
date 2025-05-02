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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: 16),
        obscureText: obscureText,
        keyboardType: keyboardType,
        enabled: enabled,
        cursorColor: colorScheme.onSurface,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: icon,
          labelText: label ?? hintText,
          labelStyle: TextStyle(color: colorScheme.onSurface, fontSize: 15),
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintStyle: TextStyle(color: colorScheme.onSurface),
          filled: true,
          hoverColor: Colors.transparent,
          fillColor: colorScheme.surface,
          errorStyle: TextStyle(color: colorScheme.error),
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
