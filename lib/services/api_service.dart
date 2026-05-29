import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_prefs.dart';

const _kTimeout = Duration(seconds: 15);

/// Oturum sona erdiğinde (refresh başarısız) yayınlanır.
/// Dinleyenler login sayfasına yönlendirebilir.
final sessionExpiredStream = StreamController<void>.broadcast();

/// Uygulama genelinde kullanılan HTTP istemcisi.
/// Access token süresi dolduğunda refresh token ile otomatik yenileme yapar.
class ApiService {
  // Android emülatör için host makinesi adresi 10.0.2.2'dir.
  // Gerçek cihaz veya üretim için bu değeri değiştirin.
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await AppPrefs.getAccessToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  static Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    var res = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(auth: auth),
          body: jsonEncode(body),
        )
        .timeout(_kTimeout);
    if (res.statusCode == 401 && auth) {
      if (await _refreshTokens()) {
        res = await http
            .post(
              Uri.parse('$baseUrl$path'),
              headers: await _headers(auth: auth),
              body: jsonEncode(body),
            )
            .timeout(_kTimeout);
      }
    }
    return res;
  }

  static Future<http.Response> get(String path) async {
    var res = await http
        .get(Uri.parse('$baseUrl$path'), headers: await _headers())
        .timeout(_kTimeout);
    if (res.statusCode == 401) {
      if (await _refreshTokens()) {
        res = await http
            .get(Uri.parse('$baseUrl$path'), headers: await _headers())
            .timeout(_kTimeout);
      }
    }
    return res;
  }

  static Future<http.Response> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    var res = await http
        .put(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
          body: jsonEncode(body),
        )
        .timeout(_kTimeout);
    if (res.statusCode == 401) {
      if (await _refreshTokens()) {
        res = await http
            .put(
              Uri.parse('$baseUrl$path'),
              headers: await _headers(),
              body: jsonEncode(body),
            )
            .timeout(_kTimeout);
      }
    }
    return res;
  }

  static Future<http.Response> delete(String path) async {
    var res = await http
        .delete(Uri.parse('$baseUrl$path'), headers: await _headers())
        .timeout(_kTimeout);
    if (res.statusCode == 401) {
      if (await _refreshTokens()) {
        res = await http
            .delete(Uri.parse('$baseUrl$path'), headers: await _headers())
            .timeout(_kTimeout);
      }
    }
    return res;
  }

  /// Access token'ı refresh token ile yeniler.
  /// Başarısız olursa yerel oturum verilerini temizler.
  static Future<bool> _refreshTokens() async {
    final refreshToken = await AppPrefs.getRefreshToken();
    if (refreshToken == null) {
      await _clearSession();
      return false;
    }

    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(_kTimeout);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        await AppPrefs.setAccessToken(data['accessToken'] as String);
        return true;
      }
    } catch (_) {}

    await _clearSession();
    sessionExpiredStream.add(null); // Dinleyicileri uyar
    return false;
  }

  static Future<void> _clearSession() async {
    await AppPrefs.setAccessToken(null);
    await AppPrefs.setRefreshToken(null);
    await AppPrefs.setLoggedIn(false);
  }
}
