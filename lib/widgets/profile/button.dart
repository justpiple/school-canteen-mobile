import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EditButton extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onPressed;

  const EditButton({
    super.key,
    required this.isEditing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isEditing ? LucideIcons.x : LucideIcons.pencil),
      onPressed: onPressed,
    );
  }
}

class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LogoutButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(LucideIcons.logOut, color: Colors.redAccent),
      onPressed: onPressed,
    );
  }
}
