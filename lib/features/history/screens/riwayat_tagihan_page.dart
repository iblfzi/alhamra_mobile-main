import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/app_styles.dart';
import '../../../core/models/bill.dart';
import '../../../core/localization/app_localizations.dart';
import 'detail_tagihan_page.dart';
import '../../shared/widgets/history_filter_widget.dart';

class RiwayatTagihanPage extends StatefulWidget {
  const RiwayatTagihanPage({super.key});

  @override
  State<RiwayatTagihanPage> createState() => _RiwayatTagihanPageState();
}

class _RiwayatTagihanPageState extends State<RiwayatTagihanPage> {
  
  // Filter state variables
  String _selectedSortOrder = 'Terbaru';
  DateTime? _startDate;
  DateTime? _endDate;
  final Map<String, bool> _categoryFilters = {
    'SPP': true,
    'Seragam': true,
    'Makan': true,
    'Buku': true,
    'Kegiatan': true,
    'Lainnya': true,
  };
  
  // Sample bill data with varied content
  final List<Bill> _allBills = [
    Bill(
      id: 'INV/083/329382',
      title: 'Seragam Sekolah XL Kelas 12',
      subtitle: 'Tenggat Bayar : 22 Juli 2025, 23:59 WIB',
      amount: 1200000,
      dueDate: DateTime(2025, 7, 22, 23, 59),
      status: BillStatus.paid,
      period: 'Juli 2025',
    ),
    Bill(
      id: 'INV/084/329383',
      title: 'SPP Bulan Agustus 2025',
      subtitle: 'Tenggat Bayar : 15 Agustus 2025, 23:59 WIB',
      amount: 850000,
      dueDate: DateTime(2025, 8, 15, 23, 59),
      status: BillStatus.unpaid,
      period: 'Agustus 2025',
    ),
    Bill(
      id: 'INV/085/329384',
      title: 'Makan Siang Bulan Juli',
      subtitle: 'Tenggat Bayar : 30 Juli 2025, 23:59 WIB',
      amount: 450000,
      dueDate: DateTime(2025, 7, 30, 23, 59),
      status: BillStatus.paid,
      period: 'Juli 2025',
    ),
    Bill(
      id: 'INV/086/329385',
      title: 'Buku Pelajaran Semester 1',
      subtitle: 'Tenggat Bayar : 10 Agustus 2025, 23:59 WIB',
      amount: 750000,
      dueDate: DateTime(2025, 8, 10, 23, 59),
      status: BillStatus.unpaid,
      period: 'Agustus 2025',
    ),
    Bill(
      id: 'INV/087/329386',
      title: 'Kegiatan Ekstrakurikuler',
      subtitle: 'Tenggat Bayar : 25 Juli 2025, 23:59 WIB',
      amount: 300000,
      dueDate: DateTime(2025, 7, 25, 23, 59),
      status: BillStatus.paid,
      period: 'Juli 2025',
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  String _getBillCategory(Bill bill) {
    final t = bill.title.toLowerCase();
    if (t.contains('spp')) return 'SPP';
    if (t.contains('seragam')) return 'Seragam';
    if (t.contains('makan')) return 'Makan';
    if (t.contains('buku')) return 'Buku';
    if (t.contains('kegiatan') || t.contains('ekstrakurikuler')) return 'Kegiatan';
    return 'Lainnya';
  }

  void _showFilterDialog() {
    String tempSortOrder = _selectedSortOrder;
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;
    Map<String, bool> tempCategoryFilters = Map.from(_categoryFilters);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HistoryFilterWidget(
        selectedSortOrder: tempSortOrder,
        startDate: tempStartDate,
        endDate: tempEndDate,
        categoryFilters: tempCategoryFilters,
        availableCategories: _categoryFilters.keys.toList(),
        onSortOrderChanged: (sortOrder) {
          tempSortOrder = sortOrder;
        },
        onStartDateChanged: (startDate) {
          tempStartDate = startDate;
        },
        onEndDateChanged: (endDate) {
          tempEndDate = endDate;
        },
        onCategoryFiltersChanged: (categoryFilters) {
          tempCategoryFilters = categoryFilters;
        },
        onApply: () {
          setState(() {
            _selectedSortOrder = tempSortOrder;
            _startDate = tempStartDate;
            _endDate = tempEndDate;
            _categoryFilters
              ..clear()
              ..addAll(tempCategoryFilters);
          });
        },
        onReset: () {
          setState(() {
            _selectedSortOrder = 'Terbaru';
            _startDate = null;
            _endDate = null;
            _categoryFilters.updateAll((key, value) => true);
          });
        },
        title: 'Filter Riwayat Tagihan',
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Bill> get _filteredBills {
    List<Bill> filtered = List.from(_allBills);
    
    // Filter by main tab
    // Single tab: only show paid (Pembayaran Berhasil)
    filtered = filtered.where((bill) => bill.status == BillStatus.paid).toList();
    
    // Filter by date range (based on dueDate)
    if (_startDate != null || _endDate != null) {
      filtered = filtered.where((bill) {
        final d = bill.dueDate;
        if (_startDate != null && _endDate != null) {
          return d.isAfter(_startDate!.subtract(const Duration(days: 1))) && d.isBefore(_endDate!.add(const Duration(days: 1)));
        } else if (_startDate != null) {
          return d.isAfter(_startDate!.subtract(const Duration(days: 1)));
        } else if (_endDate != null) {
          return d.isBefore(_endDate!.add(const Duration(days: 1)));
        }
        return true;
      }).toList();
    }
    
    // Filter by category inferred from title
    filtered = filtered.where((bill) {
      final cat = _getBillCategory(bill);
      return _categoryFilters[cat] == true;
    }).toList();
    
    // Sort by newest first
    if (_selectedSortOrder == 'Terbaru') {
      filtered.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    } else {
      filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).riwayat,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // No tabs needed since only one status is shown
          
          // Filter section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).selesai,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _selectedSortOrder,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: _showFilterDialog,
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context).filter,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppStyles.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.tune,
                            size: 18,
                            color: AppStyles.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Transaction list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredBills.length,
              itemBuilder: (context, index) {
                final bill = _filteredBills[index];
                return _buildTransactionItem(bill);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Bill bill) {
    Color statusColor;
    Color statusBgColor;
    String statusText;
    IconData statusIcon;

    switch (bill.status) {
      case BillStatus.pending:
        statusColor = Colors.grey[600]!;
        statusBgColor = Colors.grey[50]!;
        statusText = 'Menunggu';
        statusIcon = Icons.schedule;
        break;
      case BillStatus.unpaid:
        statusColor = Colors.orange[600]!;
        statusBgColor = Colors.orange[50]!;
        statusText = 'Belum Lunas';
        statusIcon = Icons.access_time;
        break;
      case BillStatus.partial:
        statusColor = Colors.blue[600]!;
        statusBgColor = Colors.blue[50]!;
        statusText = 'Terbayar Sebagian';
        statusIcon = Icons.hourglass_bottom;
        break;
      case BillStatus.paid:
        statusColor = Colors.green[600]!;
        statusBgColor = Colors.green[50]!;
        statusText = 'Pembayaran Berhasil';
        statusIcon = Icons.check_circle_outline;
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailTagihanPage(bill: bill),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Invoice ID
                  Text(
                    bill.id,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Title
                  Text(
                    bill.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Subtitle
                  Text(
                    bill.subtitle ?? '',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[500],
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Amount and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rp ${NumberFormat('#,###').format(bill.amount)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bill.status == BillStatus.paid 
                        ? Colors.green[100] 
                        : bill.status == BillStatus.pending
                        ? Colors.grey[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: bill.status == BillStatus.paid 
                          ? Colors.green[700] 
                          : bill.status == BillStatus.pending
                          ? Colors.grey[700]
                          : Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
