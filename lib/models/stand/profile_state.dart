import 'package:flutter/cupertino.dart';
import './stand.dart';

class StandProfileControllers {
  final username = TextEditingController();
  final password = TextEditingController();
  final standName = TextEditingController();
  final ownerName = TextEditingController();
  final phone = TextEditingController();

  void dispose() {
    username.dispose();
    password.dispose();
    standName.dispose();
    ownerName.dispose();
    phone.dispose();
  }

  void updateFromStand(Stand stand) {
    standName.text = stand.standName;
    ownerName.text = stand.ownerName;
    phone.text = stand.phone;
  }
}

class StandProfileState {
  bool isLoading = false;
  bool isEditing = false;
  bool exists = false;

  void toggleEdit() {
    isEditing = !isEditing;
  }

  void setLoading(bool value) {
    isLoading = value;
  }
}

class StandProfileData {
  final Stand? stand;
  final bool exists;
  final bool isLoading;
  final TextEditingController standNameController;
  final TextEditingController ownerNameController;
  final TextEditingController phoneController;

  StandProfileData({
    this.stand,
    required this.exists,
    required this.isLoading,
    required this.standNameController,
    required this.ownerNameController,
    required this.phoneController,
  });
}
