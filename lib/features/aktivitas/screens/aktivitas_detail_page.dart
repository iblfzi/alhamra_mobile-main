import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/app_styles.dart';
import 'package:alhamra_1/core/data/student_data.dart';
import '../../../core/models/aktivitas_model.dart';
import '../../shared/widgets/status_app_bar.dart';

class AktivitasDetailPage extends StatelessWidget {
  final AktivitasEntry entry;
  final String studentName;

  const AktivitasDetailPage({
    super.key,
    required this.entry,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StatusAppBar(
        title: 'Detail Aktivitas',
        backgroundColor: AppStyles.primaryColor,
        actions: const [], // Menghapus menu/tombol aksi di app bar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar + Nama
            CircleAvatar(
              radius: 40,
              backgroundImage:
                  NetworkImage(StudentData.getStudentAvatar(studentName)),
            ),
            const SizedBox(height: 12),
            Text(
              studentName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 24),
            // Card informasi utama
            _buildSectionCard(
              children: [
                _buildInfoRow("Jenis Aktivitas", entry.tipe.label,
                    valueColor: _getColorForType(entry.tipe)),
                _buildInfoRow(
                  "Tanggal",
                  DateFormat('d MMMM yyyy', 'id_ID').format(entry.tanggal),
                ),
                _buildInfoRow(
                  "Waktu",
                  DateFormat('HH:mm \'WIB\'', 'id_ID').format(entry.tanggal),
                ),
                _buildInfoRow("Dicatat oleh", entry.pencatat),
              ],
            ),

            const SizedBox(height: 24),
            // Card detail aktivitas
            _buildSectionCard(
              children: [
                const Text("Detail Aktivitas",
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 12),
                Text(
                  entry.judul,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.keterangan,
                  style: const TextStyle(color: Colors.black87, height: 1.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Card Section Wrapper
  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // Row Info
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForType(AktivitasType type) {
    switch (type) {
      case AktivitasType.pelanggaran:
        return AppStyles.dangerColor;
      case AktivitasType.perizinan:
        return Colors.orange.shade700;
      case AktivitasType.kesehatan:
        return Colors.green.shade600;
    }
  }
}
