import 'package:flutter/cupertino.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../common/custom_text_field.dart';
import '../common/loading_button.dart';
import '../common/section_title.dart';

class UserInfoSection extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isEditing;
  final bool isLoading;
  final VoidCallback onUpdate;

  const UserInfoSection({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.isEditing,
    required this.isLoading,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'User Information'),
        const SizedBox(height: 16),
        CustomTextField(
          controller: usernameController,
          label: 'Username',
          icon: LucideIcons.user,
          enabled: isEditing,
          validator: (value) =>
              value?.isEmpty == true ? 'Please enter username' : null,
        ),
        if (isEditing) ...[
          const SizedBox(height: 16),
          CustomTextField(
            controller: passwordController,
            label: 'New Password (optional)',
            icon: LucideIcons.key,
            isPassword: true,
            enabled: true,
          ),
          const SizedBox(height: 16),
          LoadingButton(
            onPressed: onUpdate,
            isLoading: isLoading,
            text: 'Update User Info',
          ),
        ],
      ],
    );
  }
}
