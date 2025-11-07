import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/config/app_config.dart';
import '../services/odoo_api_service.dart';
import '../models/pelanggaran_history.dart';

class PelanggaranService {
  PelanggaranService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<PelanggaranHistory>> fetchRiwayat({
    String? sessionId,
    String? siswaId,
    int page = 1,
    int limit = 50,
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
        '${AppConfig.baseUrl}/api/v1/siswa/$siswaId/pelanggaran?page=$page&limit=$limit');
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
      throw Exception('Gagal memuat riwayat pelanggaran (${res.statusCode})');
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
    return list.map<PelanggaranHistory>((raw) {
      DateTime parseDate(String? s) {
        if (s == null) return DateTime.now();
        try { return DateTime.parse(s.replaceAll(' ', 'T')); } catch (_) { return DateTime.now(); }
      }

      // Fleksibel: terima beragam nama field dari server
      final id = (raw['id'] ?? '').toString();
      final tanggal = parseDate(raw['tanggal']?.toString() ?? raw['tgl']?.toString());
      final judul = (raw['judul'] ?? raw['pelanggaran'] ?? '').toString();
      final keterangan = (raw['keterangan'] ?? raw['deskripsi'] ?? '').toString();
      final status = (raw['status'] ?? raw['state'] ?? '').toString();
      final pencatat = (raw['pencatat'] ?? raw['petugas'] ?? '').toString();

      return PelanggaranHistory(
        id: id,
        tanggal: tanggal,
        judul: judul,
        keterangan: keterangan,
        status: status,
        pencatat: pencatat,
      );
    }).toList();
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
