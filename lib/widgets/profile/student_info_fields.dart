import 'package:flutter/cupertino.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/profile/profile_state.dart';
import '../common/custom_text_field.dart';

class StudentInfoFields extends StatelessWidget {
  final StudentProfileData data;
  final bool isEditing;

  const StudentInfoFields({
    super.key,
    required this.data,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: data.nameController,
          label: 'Full Name',
          icon: LucideIcons.user2,
          enabled: isEditing || !data.exists,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: data.addressController,
          label: 'Address',
          icon: LucideIcons.mapPin,
          enabled: isEditing || !data.exists,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: data.phoneController,
          label: 'Phone',
          icon: LucideIcons.phone,
          enabled: isEditing || !data.exists,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
      ],
    );
  }
}
