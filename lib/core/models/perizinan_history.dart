import 'package:flutter/material.dart';

class PerizinanHistory {
  final String id;
  final String name;
  final DateTime tglIjin;
  final DateTime tglKembali;
  final String keperluan;
  final String state;

  PerizinanHistory({
    required this.id,
    required this.name,
    required this.tglIjin,
    required this.tglKembali,
    required this.keperluan,
    required this.state,
  });

  Color get statusColor {
    final s = state.toLowerCase();
    if (s.contains('approve')) return Colors.green;
    if (s.contains('reject') || s.contains('tolak')) return Colors.red;
    if (s.contains('draft') || s.contains('pending')) return Colors.orange;
    return Colors.blueGrey;
  }
}
