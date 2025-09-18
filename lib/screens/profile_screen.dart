// screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:lively/core/constants.dart';
import 'package:lively/core/db/app_database.dart';

/// Screen for managing user profile (nickname and photo)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nicknameController = TextEditingController();
  String? _photoPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final db = await AppDatabase.instance.database;
      final results = await db.query(
        AppConstants.settingsTable,
        where: 'key IN (?, ?)',
        whereArgs: [
          AppConstants.nicknameKey,
          AppConstants.profilePhotoPathKey,
        ],
      );

      for (final row in results) {
        final key = row['key'] as String;
        final value = row['value'] as String;
        if (key == AppConstants.nicknameKey) {
          _nicknameController.text = value;
        } else if (key == AppConstants.profilePhotoPathKey) {
          _photoPath = value;
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = File('${appDir.path}/$fileName');

      // Copy picked image to app directory
      await File(pickedImage.path).copy(savedImage.path);

      // Delete old photo if exists
      if (_photoPath != null) {
        try {
          await File(_photoPath!).delete();
        } catch (_) {}
      }

      // Save new photo path
      final db = await AppDatabase.instance.database;
      await db.insert(
        AppConstants.settingsTable,
        {
          'key': AppConstants.profilePhotoPathKey,
          'value': savedImage.path,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      setState(() => _photoPath = savedImage.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _saveNickname() async {
    final nickname = _nicknameController.text.trim();
    try {
      final db = await AppDatabase.instance.database;
      await db.insert(
        AppConstants.settingsTable,
        {
          'key': AppConstants.nicknameKey,
          'value': nickname,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _photoPath != null
                            ? FileImage(File(_photoPath!))
                            : null,
                        child: _photoPath == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: _pickImage,
                      child: const Text('Change Photo'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      labelText: 'Nickname',
                      hintText: 'Enter your nickname',
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveNickname,
                    child: const Text('Save Profile'),
                  ),
                ],
              ),
            ),
    );
  }
}