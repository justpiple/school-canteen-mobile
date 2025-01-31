import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'student.dart';

class ProfileControllers {
  final username = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final address = TextEditingController();
  final phone = TextEditingController();

  void dispose() {
    username.dispose();
    password.dispose();
    name.dispose();
    address.dispose();
    phone.dispose();
  }

  void updateFromStudent(Student student) {
    name.text = student.name;
    address.text = student.address;
    phone.text = student.phone;
  }
}

class ProfileState {
  bool isLoading = false;
  bool isEditing = false;
  bool exists = false;
  File? imageFile;

  void toggleEdit() {
    isEditing = !isEditing;
  }

  void setLoading(bool value) {
    isLoading = value;
  }

  void setImageFile(File? file) {
    imageFile = file;
  }
}

class StudentProfileData {
  final Student? student;
  final File? imageFile;
  final bool exists;
  final bool isLoading;
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController phoneController;

  StudentProfileData({
    this.student,
    this.imageFile,
    required this.exists,
    required this.isLoading,
    required this.nameController,
    required this.addressController,
    required this.phoneController,
  });
}
