import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_models.dart';

class ProfileForm extends StatelessWidget {
  final UserProfile user;
  final bool isEditing;
  final File? selectedImage;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController oldPasswordController;
  final TextEditingController newPasswordController;
  final bool showOldPassword;
  final bool showNewPassword;
  final VoidCallback onToggleOldPassword;
  final VoidCallback onToggleNewPassword;
  final VoidCallback onTapImage;
  final Widget Function() buildProfileImage;

  const ProfileForm({
    super.key,
    required this.user,
    required this.isEditing,
    required this.selectedImage,
    required this.nameController,
    required this.emailController,
    required this.oldPasswordController,
    required this.newPasswordController,
    required this.showOldPassword,
    required this.showNewPassword,
    required this.onToggleOldPassword,
    required this.onToggleNewPassword,
    required this.onTapImage,
    required this.buildProfileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildProfileImage(),
        const SizedBox(height: 24),

        // Name
        TextFormField(
          controller: nameController,
          readOnly: !isEditing,
          decoration: InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        // Username
        TextFormField(
          initialValue: user.username,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        // Email
        TextFormField(
          controller: emailController,
          readOnly: !isEditing,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        // Passwords
        if (isEditing) ...[
          // Old Password
          TextFormField(
            controller: oldPasswordController,
            obscureText: !showOldPassword,
            decoration: InputDecoration(
              labelText: 'Old Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  showOldPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: onToggleOldPassword,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // New Password
          TextFormField(
            controller: newPasswordController,
            obscureText: !showNewPassword,
            decoration: InputDecoration(
              labelText: 'New Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  showNewPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: onToggleNewPassword,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
