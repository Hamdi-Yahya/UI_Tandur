import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/auth_repository.dart';

/// Status autentikasi aplikasi.
class AuthState {
  const AuthState({
    this.userId,
    this.fullName,
    this.roles = const [],
    this.isNewUser = false,
    this.isAuthenticated = false,
    this.hasAccount = false,
    this.isLoading = false,
  });

  final String? userId;
  final String? fullName;
  final List<String> roles;
  final bool isNewUser;
  final bool isAuthenticated;
  final bool hasAccount;
  final bool isLoading;

  bool get isAdmin => roles.contains('ADMIN');
  bool get isModerator => roles.contains('MODERATOR');

  AuthState copyWith({
    String? userId,
    String? fullName,
    List<String>? roles,
    bool? isNewUser,
    bool? isAuthenticated,
    bool? hasAccount,
    bool? isLoading,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      roles: roles ?? this.roles,
      isNewUser: isNewUser ?? this.isNewUser,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasAccount: hasAccount ?? this.hasAccount,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// State setelah logout / sesi mati.
  static const empty = AuthState();
}

/// Controller autentikasi. Memegang sesi aktif dan menyingkronkan token ke
/// SecureTokenStore. Saat refresh gagal, AuthInterceptor membersihkan token
/// dan status otomatis jadi tidak terautentikasi saat aplikasi membaca ulang.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final session = await ref.read(authRepositoryProvider).signup(
            fullName: fullName,
            email: email,
            password: password,
          );
      await ref.read(authRepositoryProvider).session(session: session);
      state = AuthState(
        userId: session.userId,
        fullName: session.fullName,
        roles: session.roles,
        isNewUser: session.isNewUser,
        isAuthenticated: true,
        hasAccount: true,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signin({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    try {
      final session = await ref.read(authRepositoryProvider).signin(
            email: email,
            password: password,
          );
      await ref.read(authRepositoryProvider).session(session: session);
      state = AuthState(
        userId: session.userId,
        fullName: session.fullName,
        roles: session.roles,
        isNewUser: session.isNewUser,
        isAuthenticated: true,
        hasAccount: true,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signInWithGoogle({required String idToken}) async {
    state = state.copyWith(isLoading: true);
    try {
      final session = await ref.read(authRepositoryProvider).signInWithGoogle(idToken: idToken);
      await ref.read(authRepositoryProvider).session(session: session);
      state = AuthState(
        userId: session.userId,
        fullName: session.fullName,
        roles: session.roles,
        isNewUser: session.isNewUser,
        isAuthenticated: true,
        hasAccount: true,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signout() async {
    await ref.read(authRepositoryProvider).logout();
    // Setelah keluar akun, pengguna tetap ditandai pernah memiliki akun (hasAccount: true)
    // agar diarahkan ke layar /masuk saat membuka aplikasi lagi, bukan mengulang perkenalan.
    state = const AuthState(hasAccount: true);
  }

  /// Pulihkan sesi saat aplikasi dibuka (token masih tersimpan).
  Future<void> bootstrap() async {
    final storage = ref.read(secureTokenStoreProvider);
    final access = await storage.accessToken();
    final refresh = await storage.refreshToken();
    final hasAcc = await storage.hasAccount();
    final isAuth = access != null && refresh != null;
    state = AuthState(
      isAuthenticated: isAuth,
      hasAccount: hasAcc || isAuth, // Jika punya token aktif, pasti pernah punya akun
      isLoading: false,
    );
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);