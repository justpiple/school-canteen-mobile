import 'package:flutter/cupertino.dart';
import 'package:school_canteen/widgets/profile/profile_avatar.dart';
import 'package:school_canteen/widgets/profile/profile_header.dart';
import 'package:school_canteen/widgets/profile/student_info_fields.dart';

import '../../models/profile/profile_state.dart';
import '../common/loading_button.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileHeader(
          exists: data.exists,
          isEditing: isEditing,
        ),
        const SizedBox(height: 24),
        ProfileAvatar(
          imageFile: data.imageFile,
          photoUrl: data.student?.photo,
          isEditing: isEditing,
          onPick: onImagePick,
        ),
        const SizedBox(height: 24),
        StudentInfoFields(
          data: data,
          isEditing: isEditing,
        ),
        if (isEditing || !data.exists)
          LoadingButton(
            onPressed: onSave,
            isLoading: data.isLoading,
            text: data.exists ? 'Save Changes' : 'Create Profile',
          ),
      ],
    );
  }
}
