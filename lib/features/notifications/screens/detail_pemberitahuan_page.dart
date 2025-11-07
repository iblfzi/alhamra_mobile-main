import 'package:flutter/material.dart';
import '../../../core/utils/app_styles.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/services/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailPemberitahuanPage extends StatefulWidget {
  final NotificationItem notification;

  const DetailPemberitahuanPage({
    super.key,
    required this.notification,
  });

  @override
  State<DetailPemberitahuanPage> createState() => _DetailPemberitahuanPageState();
}

class _DetailPemberitahuanPageState extends State<DetailPemberitahuanPage> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Mark this specific notification as read when detail page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationService.markAsRead(widget.notification.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF2196F3),
        appBar: CustomAppBar(
          title: 'Detail Pemberitahuan',
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildContent(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.notification.id,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.notification.title,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (widget.notification.amount.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.notification.amount,
              style: GoogleFonts.poppins(
                color: AppStyles.primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            _formatDate(widget.notification.date),
            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Pemberitahuan',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailContent(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailContent() {
    switch (widget.notification.type) {
      case NotificationType.transaksi:
        return _buildTransactionDetail();
      case NotificationType.perijinan:
        return _buildPermissionDetail();
      case NotificationType.pengumuman:
        return _buildAnnouncementDetail();
    }
  }

  Widget _buildTransactionDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Jenis Transaksi', 'Pembayaran'),
        const SizedBox(height: 12),
        _buildDetailRow('Nominal', widget.notification.amount),
        const SizedBox(height: 12),
        _buildDetailRow('Metode Pembayaran', 'Transfer Bank'),
        const SizedBox(height: 12),
        _buildDetailRow('Status Pembayaran', _getStatusText()),
        const SizedBox(height: 16),
        Text(
          'Keterangan:',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pembayaran untuk ${widget.notification.title.toLowerCase()} telah ${_getStatusText().toLowerCase()}. Silakan simpan bukti pembayaran ini untuk keperluan administrasi.',
          style: GoogleFonts.poppins(
            color: Colors.grey.shade700,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Jenis Perijinan', 'Izin Keluar'),
        const SizedBox(height: 12),
        _buildDetailRow('Nama Santri', 'Ahmad Fauzi'),
        const SizedBox(height: 12),
        _buildDetailRow('Tanggal Izin', '10 September 2024'),
        const SizedBox(height: 12),
        _buildDetailRow('Waktu', '08:00 - 17:00 WIB'),
        const SizedBox(height: 12),
        _buildDetailRow('Status', _getStatusText()),
        const SizedBox(height: 16),
        Text(
          'Alasan:',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Keperluan keluarga dan urusan administrasi penting. Santri akan kembali sebelum waktu yang ditentukan.',
          style: GoogleFonts.poppins(
            color: Colors.grey.shade700,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Jenis', 'Pengumuman Umum'),
        const SizedBox(height: 12),
        _buildDetailRow('Berlaku Mulai', '15 April 2024'),
        const SizedBox(height: 12),
        _buildDetailRow('Berlaku Sampai', '17 April 2024'),
        const SizedBox(height: 16),
        Text(
          'Isi Pengumuman:',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Dalam rangka memperingati Hari Raya Idul Fitri 1445 H, pondok pesantren akan libur selama 3 hari. Seluruh kegiatan belajar mengajar diliburkan dan santri diperbolehkan pulang ke rumah masing-masing. Kegiatan akan kembali normal pada tanggal 18 April 2024.',
          style: GoogleFonts.poppins(
            color: Colors.grey.shade700,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          ': ',
          style: GoogleFonts.poppins(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (widget.notification.type == NotificationType.transaksi) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement download receipt
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur unduh bukti pembayaran akan segera tersedia')),
                );
              },
              icon: const Icon(Icons.download, color: Colors.white),
              label: Text(
                'Unduh Bukti Pembayaran',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur bagikan akan segera tersedia')),
                );
              },
              icon: Icon(Icons.share, color: AppStyles.primaryColor),
              label: Text(
                'Bagikan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppStyles.primaryColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppStyles.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatusBadge() {
    switch (widget.notification.status) {
      case NotificationStatus.approved:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Disetujui',
            style: GoogleFonts.poppins(
              color: const Color(0xFF4CAF50),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case NotificationStatus.pending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Menunggu',
            style: GoogleFonts.poppins(
              color: const Color(0xFFFF9800),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case NotificationStatus.rejected:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Ditolak',
            style: GoogleFonts.poppins(
              color: const Color(0xFFF44336),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case NotificationStatus.read:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Dibaca',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case NotificationStatus.unread:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Baru',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1976D2),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
    }
  }

  String _getStatusText() {
    switch (widget.notification.status) {
      case NotificationStatus.approved:
        return 'Disetujui';
      case NotificationStatus.pending:
        return 'Menunggu';
      case NotificationStatus.rejected:
        return 'Ditolak';
      case NotificationStatus.read:
        return 'Dibaca';
      case NotificationStatus.unread:
        return 'Belum Dibaca';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hari ini, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return 'Kemarin, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}

