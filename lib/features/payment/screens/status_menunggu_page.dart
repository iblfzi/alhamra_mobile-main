  import 'package:flutter/material.dart';
import '../../../core/utils/app_styles.dart';
import '../../shared/widgets/status_app_bar.dart';

class StatusMenungguPage extends StatelessWidget {
  final int? amount;
  
  const StatusMenungguPage({super.key, this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StatusAppBar(
        title: 'Seragam Santri',
        onBackPressed: () => Navigator.pop(context),
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
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Menunggu Konfirmasi',
                            style: AppStyles.bodyText(context).copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Date Time
                    Text(
                      '17-09-2025, 23:51 WIB',
                      style: AppStyles.bodyText(context).copyWith(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Invoice Details Card
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
                          _buildDetailRow('ID Invoice', 'INV/083/329383', isBlue: true),
                          const SizedBox(height: 16),
                          _buildDetailRow('Nama Pengirim', 'Muhammad Faithfullah\nIlhamy Azda'),
                          const SizedBox(height: 16),
                          _buildDetailRow('Administrator', 'Diah Al Quwari'),
                          const SizedBox(height: 16),
                          _buildDetailRow('Tgl. Konfirmasi', '18-09-2025'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Detail Pembayaran Expandable
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          'Detail Pembayaran',
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
                                _buildDetailRow('Rekening Pengirim', '3513839289292'),
                                const SizedBox(height: 16),
                                _buildDetailRow('Nominal Pembayaran', amount != null ? 'Rp. ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}' : 'Rp. 1.400.000'),
                                const SizedBox(height: 16),
                                _buildDetailRow('Keterangan', 'SPP 2025'),
                                const SizedBox(height: 16),
                                _buildDetailRow('Nama Santri', 'Naufal Ramadhan'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 120),
                    
                    // Kembali Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
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

  Widget _buildDetailRow(String label, String value, {bool isBlue = false}) {
    return Row(
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
