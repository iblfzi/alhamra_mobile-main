import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/app_styles.dart';
import '../../../core/models/bill.dart';
import '../../../core/data/student_data.dart';
import '../../shared/widgets/status_app_bar.dart';

class PaymentData {
  final List<Bill> bills;
  final String studentName;
  final String paymentMethod;
  final String virtualAccount;
  final int totalAmount;
  final DateTime paymentDate;
  final String invoiceId;
  final String senderName;
  final String administrator;

  PaymentData({
    required this.bills,
    required this.studentName,
    required this.paymentMethod,
    required this.virtualAccount,
    required this.totalAmount,
    required this.paymentDate,
    required this.invoiceId,
    required this.senderName,
    required this.administrator,
  });
}

class CustomStatusMenungguPage extends StatefulWidget {
  final PaymentData paymentData;
  
  const CustomStatusMenungguPage({
    super.key,
    required this.paymentData,
  });

  @override
  State<CustomStatusMenungguPage> createState() => _CustomStatusMenungguPageState();
}

class _CustomStatusMenungguPageState extends State<CustomStatusMenungguPage> {
  bool _isPaymentDetailsExpanded = false;
  bool _isBillDetailsExpanded = false;

  String _formatCurrency(int amount) {
    final format = NumberFormat.decimalPattern('id_ID');
    return 'Rp ${format.format(amount)}';
  }

  String _formatDateTime(DateTime dateTime) {
    final format = DateFormat('dd-MM-yyyy, HH:mm');
    return '${format.format(dateTime)} WIB';
  }

  String _getPaymentDescription() {
    if (widget.paymentData.bills.length == 1) {
      return widget.paymentData.bills.first.title;
    } else {
      final types = widget.paymentData.bills.map((bill) => bill.title).toSet().toList();
      if (types.length == 1) {
        return '${types.first} (${widget.paymentData.bills.length} tagihan)';
      } else {
        return 'Pembayaran Multiple (${widget.paymentData.bills.length} tagihan)';
      }
    }
  }

  String _getDetailedPaymentInfo() {
    if (widget.paymentData.bills.length == 1) {
      final bill = widget.paymentData.bills.first;
      return '${bill.title} - ${bill.period}';
    } else {
      final billsByTitle = <String, List<Bill>>{};
      for (final bill in widget.paymentData.bills) {
        billsByTitle.putIfAbsent(bill.title, () => []).add(bill);
      }
      
      final descriptions = <String>[];
      billsByTitle.forEach((title, bills) {
        if (bills.length == 1) {
          descriptions.add('$title - ${bills.first.period}');
        } else {
          final periods = bills.map((b) => b.period).join(', ');
          descriptions.add('$title ($periods)');
        }
      });
      
      return descriptions.join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StatusAppBar(
        title: _getPaymentDescription(),
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
                    
                    // Main Content Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Status Section
                          _buildStatusSection(),
                          
                          const SizedBox(height: 20),
                          
                          // Basic Info Section
                          _buildBasicInfoSection(),
                          
                          const SizedBox(height: 16),
                          
                          // Payment Details Section (Collapsible)
                          _buildCollapsibleSection(
                            title: 'Payment Details',
                            isExpanded: _isPaymentDetailsExpanded,
                            onToggle: () {
                              setState(() {
                                _isPaymentDetailsExpanded = !_isPaymentDetailsExpanded;
                              });
                            },
                            child: _buildPaymentDetailsContent(),
                          ),
                          
                          // Bill Details Section (Collapsible) - Only show if multiple bills
                          if (widget.paymentData.bills.length > 1) ...[
                            const SizedBox(height: 16),
                            _buildCollapsibleSection(
                              title: 'Rincian Tagihan (${widget.paymentData.bills.length} item)',
                              isExpanded: _isBillDetailsExpanded,
                              onToggle: () {
                                setState(() {
                                  _isBillDetailsExpanded = !_isBillDetailsExpanded;
                                });
                              },
                              child: _buildBillDetailsContent(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
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
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      children: [
        // Profile Image
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(
            StudentData.getStudentAvatar(widget.paymentData.studentName),
          ),
        ),
        
        const SizedBox(height: 12),
        
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
              const SizedBox(width: 6),
              Text(
                'Waiting for Confirmation',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Date Time
        Text(
          _formatDateTime(widget.paymentData.paymentDate),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildDetailRow('Invoice ID', widget.paymentData.invoiceId, isHighlight: true),
          const SizedBox(height: 10),
          _buildDetailRow('Sender Name', widget.paymentData.senderName),
          const SizedBox(height: 10),
          _buildDetailRow('Administrator', widget.paymentData.administrator),
          const SizedBox(height: 10),
          _buildDetailRow('Confirmation Date', DateFormat('dd-MM-yyyy').format(widget.paymentData.paymentDate.add(const Duration(days: 1)))),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isExpanded ? null : 0,
            child: isExpanded
                ? Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: child,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsContent() {
    return Column(
      children: [
        const SizedBox(height: 12),
        _buildDetailRow('Payment Method', widget.paymentData.paymentMethod),
        const SizedBox(height: 10),
        _buildDetailRow('Virtual Account', widget.paymentData.virtualAccount),
        const SizedBox(height: 10),
        _buildDetailRow('Payment Amount', _formatCurrency(widget.paymentData.totalAmount), isHighlight: true),
        const SizedBox(height: 10),
        _buildDetailRow('Description', _getDetailedPaymentInfo()),
        const SizedBox(height: 10),
        _buildDetailRow('Student Name', widget.paymentData.studentName),
      ],
    );
  }

  Widget _buildBillDetailsContent() {
    return Column(
      children: [
        const SizedBox(height: 12),
        ...widget.paymentData.bills.asMap().entries.map((entry) {
          final index = entry.key;
          final bill = entry.value;
          return Column(
            children: [
              if (index > 0) const SizedBox(height: 8),
              _buildDetailRow(
                '${bill.title} - ${bill.period}',
                _formatCurrency(bill.outstanding),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isHighlight ? AppStyles.primaryColor : Colors.black87,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
