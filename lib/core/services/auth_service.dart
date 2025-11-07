import 'dart:convert';
import '../../../core/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'odoo_api_service.dart';

class AuthService {
  final OdooApiService _odooApi = OdooApiService();
  
  // Static user data for testing (fallback)
  static final List<Map<String, dynamic>> _staticUsers = [
    {
      'uid': 'user_001',
      'namaLengkap': 'Ahmad Santoso',
      'jenisKelamin': 'Laki-laki',
      'nomorHp': '081234567890',
      'alamatLengkap': 'Jl. Merdeka No. 123, Jakarta',
      'emailPengguna': 'ahmad@example.com',
      'password': 'flutte',
    },
    {
      'uid': 'user_002',
      'namaLengkap': 'Siti Nurhaliza',
      'jenisKelamin': 'Perempuan',
      'nomorHp': '081234567891',
      'alamatLengkap': 'Jl. Sudirman No. 456, Bandung',
      'emailPengguna': 'siti@example.com',
      'password': 'password456',
    },
    {
      'uid': 'user_003',
      'namaLengkap': 'Budi Prasetyo',
      'jenisKelamin': 'Laki-laki',
      'nomorHp': '081234567892',
      'alamatLengkap': 'Jl. Gatot Subroto No. 789, Surabaya',
      'emailPengguna': 'budi@example.com',
      'password': 'password789',
    },
  ];

  String? _currentUserId;
  UserModel? _currentUserData;
  static const String _currentUserKey = 'current_user_id';
  static const String _currentUserDataKey = 'current_user_data';
  
  // PENTING: Set ke true untuk menggunakan Odoo API
  // Set ke false untuk testing dengan data static
  static const bool _useOdooApi = true;

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    
    if (_useOdooApi) {
      // Login menggunakan Odoo API
      try {
        final result = await _odooApi.login(email, password);
        
        // Create user model from Odoo response
        _currentUserData = UserModel.fromOdoo(result);
        _currentUserId = _currentUserData!.uid;
        
        // Save user data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_currentUserKey, _currentUserId!);
        await prefs.setString(_currentUserDataKey, 
          jsonEncode(_currentUserData!.toMap()));
        
        return UserCredential(_currentUserId!);
      } catch (e) {
        if (e is OdooException) {
          throw 'Login gagal: ${e.message}';
        }
        throw 'Koneksi ke server gagal. Pastikan Anda terhubung ke internet.';
      }
    } else {
      // Fallback to static data for testing
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        final userData = _staticUsers.firstWhere(
          (user) => user['emailPengguna'] == email && user['password'] == password,
        );
        
        _currentUserId = userData['uid'];
        _currentUserData = UserModel.fromMap(userData, userData['uid']);
        
        // Save current user ID to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_currentUserKey, userData['uid']);
        await prefs.setString(_currentUserDataKey, 
          jsonEncode(_currentUserData!.toMap()));
        
        await updateLastLogin(userData['uid']);
        
        return UserCredential(userData['uid']);
      } catch (e) {
        throw 'Email dan password tidak terdaftar';
      }
    }
  }

  // Get user data (use cached login result)
  Future<UserModel?> getUserData(String uid) async {
    // Return cached user data if available
    if (_currentUserData != null && _currentUserData!.uid == uid) {
      return _currentUserData;
    }

    // Try to get from SharedPreferences (populated at login)
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString(_currentUserDataKey);
    if (userDataJson != null) {
      try {
        final userData = jsonDecode(userDataJson) as Map<String, dynamic>;
        _currentUserData = UserModel.fromMap(userData, uid);
        return _currentUserData;
      } catch (_) {
        // ignore parse error and continue
      }
    }

    // Fallback to static data only when not using Odoo API
    if (!_useOdooApi) {
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        final userData = _staticUsers.firstWhere((user) => user['uid'] == uid);
        return UserModel.fromMap(userData, uid);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // Update last login timestamp
  Future<void> updateLastLogin(String uid) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    try {
      final userIndex = _staticUsers.indexWhere((user) => user['uid'] == uid);
      if (userIndex != -1) {
        _staticUsers[userIndex]['lastLogin'] = DateTime.now().toIso8601String();
      }
    } catch (e) {
      // Handle errors silently
    }
  }

  // Sign out
  Future<void> signOut() async {
    if (_useOdooApi) {
      await _odooApi.logout();
    }
    
    _currentUserId = null;
    _currentUserData = null;
    
    // Remove current user data from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    // Also remove legacy key used by AuthProvider
    await prefs.remove('user_token');
    await prefs.remove(_currentUserDataKey);
  }

  // Get current user
  User? getCurrentUser() {
    if (_currentUserId != null) {
      return User(_currentUserId!);
    }
    return null;
  }

  // Initialize current user from SharedPreferences
  Future<void> initializeCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString(_currentUserKey);
    // Fallback to the key used by AuthProvider
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      final legacyId = prefs.getString('user_token');
      if (legacyId != null && legacyId.isNotEmpty) {
        _currentUserId = legacyId;
      }
    }
    
    final userDataJson = prefs.getString(_currentUserDataKey);
    if (userDataJson != null) {
      try {
        final userData = jsonDecode(userDataJson) as Map<String, dynamic>;
        _currentUserData = UserModel.fromMap(userData, _currentUserId ?? '');
      } catch (e) {
        // Failed to parse user data
      }
    }

    // Restore Bearer token for REST calls
    await _odooApi.loadAuthToken();
  }
}

// Simple user credential class to replace Firebase UserCredential
class UserCredential {
  final User? user;
  
  UserCredential(String uid) : user = User(uid);
}

// Simple user class to replace Firebase User
class User {
  final String uid;
  
  User(this.uid);
}

