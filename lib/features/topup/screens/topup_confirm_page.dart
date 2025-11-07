import 'package:flutter/material.dart';
import '../../../core/utils/app_styles.dart';
import '../../shared/widgets/custom_app_bar.dart';
import 'topup_payment_page.dart';

class TopUpConfirmPage extends StatelessWidget {
  const TopUpConfirmPage({super.key, required this.amount});
  final int amount;

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final themed = baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(fontFamily: 'Poppins'),
    );

    return Theme(
      data: themed,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Konfirmasi Top Up'),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(context),
              const SizedBox(height: 16),
              _buildMethodCard(context),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Konfirmasi'),
                        content: Text('Buat kode bayar untuk top up sebesar ${_rupiah(amount)}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Ya, Lanjut'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TopUpPaymentPage(amount: amount),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Buat Kode Bayar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppStyles.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.savings_outlined, color: AppStyles.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nominal Top Up', style: AppStyles.bodyText(context).copyWith(color: Colors.black54)),
                const SizedBox(height: 4),
                Text(_rupiah(amount), style: AppStyles.saldoValue(context).copyWith(fontSize: 20)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
            child: const Icon(Icons.account_balance, color: AppStyles.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BSI Virtual Account', style: AppStyles.bodyText(context).copyWith(fontWeight: FontWeight.w600, color: Colors.black)),
                const SizedBox(height: 2),
                const Text('Pembayaran dicek otomatis'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _rupiah(int amount) {
    final s = amount.toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return 'Rp ${s.replaceAllMapped(reg, (m) => '.')}';
  }
}


