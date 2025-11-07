import 'package:alhamra_1/core/utils/app_styles.dart';
import 'package:flutter/material.dart';

class KetentuanLayananPage extends StatelessWidget {
  const KetentuanLayananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.greyColor,
      appBar: AppBar(
        title: const Text('Ketentuan Layanan'),
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
                  Text(
                    'Ketentuan Aplikasi',
                    style: AppStyles.heading2(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Terakhir Diperbarui: 24 Juli 2025',
                    style: AppStyles.bodyText(context)
                        .copyWith(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  _buildTermSection(
                    context,
                    '1. Pendahuluan',
                    'Selamat datang di Mobile Alhamra. Dengan mengakses atau menggunakan aplikasi ini, Anda setuju untuk terikat oleh syarat dan ketentuan ini ("Ketentuan"). Mohon baca dengan cermat sebelum menggunakan Mobile Alhamra.',
                  ),
                  _buildTermSection(
                    context,
                    '2. Penggunaan Aplikasi',
                    'Mobile Alhamra disediakan untuk memfasilitasi informasi akademik, kesantrian, keuangan, dan komunikasi di lingkungan Pesantren. Pengguna dilarang menggunakan aplikasi untuk tujuan ilegal atau tidak sah.',
                  ),
                  _buildTermSection(
                    context,
                    '2.1 Akun Pengguna',
                    'Untuk mengakses fitur tertentu, Anda mungkin diminta untuk membuat akun. Anda bertanggung jawab penuh atas menjaga kerahasiaan kata sandi dan aktivitas yang terjadi di bawah akun Anda.',
                  ),
                  _buildTermSection(
                    context,
                    '2.2 Konten Pengguna',
                    'Anda bertanggung jawab atas konten yang Anda unggah atau kirim melalui aplikasi. Konten yang tidak sesuai dengan etika pesantren atau hukum yang berlaku akan dihapus.',
                  ),
                  _buildTermSection(
                    context,
                    '3. Privasi Data',
                    'Penggunaan data pribadi Anda diatur oleh Kebijakan Privasi kami.',
                  ),
                  _buildTermSection(
                    context,
                    '4. Pembayaran dan Keuangan',
                    'Semua transaksi pembayaran yang dilakukan melalui aplikasi akan mengikuti prosedur yang ditetapkan dan diatur oleh kebijakan keuangan pesantren.',
                  ),
                  _buildTermSection(
                    context,
                    '5. Perubahan Ketentuan',
                    'Kami dapat memperbarui Ketentuan Layanan ini dari waktu ke waktu. Perubahan akan berlaku segera setelah dipublikasikan di aplikasi. Anda bertanggung jawab untuk meninjau Ketentuan secara berkala.',
                  ),
                  _buildTermSection(
                    context,
                    'Kontak',
                    'Jika Anda memiliki pertanyaan tentang Ketentuan Layanan ini, silakan hubungi kami pada bantuan.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppStyles.bodyText(context)
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Text(content,
              style: AppStyles.bodyText(context).copyWith(height: 1.5),
              textAlign: TextAlign.justify),
        ],
      ),
    );
  }
}