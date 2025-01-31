import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../models/stand/profile_state.dart';
import '../../models/stand/update_stand.dart';
import '../../models/stand/create_stand.dart';
import '../../models/update_user.dart';
import '../../providers/auth_provider.dart';
import '../../services/stand_admin/stand_service.dart';
import '../../widgets/profile/stand_profile_section.dart';
import '../../widgets/profile/user_info_section.dart';

class StandProfilePage extends StatefulWidget {
  const StandProfilePage({super.key});

  @override
  State<StandProfilePage> createState() => _StandProfilePageState();
}

class _StandProfilePageState extends State<StandProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = StandProfileControllers();
  final _profileState = StandProfileState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  StandProfileData _getProfileData() {
    return StandProfileData(
      stand: context.read<StandService>().standProfileCache?.data,
      exists: _profileState.exists,
      isLoading: _profileState.isLoading,
      standNameController: _controllers.standName,
      ownerNameController: _controllers.ownerName,
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
    final standService = context.read<StandService>();

    final userInfo = authProvider.user;
    if (userInfo != null) {
      _controllers.username.text = userInfo.username ?? '';
    }

    final response = await standService.getProfile(forceRefresh: forceRefresh);
    setState(() {
      _profileState.exists = response.data != null;

      if (response.data != null) {
        _controllers.updateFromStand(response.data!);
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _profileState.setLoading(true);
    });

    try {
      final standService = context.read<StandService>();

      final response = _profileState.exists
          ? await standService.updateProfile(
              UpdateStandDto(
                standName: _controllers.standName.text,
                ownerName: _controllers.ownerName.text,
                phone: _controllers.phone.text,
              ),
            )
          : await standService.createProfile(
              CreateStandDto(
                standName: _controllers.standName.text,
                ownerName: _controllers.ownerName.text,
                phone: _controllers.phone.text,
              ),
            );
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        standService.clearProfileCache();
        _toggleEdit();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully')),
        );
        if (!_profileState.exists) {
          setState(() => _profileState.exists = true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          // ignore: dead_null_aware_expression
          SnackBar(content: Text(response.message ?? 'Unknown error occurred')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _profileState.setLoading(false);
      });
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

  Future<void> _logout() async {
    final authProvider = context.read<AuthProvider>();
    final profileService = context.read<StandService>();
    await authProvider.logout();
    profileService.clearProfileCache();
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User info updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      _profileState.setLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user info: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stand Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _profileState.isEditing ? LucideIcons.x : LucideIcons.edit,
              color: Colors.black,
            ),
            onPressed: _toggleEdit,
          ),
          IconButton(
            icon: const Icon(LucideIcons.logOut, color: Colors.red),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: Consumer2<AuthProvider, StandService>(
        builder: (context, authProvider, standService, _) {
          final profileData = _getProfileData();

          return RefreshIndicator(
            onRefresh: _loadProfileData,
            child: SingleChildScrollView(
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
                    StandProfileSection(
                      data: profileData,
                      isEditing: _profileState.isEditing,
                      onSave: _saveProfile,
                    ),
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
