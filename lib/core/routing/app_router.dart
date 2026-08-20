import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/features/auth/presentation/auth_controller.dart';
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
import 'package:tandur/features/kelas/data/learning_repository.dart';
import 'package:tandur/features/kelas/presentation/screens/quiz_screen.dart';
import 'package:tandur/features/kelas/presentation/screens/quiz_result_screen.dart';
import 'package:tandur/features/kelas/presentation/screens/final_test_screen.dart';
import 'package:tandur/features/kelas/presentation/screens/final_test_result_screen.dart';
import 'package:tandur/features/kelas/presentation/screens/downloaded_screen.dart';
import 'package:tandur/core/presentation/widgets/main_scaffold.dart';
import 'package:tandur/features/periksa/presentation/screens/kamera_periksa_screen.dart';
import 'package:tandur/features/periksa/presentation/screens/hasil_pindai_screen.dart';
import 'package:tandur/features/periksa/presentation/screens/diskusi_screen.dart';
import 'package:tandur/features/periksa/presentation/screens/daftar_tanaman_screen.dart';
import 'package:tandur/features/periksa/presentation/screens/form_tanaman_screen.dart';
import 'package:tandur/features/periksa/presentation/screens/linimasa_tanaman_screen.dart';
import 'package:tandur/features/warung/presentation/screens/daftar_pertanyaan_screen.dart';
import 'package:tandur/features/warung/presentation/screens/buat_pertanyaan_screen.dart';
import 'package:tandur/features/warung/presentation/screens/detail_pertanyaan_screen.dart';
import 'package:tandur/features/warung/presentation/screens/profil_publik_screen.dart';
import 'package:tandur/features/saya/presentation/screens/profil_saya_screen.dart';
import 'package:tandur/features/saya/presentation/screens/ubah_profil_screen.dart';
import 'package:tandur/features/saya/presentation/screens/riwayat_xp_screen.dart';
import 'package:tandur/features/saya/presentation/screens/koleksi_lencana_screen.dart';
import 'package:tandur/features/saya/presentation/screens/notifikasi_screen.dart';
import 'package:tandur/features/saya/presentation/screens/pengaturan_screen.dart';

/// Router utama aplikasi Tandur (Riverpod provider).
/// Aturan navigasi:
/// 1. Punya token (auth.isAuthenticated) -> '/kelas'
/// 2. Tidak punya token, tapi pernah punya akun (auth.hasAccount) -> '/masuk'
/// 3. Tidak punya token dan belum pernah punya akun -> '/onboarding'
final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  return GoRouter(
    initialLocation: auth.isAuthenticated
        ? '/kelas'
        : (auth.hasAccount ? '/masuk' : '/onboarding'),
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // 1. Pengguna sudah login (punya token) -> skip semua layar onboarding & auth
      if (auth.isAuthenticated) {
        if (loc.startsWith('/onboarding') ||
            loc == '/daftar' ||
            loc == '/masuk' ||
            loc == '/lupa-password' ||
            loc == '/atur-ulang-password') {
          return '/kelas';
        }
        return null;
      }

      // 2. Pengguna belum login tapi pernah punya akun -> arahkan ke /masuk, jangan lemparkan ke onboarding
      if (auth.hasAccount) {
        if (loc.startsWith('/onboarding')) {
          return '/masuk';
        }
        // Izinkan halaman autentikasi
        if (loc == '/masuk' ||
            loc == '/daftar' ||
            loc == '/lupa-password' ||
            loc == '/atur-ulang-password') {
          return null;
        }
        // Jika mencoba mengakses rute terproteksi di dalam aplikasi tanpa login, arahkan ke /masuk
        return '/masuk';
      }

      // 3. Pengguna baru (belum pernah punya akun) -> izinkan onboarding & auth
      if (loc.startsWith('/onboarding') ||
          loc == '/daftar' ||
          loc == '/masuk' ||
          loc == '/lupa-password' ||
          loc == '/atur-ulang-password') {
        return null;
      }

      // Akses ke rute dalam tanpa akun diarahkan ke perkenalan (onboarding)
      return '/onboarding';
    },
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
                            correctCount: extra['correctCount'] as int? ?? 0,
                            total: extra['total'] as int? ?? 1,
                            scorePercent: extra['scorePercent'] as int? ?? 0,
                            xpEarned: extra['xpEarned'] as int? ?? 0,
                            results: (extra['results'] as List<ExerciseAnswerResult>?) ?? const [],
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
                            scorePercent: extra['scorePercent'] as int? ?? 0,
                            correctCount: extra['correctCount'] as int? ?? 0,
                            total: extra['total'] as int? ?? 1,
                            xpEarned: extra['xpEarned'] as int? ?? 0,
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
                            scorePercent: extra['scorePercent'] as int? ?? 0,
                            correctCount: extra['correctCount'] as int? ?? 0,
                            total: extra['total'] as int? ?? 1,
                            xpEarned: extra['xpEarned'] as int? ?? 0,
                            stars: extra['stars'] as int? ?? 0,
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
                builder: (context, state) => const KameraPeriksaScreen(),
                routes: [
                  GoRoute(
                    path: 'hasil/:scanId',
                    builder: (context, state) => HasilPindaiScreen(scanId: state.pathParameters['scanId']!),
                  ),
                  GoRoute(
                    path: 'diskusi/:scanId',
                    builder: (context, state) => DiskusiScreen(scanId: state.pathParameters['scanId']!),
                  ),
                  GoRoute(
                    path: 'tanaman',
                    builder: (context, state) => const DaftarTanamanScreen(),
                    routes: [
                      GoRoute(
                        path: 'baru',
                        builder: (context, state) => const FormTanamanScreen(),
                      ),
                      GoRoute(
                        path: ':id',
                        builder: (context, state) => LinimasaTanamanScreen(plantId: state.pathParameters['id']!),
                      ),
                    ],
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
                builder: (context, state) => const DaftarPertanyaanScreen(),
                routes: [
                  GoRoute(
                    path: 'tanya',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      return BuatPertanyaanScreen(
                        fromScanId: extra?['fromScanId'] as String?,
                        initialCommodity: extra?['commodity'] as String?,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'p/:id',
                    builder: (context, state) => DetailPertanyaanScreen(questionId: state.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'pengguna/:id',
                    builder: (context, state) => ProfilPublikScreen(userId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),

          // Tab 4: Saya
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saya',
                builder: (context, state) => const ProfilSayaScreen(),
                routes: [
                  GoRoute(path: 'ubah', builder: (context, state) => const UbahProfilScreen()),
                  GoRoute(path: 'xp', builder: (context, state) => const RiwayatXpScreen()),
                  GoRoute(path: 'lencana', builder: (context, state) => const KoleksiLencanaScreen()),
                  GoRoute(path: 'notifikasi', builder: (context, state) => const NotifikasiScreen()),
                  GoRoute(path: 'pengaturan', builder: (context, state) => const PengaturanScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
