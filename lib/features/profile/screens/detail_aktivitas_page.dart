import 'package:alhamra_1/core/models/aktivitas_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/app_styles.dart';
import '../../shared/widgets/status_app_bar.dart';

class DetailAktivitasPage extends StatelessWidget {
  final AktivitasEntry aktivitas;

  const DetailAktivitasPage({super.key, required this.aktivitas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StatusAppBar(
        title: 'Detail Aktivitas',
        onBackPressed: () => Navigator.pop(context),
        backgroundColor: aktivitas.tipe.color,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // White Content Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Status Badge
                    _buildStatusBadge(context),
                    
                    const SizedBox(height: 12),
                    
                    // Date Time
                    Text(
                      '${DateFormat('dd-MM-yyyy, HH:mm').format(aktivitas.tanggal)} WIB',
                      style: AppStyles.bodyText(context).copyWith(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Details Card
                    _buildDetailsCard(context),
                    
                    const SizedBox(height: 20),
                    
                    // Keterangan Expandable
                    _buildKeteranganExpandable(context),
                    
                    const SizedBox(height: 80),
                    
                    // Kembali Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Tutup',
                          style: AppStyles.bodyText(context).copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: aktivitas.tipe.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: aktivitas.tipe.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            aktivitas.tipe.icon,
            color: aktivitas.tipe.color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            aktivitas.tipe.label,
            style: AppStyles.bodyText(context).copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: aktivitas.tipe.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildDetailRow('ID Aktivitas', aktivitas.id, isBlue: true),
          const SizedBox(height: 16),
          _buildDetailRow('Judul', aktivitas.judul),
          const SizedBox(height: 16),
          _buildDetailRow('Dicatat oleh', aktivitas.pencatat),
          const SizedBox(height: 16),
          _buildDetailRow('Tanggal Kejadian', DateFormat('dd MMMM yyyy').format(aktivitas.tanggal)),
        ],
      ),
    );
  }

  Widget _buildKeteranganExpandable(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        title: Text(
          'Keterangan Lengkap',
          style: AppStyles.bodyText(context).copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              aktivitas.keterangan,
              style: AppStyles.bodyText(context).copyWith(height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBlue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isBlue ? Colors.blue : Colors.black,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
