import 'package:flutter/material.dart';

import '../common/section_title.dart';

class ProfileHeader extends StatelessWidget {
  final bool exists;
  final bool isEditing;

  const ProfileHeader({
    super.key,
    required this.exists,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SectionTitle(title: 'Student Profile'),
        if (!exists)
          const Chip(
            label: Text('Not Created'),
            backgroundColor: Colors.orange,
            labelStyle: TextStyle(color: Colors.white),
          ),
      ],
    );
  }
}
