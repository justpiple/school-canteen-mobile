import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../common/animated_text_field.dart';

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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'User Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedTextField(
              controller: usernameController,
              label: 'Username',
              icon: Icons.account_circle,
              enabled: isEditing,
              validator: (value) =>
                  value?.isEmpty == true ? 'Please enter username' : null,
            ),
            if (isEditing) ...[
              const SizedBox(height: 16),
              AnimatedTextField(
                controller: passwordController,
                label: 'New Password (optional)',
                icon: Icons.key,
                isPassword: true,
                enabled: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onUpdate,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.save),
                  label: const Text('Update User Info'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
