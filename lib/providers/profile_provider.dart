// providers/profile_provider.dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lively/core/constants.dart';
import 'package:lively/core/db/app_database.dart';
import 'package:lively/models/profile_state.dart';
import 'package:lively/providers/event_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref);
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref ref;

  ProfileNotifier(this.ref) : super(ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final db = await AppDatabase.instance.database;
      final results = await db.query(
        AppConstants.settingsTable,
        where: 'key IN (?, ?, ?)',
        whereArgs: [
          AppConstants.nicknameKey,
          AppConstants.profilePhotoPathKey,
          'last_access_date',
        ],
      );

      String? nickname;
      String? photoPath;
      DateTime? lastAccessDate;

      for (final row in results) {
        final key = row['key'] as String;
        final value = row['value'] as String;
        if (key == AppConstants.nicknameKey) {
          nickname = value;
        } else if (key == AppConstants.profilePhotoPathKey) {
          photoPath = value;
        } else if (key == 'last_access_date') {
          lastAccessDate = DateTime.parse(value);
        }
      }
      state = state.copyWith(
        nickname: nickname ?? '',
        photoPath: photoPath,
        isLoading: false,
        lastAccessDate: lastAccessDate,
      );

      await checkAndResetMonthlyData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profile: $e',
      );
    }
  }

  Future<void> checkAndResetMonthlyData() async {
    final now = DateTime.now();
    final lastAccess = state.lastAccessDate;
    final db = await AppDatabase.instance.database;

    if (lastAccess != null &&
        (now.year > lastAccess.year ||
            (now.year == lastAccess.year && now.month > lastAccess.month))) {
      await ref.read(eventNotifierProvider.notifier).clearAllEvents(ref as WidgetRef);
    }

    await db.insert(
      AppConstants.settingsTable,
      {
        'key': 'last_access_date',
        'value': now.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveNickname(String nickname) async {
    try {
      final db = await AppDatabase.instance.database;
      await db.insert(
        AppConstants.settingsTable,
        {
          'key': AppConstants.nicknameKey,
          'value': nickname.trim(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      state = state.copyWith(nickname: nickname.trim());
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to save nickname: $e');
    }
  }

  Future<void> pickAndSaveImage() async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = File('${appDir.path}/$fileName');

      await File(pickedImage.path).copy(savedImage.path);

      if (state.photoPath != null && state.photoPath!.isNotEmpty) {
        try {
          await File(state.photoPath!).delete();
        } catch (_) {}
      }

      final db = await AppDatabase.instance.database;
      await db.insert(
        AppConstants.settingsTable,
        {
          'key': AppConstants.profilePhotoPathKey,
          'value': savedImage.path,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      state = state.copyWith(photoPath: savedImage.path);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to pick image: $e');
    }
  }
}