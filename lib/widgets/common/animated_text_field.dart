import 'package:flutter/material.dart';

class AnimatedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final bool isPassword;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AnimatedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.enabled = true,
    this.isPassword = false,
    this.maxLines,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: enabled
            ? Colors.grey.withValues(alpha: .1)
            : Colors.grey.withValues(alpha: .05),
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: isPassword,
        maxLines: maxLines ?? 1,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          errorStyle: const TextStyle(
            fontSize: 12,
            height: 1,
          ),
        ),
        style: TextStyle(
          color: enabled ? null : Colors.grey,
        ),
      ),
    );
  }
}
