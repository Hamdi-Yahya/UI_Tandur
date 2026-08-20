import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tandur/core/network/secure_token_store.dart';
import 'package:tandur/features/auth/presentation/auth_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureTokenStore - hasAccount & clear (Tugas 2)', () {
    test('hasAccount awalnya false jika belum pernah disimpan', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final store = SecureTokenStore();

      expect(await store.hasAccount(), isFalse);
    });

    test('saveTokens otomatis menetapkan hasAccount menjadi true', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final store = SecureTokenStore();

      await store.saveTokens(accessToken: 'access123', refreshToken: 'refresh123');

      expect(await store.accessToken(), 'access123');
      expect(await store.refreshToken(), 'refresh123');
      expect(await store.hasAccount(), isTrue);
    });

    test('clear() menghapus token tetapi MEMPERTAHANKAN hasAccount', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final store = SecureTokenStore();

      await store.saveTokens(accessToken: 'access123', refreshToken: 'refresh123');
      expect(await store.hasAccount(), isTrue);

      // Lakukan clear (logout / sesi mati)
      await store.clear();

      // Token harus terhapus
      expect(await store.accessToken(), isNull);
      expect(await store.refreshToken(), isNull);

      // ALASAN PENTING: hasAccount harus TETAP true agar pengguna lama tidak dilempar ke onboarding
      expect(await store.hasAccount(), isTrue);
    });
  });

  group('AuthState & AuthController (Tugas 2)', () {
    test('AuthState copyWith dan default value', () {
      const state = AuthState();
      expect(state.isAuthenticated, isFalse);
      expect(state.hasAccount, isFalse);

      final updated = state.copyWith(isAuthenticated: true, hasAccount: true);
      expect(updated.isAuthenticated, isTrue);
      expect(updated.hasAccount, isTrue);
    });

    test('signout mempertahankan hasAccount: true', () {
      const state = AuthState(isAuthenticated: false, hasAccount: true);
      expect(state.hasAccount, isTrue);
      expect(state.isAuthenticated, isFalse);
    });
  });
}
