import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:school_canteen/widgets/profile/profile_avatar.dart';

import '../../models/profile/profile_state.dart';
import '../common/animated_text_field.dart';

class StudentProfileSection extends StatelessWidget {
  final StudentProfileData data;
  final bool isEditing;
  final VoidCallback onSave;
  final VoidCallback onImagePick;

  const StudentProfileSection({
    super.key,
    required this.data,
    required this.isEditing,
    required this.onSave,
    required this.onImagePick,
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
                Icon(Icons.school, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Student Profile',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ProfileAvatar(
                imageFile: data.imageFile,
                photoUrl: data.student?.photo,
                isEditing: isEditing,
                onPick: onImagePick,
              ),
            ),
            const SizedBox(height: 24),
            AnimatedTextField(
              controller: data.nameController,
              label: 'Full Name',
              icon: Icons.badge,
              enabled: isEditing,
              validator: (value) =>
                  value?.isEmpty == true ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 16),
            AnimatedTextField(
              controller: data.addressController,
              label: 'Address',
              icon: Icons.home,
              enabled: isEditing,
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty == true ? 'Please enter your address' : null,
            ),
            const SizedBox(height: 16),
            AnimatedTextField(
              controller: data.phoneController,
              label: 'Phone',
              icon: Icons.phone,
              enabled: isEditing,
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty == true
                  ? 'Please enter your phone number'
                  : null,
            ),
            if (isEditing) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: data.isLoading ? null : onSave,
                  icon: data.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.save),
                  label: Text(data.exists ? 'Save Changes' : 'Create Profile'),
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
