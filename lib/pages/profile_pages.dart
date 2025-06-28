import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'signin_pages.dart';
import 'profile_photo_pages.dart';
import 'crop_photo_pages.dart';
import '../models/user_models.dart';
import '../services/auth_api_service.dart';
import '../services/user_api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _user;
  bool _isLoading = true;
  String? _error;
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _showOldPassword = false;
  bool _showNewPassword = false;

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Function load user profile
  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignInPage()),
          (route) => false,
        );
      }
      return;
    }

    try {
      final user = await UserApiService.fetchUserProfile();
      setState(() {
        _user = user;
        _nameController.text = user.name;
        _emailController.text = user.email;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Function update profile
  Future<void> _updateProfile() async {
    // Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final message = await UserApiService.updateUserProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        oldPassword: _oldPasswordController.text.trim().isEmpty
            ? null
            : _oldPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim().isEmpty
            ? null
            : _newPasswordController.text.trim(),
        profileImage: _selectedImage,
      );

      Navigator.pop(context, true);
      _showSnackBar(message, Colors.green);
      setState(() {
        _isEditing = false;
        _selectedImage = null;
      });
      await _loadUserProfile();
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      _showSnackBar('Failed to update profile: $e', Colors.red);
    }
  }

  // Function signout
  Future<void> _signout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await AuthApiService.signout();
      if (context.mounted) {
        _showSnackBar('Signout Successfully', Colors.green);

        // Redirect to login pages
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignInPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      _showSnackBar('Failed to signout: $e', Colors.red);
    }
  }

  // Function show image source
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Open Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Open Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function crop image
  Future<File?> _cropImage(String imagePath) async {
    final croppedFile = await Navigator.push<File?>(
      context,
      MaterialPageRoute(
        builder: (_) => CropImagePage(imageFile: File(imagePath)),
      ),
    );
    return croppedFile;
  }

  // Function pick image
  Future<void> _pickImage(ImageSource source) async {
    if (await Permission.camera.request().isDenied ||
        (Platform.isAndroid && await Permission.photos.request().isDenied)) {
      _showSnackBar("Permission Denied", Colors.red);
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile != null) {
      final croppedImage = await _cropImage(pickedFile.path);
      if (croppedImage != null) {
        setState(() => _selectedImage = croppedImage);
      } else {
        _showSnackBar('Canceled to crop image', Colors.orange);
      }
    }
  }

  // Pop up snackbar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  Widget _buildProfileImage() {
    final imageUrl = _user?.profileImages.isNotEmpty == true
        ? _user!.profileImages.first.url
        : null;

    return GestureDetector(
      onTap: !_isEditing && imageUrl != null
          ? () => _openFullImage(imageUrl)
          : null,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 70,
            backgroundImage: _selectedImage != null
                ? FileImage(_selectedImage!)
                : (imageUrl != null ? NetworkImage(imageUrl) : null)
                      as ImageProvider?,
            backgroundColor: Colors.grey[300],
            child: imageUrl == null && _selectedImage == null
                ? const Icon(Icons.person, size: 70, color: Colors.white)
                : null,
          ),
          if (_isEditing)
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: _showImageSourceDialog,
                tooltip: 'Change Photo Profile',
              ),
            ),
        ],
      ),
    );
  }

  void _openFullImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FullImagePage(imageUrl: imageUrl)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xfff8c9d3),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
            tooltip: _isEditing ? 'Cancel' : 'Edit Profil',
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileImage(),
                      const SizedBox(height: 24),

                      // Name
                      TextFormField(
                        controller: _nameController,
                        readOnly: !_isEditing,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Username
                      TextFormField(
                        initialValue: _user!.username,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        readOnly: !_isEditing,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Old Password
                      if (_isEditing) ...[
                        TextFormField(
                          controller: _oldPasswordController,
                          obscureText: !_showOldPassword,
                          decoration: InputDecoration(
                            labelText: 'Old Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showOldPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(
                                  () => _showOldPassword = !_showOldPassword,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // New Password
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: !_showNewPassword,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(
                                  () => _showNewPassword = !_showNewPassword,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tombol save / signout tetap di bawah
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isEditing ? _updateProfile : _signout,
                  icon: Icon(
                    _isEditing ? Icons.save : Icons.logout,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isEditing ? 'Save' : 'SignOut',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent.shade200,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
