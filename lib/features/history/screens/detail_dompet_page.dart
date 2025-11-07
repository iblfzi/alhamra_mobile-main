import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../../../core/models/wallet_history.dart';
import '../../../core/utils/app_styles.dart';

class DetailDompetPage extends StatelessWidget {
  final WalletHistory transaction;
  final ScreenshotController screenshotController = ScreenshotController();
  
  DetailDompetPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final Color accent = _getTransactionColor(transaction.type);
    final String typeText = _getTransactionTypeText(transaction.type);
    final IconData typeIcon = _getTransactionIcon(transaction.type);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppStyles.primaryColor,
              AppStyles.secondaryColor,
            ],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Header (SafeArea)
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            'Detail Riwayat Dompet',
                            style: AppStyles.heading1(context).copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Overlay putih
            Positioned(
              top: 140,
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.22),
                        blurRadius: 28,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Overlay fill (on top of the shadow layer)
            Positioned(
              top: 140,
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                color: const Color(0xFFF2F4F7), // slightly darker off-white for stronger contrast
                elevation: 16,
                shadowColor: Colors.black.withOpacity(0.25),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                clipBehavior: Clip.antiAlias,
                child: const SizedBox.expand(),
              ),
            ),

            // Kartu konten utama
            Positioned(
              top: 90,
              left: 20,
              right: 20,
              bottom: 100,
              child: Screenshot(
                controller: screenshotController,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          
                          // Profile Image
                          const CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: accent.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  typeIcon,
                                  color: accent,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  typeText,
                                  style: AppStyles.bodyText(context).copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Date Time
                          Text(
                            '${DateFormat('dd-MM-yyyy').format(transaction.date)}, 23:51 WIB',
                            style: AppStyles.bodyText(context).copyWith(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Transaction Details Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              children: [
                                _buildDetailRow('ID Transaksi', transaction.id, isBlue: true),
                                const SizedBox(height: 16),
                                _buildDetailRow('Jenis Transaksi', typeText),
                                const SizedBox(height: 16),
                                _buildDetailRow('Tanggal', DateFormat('dd-MM-yyyy').format(transaction.date)),
                                const SizedBox(height: 16),
                                _buildDetailRow('Nominal', _formatCurrency(transaction.amount)),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Detail Transaksi Expandable
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: ExpansionTile(
                              title: Text(
                                'Detail Transaksi',
                                style: AppStyles.bodyText(context).copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                  child: Column(
                                    children: [
                                      _buildDetailRow('Status', typeText),
                                      const SizedBox(height: 16),
                                      _buildDetailRow('Saldo Setelah Transaksi', _formatCurrency(transaction.amount)),
                                      if (transaction.description != null && transaction.description!.isNotEmpty) ...[
                                        const SizedBox(height: 16),
                                        _buildDetailRow('Keterangan', transaction.description!),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ), // Tombol bawah
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 120),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _share(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: accent,
                              side: BorderSide(color: accent, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.share, color: accent, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Bagikan',
                                  style: AppStyles.bodyText(context).copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppStyles.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Kembali',
                              style: AppStyles.bodyText(context).copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    return 'Rp ${NumberFormat('#,###').format(amount)}';
  }

  Widget _buildDetailRow(String label, String value, {bool isBlue = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  void _share(BuildContext context) {
    final String shareText = '''
💼 Detail Transaksi Dompet

📋 Informasi Transaksi:
• ID Transaksi: ${transaction.id}
• Jenis Transaksi: ${_getTransactionTypeText(transaction.type)}
• Tanggal: ${DateFormat('dd-MM-yyyy').format(transaction.date)}
• Nominal: ${_formatCurrency(transaction.amount)}
• Status: ${_getTransactionTypeText(transaction.type)}
${transaction.description != null && transaction.description!.isNotEmpty ? '• Keterangan: ${transaction.description!}\n' : ''}
📅 ${DateFormat('dd-MM-yyyy').format(DateTime.now())}, ${DateFormat('HH:mm').format(DateTime.now())} WIB

Terima kasih telah menggunakan layanan Al-Hamra Mobile! 🙏
    ''';
    
    Share.share(shareText);
  }

  void _showShareBottomSheet(BuildContext parentContext, String shareText) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF2F2F7),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(13),
            topRight: Radius.circular(13),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 6, bottom: 8),
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D1D6),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              // Apps section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildIOSAppIcon(parentContext, Icons.content_copy, 'Salin', Colors.grey[700]!, () {
                        Clipboard.setData(ClipboardData(text: shareText));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          SnackBar(
                            content: const Text('Detail berhasil disalin'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }),
                      _buildIOSAppIcon(parentContext, Icons.message, 'Pesan', Colors.green, () {
                        Navigator.pop(ctx);
                        _showComingSoonDialog(parentContext, 'SMS');
                      }),
                      _buildIOSAppIcon(parentContext, Icons.mail, 'Mail', Colors.blue, () {
                        Navigator.pop(ctx);
                        _showComingSoonDialog(parentContext, 'Email');
                      }),
                    ],
                  ),
                ),
              ),

              // Actions: Save Image / Save PDF
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.image),
                      title: const Text('Simpan sebagai Gambar'),
                      onTap: () {
                        Navigator.pop(ctx);
                        _saveAsImage(parentContext);
                      },
                    ),
                    const Divider(height: 1, indent: 60),
                    ListTile(
                      leading: const Icon(Icons.picture_as_pdf),
                      title: const Text('Simpan sebagai PDF'),
                      onTap: () {
                        Navigator.pop(ctx);
                        _saveAsPDF(parentContext);
                      },
                    ),
                  ],
                ),
              ),
              // Cancel button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAsImage(BuildContext context) async {
    try {
      // Capture the screenshot
      final Uint8List? imageBytes = await screenshotController.capture();
      if (imageBytes == null) {
        throw Exception('Failed to capture screenshot');
      }

      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'dompet_${transaction.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = '${directory.path}/$fileName';

      // Save the image file
      final File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      // Show success dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Berhasil'),
            content: Text('Gambar telah disimpan di:\n$filePath'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Gagal menyimpan gambar: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _saveAsPDF(BuildContext context) async {
    try {
      // Capture the screenshot first
      final Uint8List? imageBytes = await screenshotController.capture();
      if (imageBytes == null) {
        throw Exception('Failed to capture screenshot');
      }

      // Create PDF document
      final pdf = pw.Document();

      // Create PDF image from bytes
      final image = pw.MemoryImage(imageBytes);

      // Add page with the image
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image),
            );
          },
        ),
      );

      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'dompet_${transaction.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = '${directory.path}/$fileName';

      // Save the PDF file
      final File file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Show success dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Berhasil'),
            content: Text('PDF telah disimpan di:\n$filePath'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Gagal menyimpan PDF: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildIOSAppIcon(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: color.withOpacity(0.2), width: 0.5),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Segera Hadir'),
        content: Text('Fitur berbagi via $feature akan segera tersedia.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Color _getTransactionColor(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.topup:
      case WalletTransactionType.refund:
        return AppStyles.primaryColor;
      case WalletTransactionType.payment:
        return Colors.red[600]!;
      case WalletTransactionType.transfer:
        return Colors.orange[600]!;
    }
  }

  String _getTransactionTypeText(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.topup:
        return 'Top Up';
      case WalletTransactionType.payment:
        return 'Pembayaran';
      case WalletTransactionType.transfer:
        return 'Transfer';
      case WalletTransactionType.refund:
        return 'Pengembalian';
    }
  }

  IconData _getTransactionIcon(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.topup:
        return Icons.arrow_downward;
      case WalletTransactionType.payment:
        return Icons.payment;
      case WalletTransactionType.transfer:
        return Icons.swap_horiz;
      case WalletTransactionType.refund:
        return Icons.refresh;
    }
  }

  String _getTransactionMessage(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.topup:
        return 'Dana berhasil ditambahkan ke dompet Anda.';
      case WalletTransactionType.payment:
        return 'Pembayaran telah berhasil diproses.';
      case WalletTransactionType.transfer:
        return 'Transfer dana telah berhasil dilakukan.';
      case WalletTransactionType.refund:
        return 'Dana pengembalian telah masuk ke dompet Anda.';
    }
  }
}
