import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double elevation;
  final bool isFullWidth;

  const MyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.width,
    this.height = 48,
    this.fontSize = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.borderRadius = 30,
    this.elevation = 2,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: elevation,
          textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
        ),
        child: Text(text),
      ),
    );
  }
}
