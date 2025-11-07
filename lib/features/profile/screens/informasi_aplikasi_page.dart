import 'package:alhamra_1/core/utils/app_styles.dart';
import 'package:flutter/material.dart';

class InformasiAplikasiPage extends StatelessWidget {
  const InformasiAplikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.greyColor,
      appBar: AppBar(
        title: const Text('Informasi Aplikasi'),
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: AppStyles.getResponsivePadding(context),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppStyles.getCardBorderRadius(context)),
            ),
            child: Padding(
              padding: AppStyles.getResponsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/logo/logoalhamra.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Informasi Aplikasi',
                    style: AppStyles.heading2(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Mobile Alhamra adalah aplikasi terpadu yang dirancang untuk mengoptimalkan pengelolaan dan komunikasi di lingkungan pesantren, menyediakan modul Akademik untuk info nilai, absensi, dan jadwal, modul Kesantrian untuk melacak tahfidz Al-Qur'an, mutaba'ah, perizinan, hingga catatan kesehatan dan pelanggaran santri, modul Keuangan untuk memudahkan pembayaran tagihan, melihat info pembayaran, dan mengelola uang saku, serta modul Profil untuk personalisasi akun dan pengelolaan data anak, semuanya terangkum dalam Beranda yang menyajikan informasi terkini dan berita kegiatan pesantren.",
                    style: AppStyles.bodyText(context).copyWith(height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}