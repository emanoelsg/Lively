// models/profile_state.dart
class ProfileState {
  final String nickname;
  final String? photoPath;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastAccessDate;

  ProfileState({
    this.nickname = '',
    this.photoPath,
    this.isLoading = true,
    this.errorMessage,
    this.lastAccessDate, 
  });

  ProfileState copyWith({
    String? nickname,
    String? photoPath,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastAccessDate, 
  }) {
    return ProfileState(
      nickname: nickname ?? this.nickname,
      photoPath: photoPath ?? this.photoPath,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastAccessDate: lastAccessDate,
    );
  }
}