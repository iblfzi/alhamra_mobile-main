import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/config/app_config.dart';

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  static const String _kSessionKey = 'session_id';
  static const String _kSiswaIdKey = 'siswa_id';

  Future<Map<String, dynamic>> authenticate({
    required String db,
    required String login,
    required String password,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/session/authenticate');
    final res = await _client.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'params': {
          'db': db,
          'login': login,
          'password': password,
        }
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Login gagal: ${res.statusCode} ${res.body}');
    }

    // Ambil session_id dari Set-Cookie
    final setCookie = res.headers['set-cookie'];
    String? sessionId;
    if (setCookie != null) {
      final match = RegExp(r'session_id=([^;]+)').firstMatch(setCookie);
      if (match != null) {
        sessionId = match.group(1);
      }
    }

    final body = json.decode(res.body) as Map<String, dynamic>;
    final result = (body['result'] ?? {}) as Map<String, dynamic>;
    final siswaId = result['siswa_id'];

    final prefs = await SharedPreferences.getInstance();
    if (sessionId != null && sessionId.isNotEmpty) {
      await prefs.setString(_kSessionKey, sessionId);
    }
    if (siswaId != null) {
      await prefs.setString(_kSiswaIdKey, siswaId.toString());
    }

    return {
      'session_id': sessionId,
      'siswa_id': siswaId,
      'result': result,
    };
  }

  static Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kSessionKey);
    }

  static Future<String?> getSiswaId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kSiswaIdKey);
  }
}
