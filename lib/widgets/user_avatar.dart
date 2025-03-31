import 'dart:math';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;

  const UserAvatar({super.key, required this.name, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: _getRandomColor(name),
      child:
          avatarUrl != null && avatarUrl!.isNotEmpty
              ? Image.network(
                avatarUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackText(name);
                },
              )
              : _buildFallbackText(name),
    );
  }
}

// extract first letter of name
Widget _buildFallbackText(String name) {
  return Text(
    name.isNotEmpty ? name[0].toUpperCase() : "?",
    style: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );
}

// generate random colors based on name
Color _getRandomColor(String name) {
  final random = Random(name.hashCode);
  return Color.fromARGB(
    255,
    100 + random.nextInt(156),
    100 + random.nextInt(156),
    100 + random.nextInt(156),
  );
}
