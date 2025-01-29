import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileAvatar extends StatelessWidget {
  final File? imageFile;
  final String? photoUrl;
  final bool isEditing;
  final VoidCallback onPick;

  const ProfileAvatar({
    super.key,
    this.imageFile,
    this.photoUrl,
    required this.isEditing,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _getImageProvider(),
          ),
          if (isEditing)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(LucideIcons.camera, color: Colors.white),
                onPressed: onPick,
              ),
            ),
        ],
      ),
    );
  }

  ImageProvider _getImageProvider() {
    if (imageFile != null) {
      return FileImage(imageFile!);
    }
    if (photoUrl != null) {
      return NetworkImage(photoUrl!);
    }
    return const AssetImage('assets/images/default_avatar.jpg');
  }
}
