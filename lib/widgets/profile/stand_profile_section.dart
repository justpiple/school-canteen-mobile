import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/stand/profile_state.dart';
import '../common/animated_text_field.dart';

class StandProfileSection extends StatelessWidget {
  final StandProfileData data;
  final bool isEditing;
  final VoidCallback onSave;

  const StandProfileSection({
    super.key,
    required this.data,
    required this.isEditing,
    required this.onSave,
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
                Icon(Icons.store, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Stand Profile',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AnimatedTextField(
              controller: data.standNameController,
              label: 'Stand Name',
              icon: LucideIcons.store,
              enabled: isEditing,
              validator: (value) =>
                  value?.isEmpty == true ? 'Please enter stand name' : null,
            ),
            const SizedBox(height: 16),
            AnimatedTextField(
              controller: data.ownerNameController,
              label: 'Owner Name',
              icon: LucideIcons.contact,
              enabled: isEditing,
              validator: (value) =>
                  value?.isEmpty == true ? 'Please enter owner name' : null,
            ),
            const SizedBox(height: 16),
            AnimatedTextField(
              controller: data.phoneController,
              label: 'Phone',
              icon: LucideIcons.phone,
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
