import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_models.dart';
import '../services/user_api_services.dart';
import 'signin_pages.dart';

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

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
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

  Future<void> _updateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _showSnackBar('Token tidak ditemukan.', Colors.red);
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('https://api-litera.vercel.app/user/profile-update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Profil berhasil diperbarui!', Colors.green);
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      } else {
        final msg =
            jsonDecode(response.body)['message'] ?? 'Gagal memperbarui profil.';
        _showSnackBar(msg, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e', Colors.red);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SigninPage()),
        (route) => false,
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
      _showSnackBar('Gambar siap diunggah (simulasi).', Colors.grey);

      // TODO: Integrasikan dengan upload API jika tersedia
    }
  }

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

    return Stack(
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
              onPressed: _pickImage,
              tooltip: 'Ubah foto profil',
            ),
          ),
      ],
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xfff8c9d3),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
            tooltip: _isEditing ? 'Batal' : 'Edit Profil',
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildProfileImage(),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              readOnly: !_isEditing,
              decoration: InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isEditing ? _updateProfile : _logout,
                icon: Icon(
                  _isEditing ? Icons.save : Icons.logout,
                  color: Colors.white,
                ),
                label: Text(
                  _isEditing ? 'Simpan Perubahan' : 'Logout',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEditing
                      ? Colors.pinkAccent.shade200
                      : Colors.pinkAccent.shade200,
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
    );
  }
}
