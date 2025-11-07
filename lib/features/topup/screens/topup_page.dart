import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/app_styles.dart';
import '../../shared/widgets/custom_app_bar.dart';
import 'topup_confirm_page.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final TextEditingController _amountController = TextEditingController();

  // Quick amounts
  final List<int> _quickAmounts = const [
    50000,
    100000,
    200000,
    300000,
    500000,
    1000000,
  ];
  int? _selectedQuickIndex;

  // Payment methods
  final List<_PaymentMethod> _methods = const [
    _PaymentMethod(id: 'bsi_va', name: 'BSI Virtual Account', subtitle: 'Dicek otomatis', icon: Icons.account_balance),
  ];
  String? _selectedMethodId = 'bsi_va';

  // Dummy current balance (could be fetched from API)
  final int _currentBalance = 2345000;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      // If user types, clear quick selection
      if (_selectedQuickIndex != null) {
        setState(() => _selectedQuickIndex = null);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int get _amountValue {
    final digits = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return int.parse(digits);
  }

  void _setAmount(int value) {
    _amountController.value = TextEditingValue(
      text: _formatRupiah(value),
      selection: TextSelection.collapsed(offset: _formatRupiah(value).length),
    );
  }

  bool get _isFormValid => _amountValue >= 10000 && _selectedMethodId != null; // minimal 10rb

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final themed = baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(fontFamily: 'Poppins'),
    );

    return Theme(
      data: themed,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Top Up'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(),
              const SizedBox(height: 16),
              _buildQuickAmount(),
              const SizedBox(height: 12),
              _buildAmountField(),
              const SizedBox(height: 16),
              _buildPaymentMethods(),
              const SizedBox(height: 90),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildBalanceCard() {
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
            child: const Icon(Icons.account_balance_wallet_outlined, color: AppStyles.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saldo Uang Saku', style: AppStyles.saldoLabel(context)),
                const SizedBox(height: 4),
                Text(_formatRupiah(_currentBalance), style: AppStyles.saldoValue(context).copyWith(fontSize: 20)),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              // refresh saldo
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saldo diperbarui')));
              setState(() {});
            },
            icon: const Icon(Icons.sync, color: AppStyles.primaryColor),
            label: Text('Segarkan', style: TextStyle(color: AppStyles.primaryColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Nominal',
          style: AppStyles.bodyText(context).copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(_quickAmounts.length, (i) {
            final isSelected = _selectedQuickIndex == i;
            return ChoiceChip(
              label: Text(_formatRupiah(_quickAmounts[i])),
              selected: isSelected,
              labelStyle: TextStyle(
                color: isSelected ? AppStyles.primaryColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              selectedColor: AppStyles.primaryColor.withOpacity(0.15),
              side: BorderSide(color: isSelected ? AppStyles.primaryColor : Colors.grey.shade300),
              onSelected: (_) {
                setState(() {
                  _selectedQuickIndex = i;
                  _setAmount(_quickAmounts[i]);
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nominal Top Up',
          style: AppStyles.bodyText(context).copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _RupiahInputFormatter(),
          ],
          decoration: InputDecoration(
                        hintText: '0',
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 6),
        Text(
          'Minimal top up Rp 10.000',
          style: AppStyles.bodyText(context).copyWith(color: Colors.black54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metode Pembayaran',
          style: AppStyles.bodyText(context).copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _methods.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final m = _methods[i];
              final selected = _selectedMethodId == m.id;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
                  child: Icon(m.icon, color: AppStyles.primaryColor),
                ),
                title: Text(m.name, style: AppStyles.bodyText(context).copyWith(fontWeight: FontWeight.w600, color: Colors.black)),
                subtitle: m.subtitle == null ? null : Text(m.subtitle!, style: const TextStyle(fontSize: 12)),
                trailing: Radio<String>(
                  value: m.id,
                  groupValue: _selectedMethodId,
                  activeColor: AppStyles.primaryColor,
                  onChanged: (val) => setState(() => _selectedMethodId = val),
                ),
                onTap: () => setState(() => _selectedMethodId = m.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10 + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Nominal', style: AppStyles.bodyText(context).copyWith(color: Colors.black54)),
                  const SizedBox(height: 2),
                  Text(
                    _formatRupiah(_amountValue),
                    style: AppStyles.saldoValue(context).copyWith(fontSize: 20),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isFormValid
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TopUpConfirmPage(
                            amount: _amountValue,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade600,
              ),
              child: const Text('Lanjut'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRupiah(int amount) {
    final s = amount.toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return 'Rp ${s.replaceAllMapped(reg, (m) => '.')}';
  }
}

class _PaymentMethod {
  final String id;
  final String name;
  final String? subtitle;
  final IconData icon;
  const _PaymentMethod({required this.id, required this.name, this.subtitle, required this.icon});
}

class _RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final value = int.parse(digitsOnly);
    final formatted = _format(value);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _format(int value) {
    final s = value.toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return 'Rp ${s.replaceAllMapped(reg, (m) => '.')}';
  }
}


