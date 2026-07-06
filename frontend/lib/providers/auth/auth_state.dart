import 'package:artid/domain/models/user.dart';

class AuthState {
  const AuthState({
    this.user,
    this.token,
    this.isGuest = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final User? user;
  final String? token;
  final bool isGuest;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  bool get hasAppAccess => isAuthenticated || isGuest;

  AuthState copyWith({
    User? user,
    bool clearUser = false,
    String? token,
    bool clearToken = false,
    bool? isGuest,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      token: clearToken ? null : (token ?? this.token),
      isGuest: isGuest ?? this.isGuest,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
