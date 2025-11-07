import 'package:alhamra_1/core/models/student_model.dart';
import 'package:alhamra_1/core/services/odoo_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StudentService {
  final OdooApiService _odooApi = OdooApiService();
  
  static const String _studentsKey = 'cached_students';
  static const bool _useOdooApi = true; // Set false untuk testing dengan data dummy
  
  // Dummy data untuk testing
  static final List<Map<String, dynamic>> _dummyStudents = [
    {
      'id': 1,
      'name': 'Muhammad Fathan Abdillah',
      'nis': '2301012',
      'gender': 'male',
      'class_name': 'Kelas 7A',
    },
    {
      'id': 2,
      'name': 'Muhammad Rafi Afifuddin',
      'nis': '23002010',
      'gender': 'male',
      'class_name': 'Kelas 7B',
    },
    {
      'id': 3,
      'name': 'Ahmad Zaky Mubarak',
      'nis': '23003015',
      'gender': 'male',
      'class_name': 'Kelas 8A',
    },
    {
      'id': 4,
      'name': 'Raisa Anggiani Putri',
      'nis': '23004021',
      'gender': 'female',
      'class_name': 'Kelas 8B',
    },
    {
      'id': 5,
      'name': 'Zahra Nur Azizah',
      'nis': '23005007',
      'gender': 'female',
      'class_name': 'Kelas 9A',
    },
  ];

  /// Get students by parent ID
  Future<List<StudentModel>> getStudentsByParent(int orangtuaId) async {
    if (_useOdooApi) {
      try {
        print('StudentService: Fetching children via REST using Bearer token');

        // Get via REST using Bearer token
        final childrenData = await _odooApi.getChildren();

        print('StudentService: Received ${childrenData.length} children from REST');

        // Normalize REST keys to match StudentModel.fromMap
        final normalized = childrenData.map((data) {
          final map = Map<String, dynamic>.from(data);
          if (map.containsKey('kelas')) {
            map['class_name'] = map['kelas'];
          }
          return map;
        }).toList();

        // Convert to StudentModel list
        final students = normalized
            .map((data) => StudentModel.fromMap(data))
            .toList();
        
        // Cache to SharedPreferences
        await _cacheStudents(students);
        
        if (students.isEmpty) {
          print('StudentService: No students found for this parent');
        }
        
        return students;
      } catch (e) {
        print('StudentService: Error fetching students: $e');
        
        // If error, try to get from cache
        final cachedStudents = await _getCachedStudents();
        if (cachedStudents.isNotEmpty) {
          print('StudentService: Using ${cachedStudents.length} cached students');
          return cachedStudents;
        }
        
        // If no cache, throw error
        throw 'Gagal mengambil data anak: ${e.toString()}';
      }
    } else {
      // Use dummy data for testing
      print('StudentService: Using dummy data (${_dummyStudents.length} students)');
      await Future.delayed(const Duration(milliseconds: 500));
      return _dummyStudents
          .map((data) => StudentModel.fromMap(data))
          .toList();
    }
  }

  /// Cache students to SharedPreferences
  Future<void> _cacheStudents(List<StudentModel> students) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentsJson = students.map((s) => s.toMap()).toList();
      await prefs.setString(_studentsKey, jsonEncode(studentsJson));
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Get cached students from SharedPreferences
  Future<List<StudentModel>> _getCachedStudents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentsJson = prefs.getString(_studentsKey);
      
      if (studentsJson != null) {
        final List<dynamic> decoded = jsonDecode(studentsJson);
        return decoded
            .map((data) => StudentModel.fromMap(data as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Ignore cache errors
    }
    
    return [];
  }

  /// Clear cached students
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_studentsKey);
    } catch (e) {
      // Ignore errors
    }
  }
}
