import 'package:flutter/material.dart';

class KesehatanHistory {
  final String id;
  final DateTime tanggal;
  final String judul;
  final String keterangan;
  final String petugas;

  KesehatanHistory({
    required this.id,
    required this.tanggal,
    required this.judul,
    required this.keterangan,
    required this.petugas,
  });

  Color get color => Colors.green;
}
