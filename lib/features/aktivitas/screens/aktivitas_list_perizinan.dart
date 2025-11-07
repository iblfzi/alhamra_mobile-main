import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/app_styles.dart';
import '../../../core/models/aktivitas_model.dart';
import '../../../core/localization/app_localizations.dart';
import '../screens/aktivitas_detail_page.dart';

class AktivitasListPerizinan extends StatelessWidget {
  final List<AktivitasEntry> entries;
  final String studentName;

  const AktivitasListPerizinan({
    super.key,
    required this.entries,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = entries
        .where((entry) => entry.tipe == AktivitasType.perizinan)
        .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context).tidakAdaDataPerizinan,
            style: const TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        return _buildCard(context, entry);
      },
    );
  }

  Widget _buildCard(BuildContext context, AktivitasEntry entry) {
    final localizations = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Kategori
          Text(
            localizations.statusPerizinan,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const Divider(height: 24),

          // Isi Data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Santri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localizations.pilihSantri, style: TextStyle(color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      studentName,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Tanggal
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(localizations.tanggal, style: TextStyle(color: Colors.black54, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d MMM yyyy', 'id_ID').format(entry.tanggal),
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Judul Aktivitas
          Text(localizations.aktivitas, style: TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            entry.judul,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),

          const SizedBox(height: 16),

          // Tombol Detail
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        AktivitasDetailPage(entry: entry, studentName: studentName),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(localizations.lihatDetail),
            ),
          ),
        ],
      ),
    );
  }
}
