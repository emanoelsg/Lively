// screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lively/models/profile_state.dart';
import 'package:lively/providers/profile_provider.dart';

/// Screen for managing user profile (nickname and photo)
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Watch the state and update the controller when profile is loaded
    final profile = ref.read(profileNotifierProvider);
    _nicknameController.text = profile.nickname;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the profile state from the provider
    final profileState = ref.watch(profileNotifierProvider);
    final notifier = ref.read(profileNotifierProvider.notifier);

    // Show a snackbar if there is an error
    ref.listen<ProfileState>(profileNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.errorMessage}')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: notifier.pickAndSaveImage,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: profileState.photoPath != null
                                ? FileImage(File(profileState.photoPath!))
                                : null,
                            child: profileState.photoPath == null
                                ? const Icon(Icons.person, size: 60)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton.icon(
                          onPressed: notifier.pickAndSaveImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Change Photo'),
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _nicknameController,
                        decoration: const InputDecoration(
                          labelText: 'Nickname',
                          hintText: 'Enter your nickname',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          notifier.saveNickname(_nicknameController.text);
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Save Profile'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}