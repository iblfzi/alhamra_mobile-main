import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/config/app_config.dart';
import '../services/odoo_api_service.dart';
import '../models/perizinan_history.dart';

class PerizinanService {
  PerizinanService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<PerizinanHistory>> fetchRiwayat({
    String? sessionId,
    String? siswaId,
    int page = 1,
    int limit = 20,
  }) async {
    sessionId ??= await _getSessionId();
    siswaId ??= await _getSiswaId();
    if (sessionId == null || siswaId == null) {
      try {
        final odoo = OdooApiService();
        await odoo.loadSession();
        sessionId = odoo.sessionId;
        final children = await odoo.getChildren();
        if (children.isNotEmpty) {
          siswaId = children.first['id']?.toString();
          final prefs = await SharedPreferences.getInstance();
          if (siswaId != null) await prefs.setString('siswa_id', siswaId);
        }
      } catch (_) {}
    }
    if (sessionId == null || siswaId == null) return [];

    final uri = Uri.parse(
        '${AppConfig.baseUrl}/api/v1/siswa/$siswaId/perizinan?page=$page&limit=$limit');
    final res = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $sessionId',
        'Cookie': 'session_id=$sessionId',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal memuat riwayat perizinan (${res.statusCode})');
    }

    final contentType = res.headers['content-type'] ?? '';
    if (!contentType.toLowerCase().contains('application/json')) {
      final txt = res.body.trimLeft();
      if (txt.startsWith('<!DOCTYPE') || txt.startsWith('<html')) {
        throw const FormatException('Server mengembalikan HTML (sesi mungkin invalid)');
      }
    }

    dynamic body;
    try {
      body = json.decode(res.body);
    } catch (_) {
      final snippet = res.body.substring(0, res.body.length > 160 ? 160 : res.body.length);
      throw Exception('Format respons tidak valid: $snippet');
    }

    final List list = (body['data'] as List? ?? []);
    return list.map<PerizinanHistory>((raw) {
      DateTime parseDate(String? s) {
        if (s == null) return DateTime.now();
        try { return DateTime.parse(s); } catch (_) { return DateTime.now(); }
      }
      return PerizinanHistory(
        id: (raw['id'] ?? '').toString(),
        name: (raw['name'] ?? '').toString(),
        tglIjin: parseDate(raw['tgl_ijin']?.toString()),
        tglKembali: parseDate(raw['tgl_kembali']?.toString()),
        keperluan: (raw['keperluan'] ?? '').toString(),
        state: (raw['state'] ?? '').toString(),
      );
    }).toList();
  }

  /// Ajukan perizinan baru untuk siswa
  Future<PerizinanHistory?> submitPerizinan({
    String? sessionId,
    String? siswaId,
    required String keperluan,
    required String penjemput,
    required DateTime tglIjin,
    required DateTime tglKembali,
  }) async {
    sessionId ??= await _getSessionId();
    siswaId ??= await _getSiswaId();
    if (sessionId == null || siswaId == null) {
      // Coba sinkronisasi sesi dan siswa dari OdooApiService
      try {
        final odoo = OdooApiService();
        await odoo.loadSession();
        sessionId = odoo.sessionId;
        final children = await odoo.getChildren();
        if (children.isNotEmpty) {
          siswaId = (children.first['id'] ?? children.first['siswa_id'])?.toString();
          final prefs = await SharedPreferences.getInstance();
          if (siswaId != null) await prefs.setString('siswa_id', siswaId);
        }
      } catch (_) {}
    }
    if (sessionId == null || siswaId == null) {
      throw Exception('Sesi atau siswa tidak tersedia untuk mengajukan perizinan');
    }

    final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/siswa/$siswaId/perizinan');
    final payload = <String, dynamic>{
      'keperluan': keperluan,
      'penjemput': penjemput,
      'tgl_ijin': _fmtDate(tglIjin),
      'tgl_kembali': _fmtDate(tglKembali),
    };

    final res = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $sessionId',
        'Cookie': 'session_id=$sessionId',
      },
      body: json.encode(payload),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gagal mengajukan perizinan (${res.statusCode})');
    }

    dynamic body;
    try {
      body = json.decode(res.body);
    } catch (_) {
      final snippet = res.body.substring(0, res.body.length > 160 ? 160 : res.body.length);
      throw Exception('Format respons tidak valid: $snippet');
    }
    final success = body['success'] == true;
    if (!success) {
      final msg = body['error'] ?? body['message'] ?? 'Pengajuan perizinan gagal';
      throw Exception(msg.toString());
    }
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      DateTime parseDate(String? s) {
        if (s == null) return DateTime.now();
        try { return DateTime.parse(s); } catch (_) { return DateTime.now(); }
      }
      return PerizinanHistory(
        id: (data['id'] ?? '').toString(),
        name: (data['name'] ?? '').toString(),
        tglIjin: parseDate(data['tgl_ijin']?.toString()),
        tglKembali: parseDate(data['tgl_kembali']?.toString()),
        keperluan: (data['keperluan'] ?? '').toString(),
        state: (data['state'] ?? '').toString(),
      );
    }
    // Jika API mengembalikan array atau tidak ada data detail, kembalikan null
    return null;
  }

  String _fmtDate(DateTime d) {
    // yyyy-MM-dd
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<String?> _getSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('session_id') ?? prefs.getString('odoo_session_id');
    } catch (_) { return null; }
  }

  Future<String?> _getSiswaId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('siswa_id');
    } catch (_) { return null; }
  }
}
