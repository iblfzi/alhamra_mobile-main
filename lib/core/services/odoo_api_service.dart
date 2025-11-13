import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/config/odoo_config.dart';

class OdooApiService {
  final String baseUrl;
  final String database;
  String? _sessionId;
  String? _authToken;
  static const String _tokenKey = 'odoo_auth_token';
  static const String _sessionKey = 'odoo_session_id';
  
  OdooApiService({
    String? baseUrl,
    String? database,
  })  : baseUrl = baseUrl ?? OdooConfig.baseUrl,
        database = database ?? OdooConfig.database;

  /// Login ke Server Odoo
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Normalize base URL to avoid double slashes that can cause redirects
      final root = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final url = Uri.parse('$root${OdooConfig.loginEndpoint}');
      
      print('OdooApiService.login: Attempting login to $url');
      
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-Requested-With': 'XMLHttpRequest',
            },
            body: jsonEncode({
              'jsonrpc': '2.0',
              'params': {
                'db': database,
                'login': email,
                'password': password,
              },
            }),
          )
          .timeout(
            Duration(seconds: OdooConfig.timeoutSeconds),
            onTimeout: () {
              print('OdooApiService.login: Request timed out after ${OdooConfig.timeoutSeconds} seconds');
              throw OdooException(
                message: 'Koneksi ke server timeout. Silakan coba lagi.',
                code: 408,
              );
            },
          );

      print('OdooApiService.login: Response status: ${response.statusCode}');
      print('OdooApiService.login: Response headers: ${response.headers}');
      print('OdooApiService.login: Response body (first 200 chars): ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}');

      // Check if response is HTML (which would indicate a login page or error page)
      final contentType = response.headers['content-type']?.toLowerCase() ?? '';
      if (contentType.contains('html')) {
        throw OdooException(
          message: 'Server mengembalikan halaman HTML. Mungkin ada masalah dengan autentikasi atau server sedang dalam pemeliharaan.',
          code: response.statusCode,
        );
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print('OdooApiService.login: Failed to parse JSON response: $e');
        throw OdooException(
          message: 'Format respons tidak valid dari server. Silakan coba lagi nanti.',
          code: response.statusCode,
        );
      }
      
      if (response.statusCode == 200) {
        // cek jika ada respon error (top-level)
        if (data is Map && data['error'] != null) {
          final error = data['error'];
          String errorMessage = 'Login gagal';
          int? errorCode;
          if (error is Map) {
            errorMessage = error['message'] ?? error['data']?['message'] ?? errorMessage;
            errorCode = (error['code'] as int?) ?? (error['data']?['code'] as int?);
          } else if (error is String) {
            errorMessage = error;
          }
          throw OdooException(
            message: errorMessage,
            code: errorCode ?? 400,
          );
        }

        // cek jika ada error di dalam result.error
        if (data is Map && data['result'] is Map && (data['result']['error'] != null)) {
          final rerr = data['result']['error'];
          String errorMessage = 'Login gagal';
          int? errorCode;
          if (rerr is Map) {
            errorMessage = rerr['message'] ?? errorMessage;
            errorCode = rerr['code'] as int?;
          } else if (rerr is String) {
            errorMessage = rerr;
          }
          throw OdooException(
            message: errorMessage,
            code: errorCode ?? 401,
          );
        }

        // Extract session ID dari cookies
        final cookies = response.headers['set-cookie'];
        print('OdooApiService.login: set-cookie header => ${cookies != null ? cookies.substring(0, cookies.length > 120 ? 120 : cookies.length) : 'null'}');
        if (cookies != null) {
          _sessionId = _extractSessionId(cookies);
          print('OdooApiService.login: extracted session_id => ${_sessionId != null ? _sessionId!.substring(0, _sessionId!.length > 8 ? 8 : _sessionId!.length) + '...' : 'null'}');
          if (_sessionId != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_sessionKey, _sessionId!);
          }
        }

        // Extract Bearer token from result if provided by REST API
        final result = data['result'];
        if (result is Map<String, dynamic>) {
          _authToken = _extractToken(result);
          if (_authToken != null && _authToken!.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_tokenKey, _authToken!);
          }
        }

        // Jika tidak ada session cookie dari REST API, fallback ke web authenticate untuk memperoleh session_id
        if (_sessionId == null) {
          print('OdooApiService.login: No session cookie from REST login. Fallback to /web/session/authenticate');
          await _loginWebSession(email, password);
        }
        
        return data['result'] as Map<String, dynamic>;
      } else {
        throw OdooException(
          message: 'Server error: ${response.statusCode}',
          code: response.statusCode,
        );
      }
    } catch (e) {
      if (e is OdooException) {
        rethrow;
      }
      throw OdooException(
        message: 'Connection error: ${e.toString()}',
        code: 0,
      );
    }
  }

  /// Logout dari server oddo
  Future<void> logout() async {
    try {
      // Selalu bersihkan token terlepas dari status session cookie
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_tokenKey);
      } catch (_) {}
      _authToken = null;

      // Jika tidak ada session, tidak perlu memanggil endpoint logout
      if (_sessionId == null) {
        print('OdooApiService: No session cookie to logout');
        return;
      }

      final url = Uri.parse('$baseUrl${OdooConfig.logoutEndpoint}');
      
      print('OdooApiService: Logging out with session: ${_sessionId?.substring(0, 10)}...');
      
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Cookie': 'session_id=$_sessionId',
            },
            body: jsonEncode({
              'jsonrpc': '2.0',
              'params': {},
            }),
          )
          .timeout(
            Duration(seconds: OdooConfig.timeoutSeconds),
          );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Cek jika ada error (session expired is OK for logout)
        if (data['error'] != null) {
          final errorCode = data['error']['code'];
          final errorMessage = data['error']['message'];
          
          // Session expired adalah OK saat logout
          if (errorCode == 100 || errorMessage?.contains('Session') == true) {
            print('OdooApiService: Session already expired (OK for logout)');
          } else {
            print('OdooApiService: Logout error: $errorMessage');
          }
        } else {
          print('OdooApiService: Logout successful');
        }
      }
      
      _sessionId = null;
    } catch (e) {
      // Ignore logout errors, always clear session
      print('OdooApiService: Logout error (ignored): $e');
      _sessionId = null;
    }
  }

  /// Extract session ID from cookie string
  String? _extractSessionId(String cookies) {
    final sessionCookie = cookies.split(';').firstWhere(
          (cookie) => cookie.trim().startsWith('session_id='),
          orElse: () => '',
        );
    
    if (sessionCookie.isNotEmpty) {
      return sessionCookie.split('=')[1];
    }
    return null;
  }

  /// Try several common token key names
  String? _extractToken(Map<String, dynamic> result) {
    final candidates = [
      'token',
      'access_token',
      'accessToken',
      'jwt',
      'bearer',
    ];
    for (final key in candidates) {
      final v = result[key];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
  }

  /// Get students by parent ID (orangtua_id)
  Future<List<Map<String, dynamic>>> getStudents(int orangtuaId) async {
    try {
      final url = Uri.parse('$baseUrl/web/dataset/call_kw');
      
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (_sessionId != null) 'Cookie': 'session_id=$_sessionId',
            },
            body: jsonEncode({
              'jsonrpc': '2.0',
              'method': 'call',
              'params': {
                'model': 'res.partner',
                'method': 'search_read',
                'args': [
                  [
                    ['parent_id', '=', orangtuaId],
                    ['is_student', '=', true],
                  ],
                ],
                'kwargs': {
                  'fields': ['id', 'name', 'nis', 'partner_id', 'gender', 'birth_date', 'class_name', 'avatar_128'],
                },
              },
            }),
          )
          .timeout(
            Duration(seconds: OdooConfig.timeoutSeconds),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check if there's an error in the response
        if (data['error'] != null) {
          throw OdooException(
            message: data['error']['data']['message'] ?? 'Failed to get students',
            code: data['error']['code'],
          );
        }
        
        // Return list of students
        final result = data['result'];
        if (result is List) {
          return List<Map<String, dynamic>>.from(result);
        }
        
        return [];
      } else {
        throw OdooException(
          message: 'Server error: ${response.statusCode}',
          code: response.statusCode,
        );
      }
    } catch (e) {
      if (e is OdooException) {
        rethrow;
      }
      throw OdooException(
        message: 'Connection error: ${e.toString()}',
        code: 0,
      );
    }
  }

  /// REST: Get children for current parent using Bearer token
  Future<List<Map<String, dynamic>>> getChildren() async {
    try {
      if (_authToken == null || _authToken!.isEmpty) {
        // Try load from prefs lazily
        await loadAuthToken();
      }
      if (_sessionId == null || _sessionId!.isEmpty) {
        await loadSession();
      }
      final url = Uri.parse('${baseUrl}api/v1/orangtua/anak');

      // Build headers with dual-auth support
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (_authToken != null && _authToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${_authToken!}';
      } else if (_sessionId != null && _sessionId!.isNotEmpty) {
        // Some backends expect the session_id as Bearer token
        headers['Authorization'] = 'Bearer ${_sessionId!}';
        // Also include Cookie for compatibility with web session checks
        headers['Cookie'] = 'session_id=$_sessionId';
      }

      final response = await http
          .get(
            url,
            headers: headers,
          )
          .timeout(
            Duration(seconds: OdooConfig.timeoutSeconds),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final success = data['success'] == true;
          if (!success && data['error'] != null) {
            throw OdooException(
              message: data['error'].toString(),
              code: 400,
            );
          }
          final items = data['data'];
          if (items is List) {
            return List<Map<String, dynamic>>.from(items);
          }
        }
        return [];
      } else if (response.statusCode == 401) {
        final reason = (_authToken == null || _authToken!.isEmpty)
            ? ((_sessionId == null || _sessionId!.isEmpty)
                ? 'missing token and cookie'
                : 'missing/invalid token from session_id')
            : 'invalid token';
        throw OdooException(message: 'Unauthorized: $reason', code: 401);
      } else {
        final contentPreview = response.body.substring(0, response.body.length > 120 ? 120 : response.body.length);
        print('OdooApiService.getChildren: Non-200 response: ${response.statusCode}, preview: $contentPreview');
        throw OdooException(
          message: 'Server error: ${response.statusCode}',
          code: response.statusCode,
        );
      }
    } catch (e) {
      if (e is OdooException) rethrow;
      throw OdooException(message: 'Connection error: ${e.toString()}', code: 0);
    }
  }

  /// REST: Get detailed student profile by ID
  Future<Map<String, dynamic>> getStudentProfile(int id) async {
    try {
      if (_authToken == null || _authToken!.isEmpty) {
        await loadAuthToken();
      }
      if (_sessionId == null || _sessionId!.isEmpty) {
        await loadSession();
      }
      final url = Uri.parse('${baseUrl}api/v1/siswa/$id/profil');

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (_authToken != null && _authToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${_authToken!}';
      } else if (_sessionId != null && _sessionId!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${_sessionId!}';
        headers['Cookie'] = 'session_id=$_sessionId';
      }

      final response = await http
          .get(url, headers: headers)
          .timeout(Duration(seconds: OdooConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final contentType = (response.headers['content-type'] ?? '').toLowerCase();
        final body = response.body;
        // Guard: some servers return HTML login page with 200 on expired session
        final looksHtml = body.trimLeft().startsWith('<');
        final isJson = contentType.contains('application/json');
        if (!isJson || looksHtml) {
          final preview = body.substring(0, body.length > 120 ? 120 : body.length);
          throw OdooException(message: 'Unexpected non-JSON response (possible login page). Preview: $preview', code: 200);
        }
        final data = jsonDecode(body);
        if (data is Map<String, dynamic>) {
          final success = data['success'] == true;
          if (!success) {
            final err = data['error'] ?? data['message'] ?? 'Failed to get profile';
            throw OdooException(message: err.toString(), code: 400);
          }
          final detail = data['data'];
          if (detail is Map<String, dynamic>) return detail;
        }
        return <String, dynamic>{};
      } else if (response.statusCode == 401) {
        throw OdooException(message: 'Unauthorized', code: 401);
      } else {
        final preview = response.body.substring(0, response.body.length > 120 ? 120 : response.body.length);
        print('OdooApiService.getStudentProfile: Non-200 ${response.statusCode}, preview: $preview');
        throw OdooException(message: 'Server error: ${response.statusCode}', code: response.statusCode);
      }
    } catch (e) {
      if (e is OdooException) {
        rethrow;
      }
      throw OdooException(message: 'Connection error: ${e.toString()}', code: 0);
    }
  }

  /// Load token from SharedPreferences
  Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
  }

  /// Load session_id from SharedPreferences
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString(_sessionKey);
    if (_sessionId == null || _sessionId!.isEmpty) {
      // Fallback to legacy key used elsewhere in the app
      final legacy = prefs.getString('session_id');
      if (legacy != null && legacy.isNotEmpty) {
        _sessionId = legacy;
      }
    }
  }

  /// Manually set token (optional)
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Get current logged in user data
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      if (_authToken == null || _authToken!.isEmpty) {
        await loadAuthToken();
      }
      if (_sessionId == null || _sessionId!.isEmpty) {
        await loadSession();
      }

      final root = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final url = Uri.parse('$root/api/v1/me');

      // Build headers with dual-auth support
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      };

      if (_authToken != null && _authToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $_authToken';
      } else if (_sessionId != null && _sessionId!.isNotEmpty) {
        // Fallback: some backends require Authorization even with cookie; use session_id
        headers['Authorization'] = 'Bearer $_sessionId';
      }
      if (_sessionId != null && _sessionId!.isNotEmpty) {
        // Include Cookie for backends that check web session
        headers['Cookie'] = 'session_id=$_sessionId';
      }

      // Debug: show which auth is used (masked)
      try {
        final at = _authToken != null && _authToken!.isNotEmpty ? (_authToken!.length > 8 ? _authToken!.substring(0,8) : _authToken) : 'null';
        final sid = _sessionId != null && _sessionId!.isNotEmpty ? (_sessionId!.length > 8 ? _sessionId!.substring(0,8) : _sessionId) : 'null';
        print('OdooApiService.getCurrentUser auth: token=${at != 'null' ? at : '-'} cookie=${sid != 'null' ? sid : '-'}');
      } catch (_) {}

      final response = await http
          .get(url, headers: headers)
          .timeout(Duration(seconds: OdooConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final body = response.body;
        final contentType = (response.headers['content-type'] ?? '').toLowerCase();
        final trimmed = body.trimLeft();
        final looksHtml = trimmed.startsWith('<');
        final headerJson = contentType.contains('application/json');
        final prefixJson = trimmed.startsWith('{') || trimmed.startsWith('[');
        final isPayloadJson = headerJson || prefixJson;
        
        if (!isPayloadJson || looksHtml) {
          final preview = body.substring(0, body.length > 120 ? 120 : body.length);
          throw OdooException(
            message: 'Unexpected non-JSON response (possible login page). Preview: $preview',
            code: 200,
          );
        }

        final data = jsonDecode(body);
        if (data is Map<String, dynamic>) {
          final success = data['success'] == true;
          if (!success) {
            final err = data['error'] ?? data['message'] ?? 'Failed to get current user';
            throw OdooException(message: err.toString(), code: 400);
          }
          return data['data'] ?? {};
        }
        return {};
      } else if (response.statusCode == 401) {
        throw OdooException(message: 'Unauthorized: Invalid or expired session', code: 401);
      } else {
        throw OdooException(
          message: 'Server error: ${response.statusCode}',
          code: response.statusCode,
        );
      }
    } catch (e) {
      if (e is OdooException) rethrow;
      throw OdooException(message: 'Connection error: ${e.toString()}', code: 0);
    }
  }

  /// Fallback login ke web endpoint untuk mendapatkan cookie session_id
  Future<void> _loginWebSession(String login, String password) async {
    final url = Uri.parse('$baseUrl/web/session/authenticate');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'jsonrpc': '2.0',
              'params': {
                'db': database,
                'login': login,
                'password': password,
              },
            }),
          )
          .timeout(
            Duration(seconds: OdooConfig.timeoutSeconds),
          );

      final cookies = response.headers['set-cookie'];
      print('OdooApiService._loginWebSession: set-cookie => ${cookies ?? 'null'}');
      if (response.statusCode == 200 && cookies != null) {
        _sessionId = _extractSessionId(cookies);
        if (_sessionId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_sessionKey, _sessionId!);
        }
      }
    } catch (e) {
      // ignore fallback errors
    }
  }

  /// Get current session ID
  String? get sessionId => _sessionId;
  
  /// Check if user is logged in
  bool get isLoggedIn => _sessionId != null;

  /// Check if authorized with token
  bool get isAuthorized => _authToken != null && _authToken!.isNotEmpty;

  /// Clear persisted token
  Future<void> clearAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (_) {}
    _authToken = null;
  }
}

/// Custom exception for Odoo API errors
class OdooException implements Exception {
  final String message;
  final int code;
  
  OdooException({
    required this.message,
    required this.code,
  });
  
  @override
  String toString() => message;
}
