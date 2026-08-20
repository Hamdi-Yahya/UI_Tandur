import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/auth/presentation/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bootstrap auth: cek token tersimpan sebelum app dimulai.
  // Kalau ada token → router redirect langsung ke /kelas, skip onboarding.
  final container = ProviderContainer();
  await container.read(authControllerProvider.notifier).bootstrap();

  runApp(UncontrolledProviderScope(
    container: container,
    child: const TandurApp(),
  ));
}

class TandurApp extends ConsumerWidget {
  const TandurApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Tandur',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        // Accessibility Foundation: Dukungan text scaling & semantic
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 1.5, // Batasi perbesaran teks agar UI tidak rusak
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
