import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/config/app_config.dart';
import '../services/odoo_api_service.dart';

class MutabaahDetailItem {
  final String kategori;
  final String aktivitas;
  final bool dilakukan;
  final int skor;
  final String keterangan;

  MutabaahDetailItem({
    required this.kategori,
    required this.aktivitas,
    required this.dilakukan,
    required this.skor,
    required this.keterangan,
  });
}

class MutabaahServerItem {
  final String id;
  final String noReferensi;
  final DateTime tanggal;
  final String sesi;
  final String totalSkor;
  final String status;
  final List<MutabaahDetailItem> rincian;

  MutabaahServerItem({
    required this.id,
    required this.noReferensi,
    required this.tanggal,
    required this.sesi,
    required this.totalSkor,
    required this.status,
    required this.rincian,
  });
}

class MutabaahService {
  MutabaahService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<MutabaahServerItem>> fetchRiwayat({
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
        sessionId = odoo.sessionId ?? sessionId;
        final children = await odoo.getChildren();
        if (children.isNotEmpty) {
          // Prefer siswa_id/student_id
          final first = children.first;
          siswaId = (first['siswa_id'] ?? first['student_id'] ?? first['id'])?.toString();
          final prefs = await SharedPreferences.getInstance();
          if (siswaId != null && siswaId!.isNotEmpty) await prefs.setString('siswa_id', siswaId!);
        }
      } catch (_) {}
    }
    if (sessionId == null || siswaId == null) return [];

    final root = AppConfig.baseUrl.endsWith('/') ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1) : AppConfig.baseUrl;
    final uri = Uri.parse('$root/api/v1/siswa/$siswaId/mutabaah?page=$page&limit=$limit');

    // Build header variants similar to OdooApiService
    final variants = <Map<String, String>>[
      {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer $sessionId',
        'Cookie': 'session_id=$sessionId',
      },
      {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Cookie': 'session_id=$sessionId',
      },
    ];

    http.Response? res;
    for (final h in variants) {
      try {
        // debug masked
        try {
          final auth = h['Authorization'] ?? '-';
          final ck = h['Cookie'] ?? '-';
          print('MutabaahService.fetchRiwayat headers: Authorization=${auth.length > 20 ? auth.substring(0,20) : auth}, Cookie=${ck != '-' ? 'present' : '-'}');
        } catch (_) {}
        res = await _client.get(uri, headers: h);
        if (res.statusCode != 200) {
          // try next variant
          continue;
        }
        final ct = (res.headers['content-type'] ?? '').toLowerCase();
        final txt = res.body.trimLeft();
        final looksHtml = txt.startsWith('<');
        final headerJson = ct.contains('application/json');
        final prefixJson = txt.startsWith('{') || txt.startsWith('[');
        final isPayloadJson = headerJson || prefixJson;
        if (!isPayloadJson || looksHtml) {
          // try next variant
          continue;
        }
        break; // good response
      } catch (_) {
        // try next
        continue;
      }
    }
    if (res == null) {
      throw const FormatException('Tidak ada respons dari server');
    }

    if (res.statusCode != 200) {
      throw Exception('Gagal memuat riwayat mutabaah (${res.statusCode})');
    }

    final contentType = res.headers['content-type'] ?? '';
    final txt = res.body.trimLeft();
    final headerJson = contentType.toLowerCase().contains('application/json');
    final prefixJson = txt.startsWith('{') || txt.startsWith('[');
    if (!(headerJson || prefixJson) || txt.startsWith('<')) {
      throw const FormatException('Server mengembalikan HTML (sesi mungkin invalid)');
    }

    dynamic body;
    try {
      body = json.decode(res.body);
    } catch (_) {
      final snippet = res.body.substring(0, res.body.length > 160 ? 160 : res.body.length);
      throw Exception('Format respons tidak valid: $snippet');
    }

    final List list = (body['data'] as List? ?? []);
    DateTime parseDate(String? s) {
      if (s == null) return DateTime.now();
      try { return DateTime.parse(s); } catch (_) { return DateTime.now(); }
    }

    return list.map<MutabaahServerItem>((raw) {
      final id = (raw['id'] ?? '').toString();
      final noRef = (raw['no_referensi'] ?? '').toString();
      final tanggal = parseDate(raw['tanggal']?.toString());
      final sesi = (raw['sesi'] ?? '').toString();
      final totalSkor = (raw['total_skor'] ?? '').toString();
      final status = (raw['status'] ?? '').toString();
      final rincianList = (raw['rincian'] as List? ?? []).map<MutabaahDetailItem>((d) {
        return MutabaahDetailItem(
          kategori: (d['kategori'] ?? '').toString(),
          aktivitas: (d['aktivitas'] ?? '').toString(),
          dilakukan: d['dilakukan'] == true,
          skor: d['skor'] is int ? d['skor'] as int : int.tryParse('${d['skor'] ?? 0}') ?? 0,
          keterangan: (d['keterangan'] ?? '').toString(),
        );
      }).toList();

      return MutabaahServerItem(
        id: id,
        noReferensi: noRef,
        tanggal: tanggal,
        sesi: sesi,
        totalSkor: totalSkor,
        status: status,
        rincian: rincianList,
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
