import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final MaterialColor? color;
  final Color? textColor;
  final VoidCallback onPressed;

  const MyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = Colors.blue,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, color: textColor ?? Colors.white),
      ),
    );
  }
}
