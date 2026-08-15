import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

void main() {
  runApp(const ProviderScope(child: TandurApp()));
}

class TandurApp extends StatelessWidget {
  const TandurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tandur',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
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
