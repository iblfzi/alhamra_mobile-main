import 'package:flutter/material.dart';

class PelanggaranHistory {
  final String id;
  final DateTime tanggal;
  final String judul;
  final String keterangan;
  final String status;
  final String pencatat;

  PelanggaranHistory({
    required this.id,
    required this.tanggal,
    required this.judul,
    required this.keterangan,
    required this.status,
    required this.pencatat,
  });

  Color get statusColor {
    final s = status.toLowerCase();
    if (s.contains('selesai') || s.contains('approve')) return Colors.green;
    if (s.contains('proses') || s.contains('pending')) return Colors.orange;
    if (s.contains('tolak') || s.contains('reject')) return Colors.red;
    return Colors.blueGrey;
  }
}
