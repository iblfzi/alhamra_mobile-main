import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../app/config/app_config.dart';
import '../models/bill.dart';
import '../../app/config/odoo_config.dart';

class PaymentService {
  PaymentService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<Bill>> fetchBillsForSiswa({
    required String sessionId,
    required String siswaId,
    int page = 1,
    int limit = 10,
    String? query,
    BillStatus? status,
    String? period,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/siswa/$siswaId/tagihan').replace(
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
        if (query != null && query.isNotEmpty) 'q': query,
        if (status != null) 'status': _statusToApi(status),
        if (period != null && period.isNotEmpty && period != 'Semua Periode') 'period': period,
      },
    );

    final res = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $sessionId',
        'Cookie': 'session_id=$sessionId',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal memuat tagihan: ${res.statusCode} ${res.reasonPhrase} -> ${res.body}');
    }

    final body = json.decode(res.body) as Map<String, dynamic>;
    final List data = body['data'] as List;

    return data.map<Bill>((raw) {
      final total = (raw['amount_total_signed'] as num).toDouble();
      final residual = (raw['amount_residual_signed'] as num).toDouble();
      final paid = (total - residual).clamp(0, total).toInt();

      final status = residual == 0
          ? BillStatus.paid
          : residual == total
              ? BillStatus.unpaid
              : BillStatus.partial;

      final dateStr = raw['invoice_date'] as String; // YYYY-MM-DD
      final due = DateTime.parse(dateStr);
      final period = _formatPeriod(due);

      // Subtitle berdasarkan database
      String? subtitle;
      switch (OdooConfig.database.toLowerCase()) {
        case 'db_sipp':
          subtitle = 'Tagihan SPP bulanan';
          break;
        case 'db_iuran':
          subtitle = 'Iuran kegiatan/komite';
          break;
        default:
          subtitle = null;
      }

      return Bill(
        id: raw['name'] as String, // nomor invoice sebagai id
        title: raw['name'] as String,
        subtitle: subtitle,
        amount: total.toInt(),
        amountPaid: paid,
        dueDate: due,
        status: status,
        period: period,
      );
    }).toList();
  }

  String _statusToApi(BillStatus s) {
    switch (s) {
      case BillStatus.unpaid:
        return 'not_paid';
      case BillStatus.partial:
        return 'partial';
      case BillStatus.paid:
        return 'paid';
      case BillStatus.pending:
        return 'pending';
    }
  }

  String _formatPeriod(DateTime d) {
    const months = [
      'Januari','Februari','Maret','April','Mei','Juni',
      'Juli','Agustus','September','Oktober','November','Desember'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}
