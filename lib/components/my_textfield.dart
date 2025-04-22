import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String hintText;
  final Icon icon;
  final TextEditingController controller;

  const MyTextfield({super.key, required this.hintText, required this.icon, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 16),
        obscureText: hintText == 'Password',
        decoration: InputDecoration(
          prefixIcon: icon,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
          filled: true,
          fillColor: Colors.black,
        ),
      ),
    );
  }
}
