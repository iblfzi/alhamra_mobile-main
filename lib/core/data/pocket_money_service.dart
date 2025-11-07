import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/config/app_config.dart';
import '../../core/services/odoo_api_service.dart';
import '../models/pocket_money_history.dart';

class PocketMoneyService {
  PocketMoneyService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<PocketMoneyHistory>> fetchTransactions({
    String? sessionId,
    String? siswaId,
    int page = 1,
    int limit = 50,
  }) async {
    sessionId ??= await _getSessionId();
    siswaId ??= await _getSiswaId();
    if (sessionId == null || siswaId == null) {
      // Fallback: try to refresh session and derive siswaId from children
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

    final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/siswa/$siswaId/uang_saku?page=$page&limit=$limit');
    final res = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $sessionId',
        // Many endpoints also require cookie even with Bearer; harmless if not needed
        'Cookie': 'session_id=$sessionId',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal memuat riwayat uang saku (${res.statusCode})');
    }

    // Ensure JSON; some servers return HTML on auth errors
    try {
      final contentType = res.headers['content-type'] ?? '';
      if (!contentType.toLowerCase().contains('application/json')) {
        // try JSON anyway; otherwise throw a readable error
        if (res.body.trimLeft().startsWith('<!DOCTYPE') || res.body.trimLeft().startsWith('<html')) {
          throw const FormatException('Server mengembalikan HTML (kemungkinan sesi tidak valid).');
        }
      }
    } catch (_) {}

    late final dynamic body;
    try {
      body = json.decode(res.body);
    } catch (e) {
      throw Exception('Format respons tidak valid: ${res.body.substring(0, res.body.length > 120 ? 120 : res.body.length)}');
    }
    final List data = (body['data'] as List? ?? []);

    return data.map<PocketMoneyHistory>((raw) {
      final jns = (raw['jns_transaksi'] ?? '').toString().toLowerCase();
      final isIncoming = jns == 'masuk';
      final amount = isIncoming
          ? ((raw['amount_in'] as num?) ?? 0).toInt()
          : ((raw['amount_out'] as num?) ?? 0).toInt();

      String? ket;
      final keterangan = raw['keterangan'];
      if (keterangan is String) {
        ket = keterangan;
      } else {
        ket = null;
      }

      final dateStr = (raw['tgl_transaksi'] ?? '').toString();
      DateTime date;
      try {
        date = DateTime.parse(dateStr.replaceAll(' ', 'T'));
      } catch (_) {
        date = DateTime.now();
      }

      return PocketMoneyHistory(
        id: (raw['id'] ?? '').toString(),
        title: isIncoming ? 'Dana Masuk' : 'Pengeluaran',
        // Tampilkan detail penggunaan sebagai subtitle jika tersedia
        subtitle: ket ?? (isIncoming ? 'Uang Saku' : 'Uang Saku'),
        amount: amount,
        date: date,
        type: isIncoming ? PocketMoneyTransactionType.incoming : PocketMoneyTransactionType.outgoing,
        description: ket,
        bankName: 'Uang Saku',
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
