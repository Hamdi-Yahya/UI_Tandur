import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_enums.dart';

/// Profil pengguna dari GET /users/me (API_DOCS bagian 2).
class UserProfile {
  const UserProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.roles = const [],
    this.province,
    this.district,
    this.commodities = const [],
    this.reputation = 0,
    required this.joinedAt,
  });

  final String userId;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final List<Role> roles;
  final String? province;
  final String? district;
  final List<Commodity> commodities;
  final int reputation;
  final DateTime joinedAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => RoleX.fromApi(e?.toString()))
              .toList() ??
          const [],
      province: json['province'] as String?,
      district: json['district'] as String?,
      commodities: (json['commodities'] as List<dynamic>?)
              ?.map((e) => Commodity.fromApi(e?.toString()))
              .toList() ??
          const [],
      reputation: json['reputation'] as int? ?? 0,
      joinedAt: DateTime.tryParse(json['joinedAt'] as String? ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Repository profil pengguna (API_DOCS bagian 2). Semua method melempar
/// [ApiException] yang sudah ternormalisasi; interceptor amplop sudah
/// membuang { msg, data }, jadi `res.data` adalah payload murni.
class UsersRepository {
  UsersRepository(this._dio);

  final Dio _dio;

  /// Profil lengkap pengguna yang sedang masuk.
  Future<UserProfile> getMe() async {
    final res = await guardApi(() => _dio.get('/users/me'));
    return UserProfile.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Perbarui nama, kabupaten, dan komoditas yang diminati. Nilai `null`
  /// tidak dikirim, jadi field yang tidak disertakan tetap.
  Future<UserProfile> updateMe({
    String? fullName,
    String? district,
    List<Commodity>? commodities,
  }) async {
    final res = await guardApi(() => _dio.patch(
          '/users/me',
          data: <String, dynamic>{
            'fullName': ?fullName,
            'district': ?district,
            if (commodities != null)
              'commodities': commodities.map((e) => e.apiValue).toList(),
          },
        ));
    return UserProfile.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Unggah foto profil — multipart, field `file` (API_DOCS bagian 2
  /// Upload Avatar). Mengembalikan URL avatar baru.
  Future<String> uploadAvatar(File file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
        contentType: _avatarContentType(file.path),
      ),
    });
    final res = await guardApi(() => _dio.post('/users/me/avatar', data: form));
    final data = (res.data as Map).cast<String, dynamic>();
    return data['avatarUrl'] as String? ?? '';
  }

  /// Daftarkan perangkat untuk notifikasi push (FCM). `platform` diisi
  /// 'ANDROID' atau 'IOS'.
  Future<void> registerDevice({
    required String fcmToken,
    required String platform,
  }) async {
    await guardApi(() => _dio.post(
          '/users/me/devices',
          data: {'fcmToken': fcmToken, 'platform': platform},
        ));
  }

  /// Jadwalkan penghapusan akun (butuh password). DELETE dengan body
  /// didukung Dio (CATATAN_FE_FLUTTER.md bagian 7).
  Future<void> deleteAccount({required String password}) async {
    await guardApi(() => _dio.delete(
          '/users/me',
          data: {'password': password},
        ));
  }

  static DioMediaType _avatarContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return DioMediaType('image', 'jpeg');
    }
    return DioMediaType('image', 'webp');
  }
}

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository(ref.watch(dioProvider));
});
