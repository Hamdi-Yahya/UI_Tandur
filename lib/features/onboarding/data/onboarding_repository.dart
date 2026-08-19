import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_enums.dart';

/// Slide perkenalan dari GET /api/onboarding (API_DOCS bagian 2).
class OnboardingSlide {
  const OnboardingSlide({
    required this.key,
    required this.title,
    required this.body,
    this.illustration,
  });

  final String key;
  final String title;
  final String body;
  final String? illustration;

  factory OnboardingSlide.fromJson(Map<String, dynamic> json) {
    return OnboardingSlide(
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      illustration: json['illustration'] as String?,
    );
  }
}

/// Komoditas yang ditawarkan saat onboarding.
class OnboardingCommodity {
  const OnboardingCommodity({
    required this.commodity,
    required this.name,
    this.cycleDays,
    this.minUnit,
    this.estCapitalIdr,
    this.iconUrl,
  });

  final Commodity commodity;
  final String name;
  final int? cycleDays;
  final String? minUnit;
  final int? estCapitalIdr;
  final String? iconUrl;

  factory OnboardingCommodity.fromJson(Map<String, dynamic> json) {
    return OnboardingCommodity(
      commodity: Commodity.fromApi(json['commodity'] as String?),
      name: json['name'] as String? ?? '',
      cycleDays: json['cycleDays'] as int?,
      minUnit: json['minUnit'] as String?,
      estCapitalIdr: json['estCapitalIdr'] as int?,
      iconUrl: json['iconUrl'] as String?,
    );
  }
}

/// Konten onboarding lengkap dari GET /api/onboarding.
class OnboardingContent {
  const OnboardingContent({required this.slides, required this.commodities});

  final List<OnboardingSlide> slides;
  final List<OnboardingCommodity> commodities;

  factory OnboardingContent.fromJson(Map<String, dynamic> json) {
    return OnboardingContent(
      slides: (json['slides'] as List<dynamic>?)
              ?.map((e) => OnboardingSlide.fromJson((e as Map).cast<String, dynamic>()))
              .toList() ??
          const [],
      commodities: (json['commodities'] as List<dynamic>?)
              ?.map(
                (e) => OnboardingCommodity.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList() ??
          const [],
    );
  }
}

/// Hasil penyimpanan preferensi dari POST /api/onboarding/complete.
class CompleteOnboardingResult {
  const CompleteOnboardingResult({required this.startRoute, this.suggestedLevelId});

  final String startRoute;
  final String? suggestedLevelId;

  factory CompleteOnboardingResult.fromJson(Map<String, dynamic> json) {
    return CompleteOnboardingResult(
      startRoute: json['startRoute'] as String? ?? '',
      suggestedLevelId: json['suggestedLevelId'] as String?,
    );
  }
}

/// Repository onboarding. `getContent` publik tanpa auth (extra 'public'),
/// `completeOnboarding` butuh Bearer — Idempotency-Key otomatis dari
/// IdempotencyInterceptor (CATATAN_FE_FLUTTER.md 2.3).
class OnboardingRepository {
  OnboardingRepository(this._dio);

  final Dio _dio;

  Future<OnboardingContent> getContent() async {
    final res = await guardApi(() => _dio.get(
          '/onboarding',
          options: Options(extra: {'public': true}),
        ));
    return OnboardingContent.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<CompleteOnboardingResult> completeOnboarding({
    required List<String> commodities,
    required bool hasFarmed,
    String? district,
    String? province,
  }) async {
    final res = await guardApi(() => _dio.post(
          '/onboarding/complete',
          data: {
            'commodities': commodities,
            'hasFarmed': hasFarmed,
            'district': ?district,
            'province': ?province,
          },
        ));
    return CompleteOnboardingResult.fromJson((res.data as Map).cast<String, dynamic>());
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(ref.watch(dioProvider));
});
