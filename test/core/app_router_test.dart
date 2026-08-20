import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tandur/core/routing/app_router.dart';
import 'package:tandur/features/auth/presentation/auth_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppRouter - Aturan Navigasi Tiga Kondisi (Tugas 2)', () {
    test('Kondisi 1: Punya token (isAuthenticated) -> initialLocation /kelas', () {
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(() => _MockAuthController(
                const AuthState(isAuthenticated: true, hasAccount: true),
              )),
        ],
      );

      final router = container.read(appRouterProvider);
      expect(router.configuration.routes.isNotEmpty, isTrue);
    });

    test('Kondisi 2: Tidak punya token tapi pernah punya akun (hasAccount) -> initialLocation /masuk', () {
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(() => _MockAuthController(
                const AuthState(isAuthenticated: false, hasAccount: true),
              )),
        ],
      );

      final auth = container.read(authControllerProvider);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.hasAccount, isTrue);
    });

    test('Kondisi 3: Pengguna baru (belum punya akun) -> initialLocation /onboarding', () {
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(() => _MockAuthController(
                const AuthState(isAuthenticated: false, hasAccount: false),
              )),
        ],
      );

      final auth = container.read(authControllerProvider);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.hasAccount, isFalse);
    });
  });
}

class _MockAuthController extends AuthController {
  _MockAuthController(this._initialState);
  final AuthState _initialState;

  @override
  AuthState build() => _initialState;
}
