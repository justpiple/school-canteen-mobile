import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../models/student/profile_state.dart';
import '../../models/student/update_student.dart';
import '../../models/update_user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../utils/message_dialog.dart';
import '../../widgets/profile/student_profile_section.dart';
import '../../widgets/profile/user_info_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = ProfileControllers();
  final _profileState = ProfileState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  StudentProfileData _getProfileData() {
    return StudentProfileData(
      student: context.read<ProfileProvider>().studentProfile?.data,
      imageFile: _profileState.imageFile,
      exists: _profileState.exists,
      isLoading: _profileState.isLoading,
      nameController: _controllers.name,
      addressController: _controllers.address,
      phoneController: _controllers.phone,
    );
  }

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData({bool forceRefresh = false}) async {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    final userInfo = authProvider.user;
    if (userInfo != null) {
      _controllers.username.text = userInfo.username ?? '';
    }

    await profileProvider.loadProfile(forceRefresh: forceRefresh);
    setState(() {
      _profileState.exists = profileProvider.studentProfile != null;

      final student = profileProvider.studentProfile?.data;
      if (student != null) {
        _controllers.updateFromStudent(student);
      }
    });
  }

  Future<void> _updateUserInfo() async {
    if (!_formKey.currentState!.validate()) return;

    _profileState.setLoading(true);

    try {
      final authProvider = context.read<AuthProvider>();

      final dto = UpdateUserDto(
        username: _controllers.username.text,
        password: _controllers.password.text.isNotEmpty
            ? _controllers.password.text
            : null,
      );

      await authProvider.updateUserInfo(dto);

      if (!mounted) return;

      _profileState.setLoading(false);
      _toggleEdit();
      _controllers.password.clear();

      showMessageDialog(
        context,
        'Success',
        'User info updated successfully',
      );
    } catch (e) {
      if (!mounted) return;
      _profileState.setLoading(false);

      showMessageDialog(
        context,
        'Error',
        'Failed to update user info: ${e.toString()}',
      );
    }
  }

  Future<void> _refreshProfile() async {
    await _loadProfileData(forceRefresh: true);
  }

  Future<void> _logout() async {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    await authProvider.logout();
    profileProvider.clearCache();
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Do you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _logout();
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    _profileState.setLoading(true);

    try {
      final profileProvider = context.read<ProfileProvider>();

      String success;
      if (_profileState.exists) {
        final dto = UpdateStudentDto(
          name: _controllers.name.text,
          address: _controllers.address.text,
          phone: _controllers.phone.text,
        );

        success = await profileProvider.updateStudentProfile(
          dto,
          photoFile: _profileState.imageFile,
        );
      } else {
        success = await profileProvider.createStudentProfile(
          name: _controllers.name.text,
          address: _controllers.address.text,
          phone: _controllers.phone.text,
          photoFile: _profileState.imageFile,
        );
        if (success.indexOf("successful") > 0) {
          _profileState.exists = true;
        }
      }

      if (!mounted) return;

      _profileState.setLoading(false);
      if (success.indexOf("successful") > 0) {
        profileProvider.clearCache();
        _toggleEdit();

        showMessageDialog(
          context,
          'Success',
          _profileState.exists
              ? 'Profile updated successfully'
              : 'Profile created successfully',
        );
      } else {
        showMessageDialog(
          context,
          'Error',
          success,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _profileState.setLoading(false);

      showMessageDialog(
        context,
        'Error',
        'Failed to save profile: ${e.toString()}',
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _profileState.setImageFile(File(image.path));
      setState(() {});
    }
  }

  void _toggleEdit() {
    setState(() {
      _profileState.toggleEdit();
      if (!_profileState.isEditing) {
        _loadProfileData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                _profileState.isEditing ? LucideIcons.x : LucideIcons.edit,
                color: Colors.black,
                size: 20,
              ),
              tooltip: _profileState.isEditing ? 'Cancel Edit' : 'Edit Profile',
              onPressed: _toggleEdit,
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: .8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(
                LucideIcons.logOut,
                color: Colors.white,
                size: 20,
              ),
              tooltip: 'Logout',
              onPressed: _confirmLogout,
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer2<AuthProvider, ProfileProvider>(
        builder: (context, authProvider, profileProvider, _) {
          final profileData = _getProfileData();

          return RefreshIndicator(
            onRefresh: _refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    UserInfoSection(
                      usernameController: _controllers.username,
                      passwordController: _controllers.password,
                      isEditing: _profileState.isEditing,
                      isLoading: _profileState.isLoading,
                      onUpdate: _updateUserInfo,
                    ),
                    const SizedBox(height: 24),
                    StudentProfileSection(
                      data: profileData,
                      isEditing: _profileState.isEditing,
                      onSave: _saveProfile,
                      onImagePick: _pickImage,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
