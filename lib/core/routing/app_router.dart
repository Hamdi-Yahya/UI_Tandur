import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/features/onboarding/presentation/screens/onboarding_intro_screen.dart';
import 'package:tandur/features/onboarding/presentation/screens/komoditas_screen.dart';
import 'package:tandur/features/onboarding/presentation/screens/pengalaman_screen.dart';
import 'package:tandur/features/auth/presentation/screens/daftar_screen.dart';
import 'package:tandur/features/auth/presentation/screens/masuk_screen.dart';
import 'package:tandur/features/auth/presentation/screens/lupa_password_screen.dart';
import 'package:tandur/features/auth/presentation/screens/atur_ulang_password_screen.dart';
import 'package:tandur/features/kelas/presentation/screens/kelas_map_screen.dart';
import 'package:tandur/features/kelas/presentation/screens/petak_detail_screen.dart';
import 'package:tandur/features/kelas/presentation/screens/unit_detail_screen.dart';
import 'package:tandur/features/kelas/presentation/screens/lesson_screen.dart';
import 'package:tandur/features/kelas/presentation/screens/exercise_screen.dart';
import 'package:tandur/features/kelas/presentation/screens/exercise_result_screen.dart';
import 'package:tandur/features/kelas/presentation/screens/quiz_screen.dart';
import 'package:tandur/features/kelas/presentation/screens/quiz_result_screen.dart';
import 'package:tandur/features/kelas/presentation/screens/final_test_screen.dart';
import 'package:tandur/features/kelas/presentation/screens/final_test_result_screen.dart';
import 'package:tandur/features/kelas/presentation/screens/downloaded_screen.dart';
import 'package:tandur/core/presentation/widgets/main_scaffold.dart';

/// Placeholder untuk route yang belum diimplementasikan.
/// Menampilkan label yang jelas agar debugging mudah.
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6F1),
        elevation: 0,
        title: Text(title),
      ),
      body: Center(
        child: Text(
          '$title\n[Belum diimplementasikan]',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF5C544A)),
        ),
      ),
    );
  }
}

/// Router utama aplikasi Tandur.
/// Route onboarding dan auth sudah terhubung ke screen nyata.
/// Route fitur utama (kelas, periksa, warung, saya) masih placeholder.
final GoRouter appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    // =========== ONBOARDING ===========
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingIntroScreen(),
      routes: [
        GoRoute(
          path: 'komoditas',
          builder: (context, state) => const KomoditasScreen(),
        ),
        GoRoute(
          path: 'pengalaman',
          builder: (context, state) {
            // Terima daftar komoditas yang dipilih dari KomoditasScreen
            final extra = state.extra as Map<String, dynamic>?;
            final commodities =
                (extra?['commodities'] as List<dynamic>?)?.cast<String>() ?? [];
            return PengalamanScreen(selectedCommodities: commodities);
          },
        ),
      ],
    ),

    // =========== AUTENTIKASI ===========
    GoRoute(
      path: '/daftar',
      builder: (context, state) => const DaftarScreen(),
    ),
    GoRoute(
      path: '/masuk',
      builder: (context, state) => const MasukScreen(),
    ),
    GoRoute(
      path: '/lupa-password',
      builder: (context, state) => const LupaPasswordScreen(),
    ),
    GoRoute(
      path: '/atur-ulang-password',
      builder: (context, state) {
        // Token dari deep link query param
        final token = state.uri.queryParameters['token'];
        return AturUlangPasswordScreen(token: token);
      },
    ),

    // =========== FITUR UTAMA (ShellRoute) ===========
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Kelas
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/kelas',
              builder: (context, state) => const KelasMapScreen(),
              routes: [
                GoRoute(
                  path: 'petak/:id',
                  builder: (context, state) => PetakDetailScreen(id: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'unit/:id',
                  builder: (context, state) => UnitDetailScreen(id: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'lesson/:id',
                  builder: (context, state) => LessonScreen(id: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'latihan/:id',
                  builder: (context, state) => ExerciseScreen(id: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'hasil',
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>? ?? {};
                        return ExerciseResultScreen(
                          id: state.pathParameters['id']!,
                          score: extra['score'] as int? ?? 0,
                          total: extra['total'] as int? ?? 1,
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'ujian-unit/:id',
                  builder: (context, state) => QuizScreen(id: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'hasil',
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>? ?? {};
                        return QuizResultScreen(
                          id: state.pathParameters['id']!,
                          score: extra['score'] as int? ?? 0,
                          total: extra['total'] as int? ?? 1,
                          passed: extra['passed'] as bool? ?? false,
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'ujian/:id',
                  builder: (context, state) => FinalTestScreen(id: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'hasil',
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>? ?? {};
                        return FinalTestResultScreen(
                          id: state.pathParameters['id']!,
                          score: extra['score'] as int? ?? 0,
                          total: extra['total'] as int? ?? 1,
                          passed: extra['passed'] as bool? ?? false,
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'unduhan',
                  builder: (context, state) => const DownloadedScreen(),
                ),
              ],
            ),
          ],
        ),

        // Tab 2: Periksa
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/periksa',
              builder: (context, state) => const _PlaceholderScreen(title: 'Periksa Tanaman'),
              routes: [
                GoRoute(
                  path: 'tanaman',
                  builder: (context, state) => const _PlaceholderScreen(title: 'Tanaman Saya'),
                ),
              ],
            ),
          ],
        ),

        // Tab 3: Warung
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/warung',
              builder: (context, state) => const _PlaceholderScreen(title: 'Warung Tani'),
            ),
          ],
        ),

        // Tab 4: Saya
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/saya',
              builder: (context, state) => const _PlaceholderScreen(title: 'Profil Saya'),
            ),
          ],
        ),
      ],
    ),
  ],
);
