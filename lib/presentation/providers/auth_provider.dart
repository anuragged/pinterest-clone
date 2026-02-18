import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication state — anonymous browsing by default.
/// Login required only for: save, create pin, boards.
/// Feed is NEVER blocked by auth state.

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? displayName;
  final String? avatarUrl;
  final String? email;

  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.displayName,
    this.avatarUrl,
    this.email,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? displayName,
    String? avatarUrl,
    String? email,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Sign in (simulated — replace with Clerk integration).
  Future<void> signIn({
    required String displayName,
    String? email,
    String? avatarUrl,
  }) async {
    state = AuthState(
      isAuthenticated: true,
      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      displayName: displayName,
      email: email,
      avatarUrl: avatarUrl,
    );
  }

  /// Sign out.
  void signOut() {
    state = const AuthState();
  }

  /// Check if action requires auth and user is not authenticated.
  bool requiresAuth() => !state.isAuthenticated;
}

// ── Provider ──

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
