import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/config/app_config.dart';
import '../../core/services/odoo_api_service.dart';
import '../models/pocket_money_history.dart';

class CanteenService {
  CanteenService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<PocketMoneyHistory>> fetchCanteenTransactions({
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
    if (sessionId == null || siswaId == null) {
      throw Exception('Sesi atau siswa tidak tersedia. Silakan login kembali.');
    }

    final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/siswa/$siswaId/transaksi_kantin?page=$page&limit=$limit');
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
      throw Exception('Gagal memuat transaksi kantin (${res.statusCode})');
    }

    // Guard against HTML response (auth expiry)
    final contentType = res.headers['content-type'] ?? '';
    if (!contentType.toLowerCase().contains('application/json')) {
      final bodyStr = res.body.trimLeft();
      if (bodyStr.startsWith('<!DOCTYPE') || bodyStr.startsWith('<html')) {
        throw const FormatException('Server mengembalikan HTML (kemungkinan sesi tidak valid).');
      }
    }

    late final dynamic body;
    try {
      body = json.decode(res.body);
    } catch (_) {
      final snippet = res.body.substring(0, res.body.length > 120 ? 120 : res.body.length);
      throw Exception('Format respons tidak valid: $snippet');
    }

    final List data = (body['data'] as List? ?? []);
    return data.map<PocketMoneyHistory>((raw) {
      final dateStr = (raw['tanggal'] ?? '').toString();
      DateTime date;
      try {
        date = DateTime.parse(dateStr.replaceAll(' ', 'T'));
      } catch (_) {
        date = DateTime.now();
      }
      final total = ((raw['total_belanja'] as num?) ?? 0).toInt();
      final nomor = (raw['nomor_transaksi'] ?? '').toString();
      // Build details from rincian (if available)
      String? detailSubtitle;
      String? description;
      final rincian = raw['rincian'];
      if (rincian is List) {
        final items = <String>[];
        for (final it in rincian) {
          final nama = (it is Map && it['produk'] != null) ? it['produk'].toString() : null;
          if (nama != null && nama.isNotEmpty) items.add(nama);
        }
        if (items.isNotEmpty) {
          detailSubtitle = items.take(3).join(', ');
          description = 'Nomor: ${nomor.isEmpty ? '-' : nomor} | Items: ${items.join(', ')}';
        }
      }
      return PocketMoneyHistory(
        id: (raw['id'] ?? '').toString(),
        title: 'Pembelian Kantin',
        // Tampilkan ringkas item yang dibeli; fallback ke nomor transaksi atau 'Kantin'
        subtitle: detailSubtitle ?? (nomor.isEmpty ? 'Kantin' : nomor),
        amount: total,
        date: date,
        type: PocketMoneyTransactionType.outgoing,
        description: description,
        bankName: 'Kantin',
      );
    }).toList();
  }

  Future<String?> _getSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('session_id') ?? prefs.getString('odoo_session_id');
    } catch (_) {
      return null;
    }
  }

  Future<String?> _getSiswaId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('siswa_id');
    } catch (_) {
      return null;
    }
  }
}
