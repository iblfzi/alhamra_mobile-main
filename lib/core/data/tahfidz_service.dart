import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/config/app_config.dart';
import '../services/odoo_api_service.dart';

class TahfidzServerItem {
  final String id;
  final DateTime tanggal;
  final String surahName;
  final String? ayatAwalText;
  final String? ayatAkhirText;
  final int? jmlBaris;
  final int? pageAwal;
  final int? pageAkhir;
  final String? nilaiName;
  final String? ustadzName;
  final String? keterangan;
  final String state;

  TahfidzServerItem({
    required this.id,
    required this.tanggal,
    required this.surahName,
    required this.ayatAwalText,
    required this.ayatAkhirText,
    required this.jmlBaris,
    required this.pageAwal,
    required this.pageAkhir,
    required this.nilaiName,
    required this.ustadzName,
    required this.keterangan,
    required this.state,
  });
}

class TahfidzService {
  TahfidzService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<TahfidzServerItem>> fetchRiwayat({
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
        if (siswaId == null && children.isNotEmpty) {
          final firstId = (children.first['siswa_id'] ?? children.first['student_id'] ?? children.first['id'])?.toString();
          if (firstId != null && firstId.isNotEmpty) {
            siswaId = firstId;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('siswa_id', siswaId);
          }
        }
      } catch (_) {}
    }
    if (sessionId == null || siswaId == null) return [];

    final uri = Uri.parse(
        '${AppConfig.baseUrl}/api/v1/siswa/$siswaId/tahfidz?page=$page&limit=$limit');
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
      throw Exception('Gagal memuat riwayat tahfidz (${res.statusCode})');
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
    DateTime parseDate(String? s) {
      if (s == null) return DateTime.now();
      try { return DateTime.parse(s); } catch (_) { return DateTime.now(); }
    }

    String? extractName(dynamic pair) {
      if (pair is List && pair.length >= 2) return pair[1]?.toString();
      return null;
    }

    String? extractAyatText(dynamic pair) {
      if (pair is List && pair.length >= 2) return pair[1]?.toString();
      return null;
    }

    return list.map<TahfidzServerItem>((raw) {
      final id = (raw['id'] ?? '').toString();
      final tanggal = parseDate(raw['tanggal']?.toString());
      final surahName = extractName(raw['surah_id']) ?? '-';
      final ayatAwalText = extractAyatText(raw['ayat_awal']);
      final ayatAkhirText = raw['ayat_akhir'] == false ? null : extractAyatText(raw['ayat_akhir']);
      final jmlBaris = raw['jml_baris'] is int ? raw['jml_baris'] as int : int.tryParse('${raw['jml_baris'] ?? ''}');
      final pageAwal = raw['page_awal'] is int ? raw['page_awal'] as int : int.tryParse('${raw['page_awal'] ?? ''}');
      final pageAkhir = raw['page_akhir'] is int ? raw['page_akhir'] as int : int.tryParse('${raw['page_akhir'] ?? ''}');
      final nilaiName = raw['nilai_id'] == false ? null : extractName(raw['nilai_id']);
      final ustadzName = extractName(raw['ustadz_id']);
      final keterangan = raw['keterangan'] == false ? null : raw['keterangan']?.toString();
      final state = (raw['state'] ?? '').toString();

      return TahfidzServerItem(
        id: id,
        tanggal: tanggal,
        surahName: surahName,
        ayatAwalText: ayatAwalText,
        ayatAkhirText: ayatAkhirText,
        jmlBaris: jmlBaris,
        pageAwal: pageAwal,
        pageAkhir: pageAkhir,
        nilaiName: nilaiName,
        ustadzName: ustadzName,
        keterangan: keterangan,
        state: state,
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
