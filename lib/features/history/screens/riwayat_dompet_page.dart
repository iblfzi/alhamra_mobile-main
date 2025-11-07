import 'package:flutter/material.dart';
import '../../../core/utils/app_styles.dart';
import '../../../core/models/wallet_history.dart';
import '../../shared/widgets/index.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'detail_dompet_page.dart';

class RiwayatDompetPage extends StatefulWidget {
  const RiwayatDompetPage({super.key});

  @override
  State<RiwayatDompetPage> createState() => _RiwayatDompetPageState();
}

class _RiwayatDompetPageState extends State<RiwayatDompetPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final bool _showFilter = false;
  String _selectedPeriod = 'Bulan Ini';
  String _selectedCategory = 'Pemasukan';
  final TextEditingController _searchController = TextEditingController();
  
  // Filter state variables
  String _selectedSortOrder = 'Terbaru';
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Category filters for wallet transactions
  final Map<String, bool> _categoryFilters = {
    'Top Up': true,
    'Pembayaran': true,
    'Transfer': true,
  };

  // Dummy data untuk riwayat dompet
  final List<WalletHistory> _allTransactions = [
    WalletHistory(
      id: 'DMP-001',
      title: 'Dana Masuk Dari',
      subtitle: 'Muhammad Ilham',
      amount: 1200000,
      date: DateTime(2025, 7, 22, 12, 9),
      type: WalletTransactionType.topup,
      bankName: 'Bank Mandiri',
    ),
    WalletHistory(
      id: 'DMP-002',
      title: 'Pembayaran SPP',
      subtitle: 'November 2024',
      amount: 350000,
      date: DateTime(2025, 7, 21, 14, 30),
      type: WalletTransactionType.payment,
      bankName: 'Bank Mandiri',
    ),
    WalletHistory(
      id: 'DMP-003',
      title: 'Dana Masuk Dari',
      subtitle: 'Muhammad Ilham',
      amount: 800000,
      date: DateTime(2025, 7, 20, 10, 15),
      type: WalletTransactionType.topup,
      bankName: 'Bank Mandiri',
    ),
    WalletHistory(
      id: 'DMP-004',
      title: 'Transfer ke Uang Saku',
      subtitle: 'Transfer internal',
      amount: 500000,
      date: DateTime(2025, 7, 19, 16, 45),
      type: WalletTransactionType.transfer,
      bankName: 'Bank Mandiri',
    ),
    WalletHistory(
      id: 'DMP-005',
      title: 'Biaya Makan',
      subtitle: 'Oktober 2024',
      amount: 450000,
      date: DateTime(2025, 7, 18, 14, 20),
      type: WalletTransactionType.payment,
      bankName: 'Bank Mandiri',
    ),
    WalletHistory(
      id: 'DMP-006',
      title: 'Dana Masuk Dari',
      subtitle: 'Muhammad Ilham',
      amount: 600000,
      date: DateTime(2025, 7, 17, 11, 10),
      type: WalletTransactionType.topup,
      bankName: 'Bank Mandiri',
    ),
    WalletHistory(
      id: 'DMP-007',
      title: 'Biaya Seragam',
      subtitle: 'September 2024',
      amount: 275000,
      date: DateTime(2025, 7, 16, 19, 30),
      type: WalletTransactionType.payment,
      bankName: 'Bank Mandiri',
    ),
    WalletHistory(
      id: 'DMP-008',
      title: 'Transfer ke Tabungan',
      subtitle: 'Transfer eksternal',
      amount: 300000,
      date: DateTime(2025, 7, 15, 9, 0),
      type: WalletTransactionType.transfer,
      bankName: 'Bank Mandiri',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final themed = baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(fontFamily: 'Poppins'),
    );

    return Theme(
      data: themed,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppStyles.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Riwayat Dompet',
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
            // Tab Bar (standardized like Riwayat Tagihan)
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppStyles.primaryColor,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: AppStyles.primaryColor,
                indicatorWeight: 2,
                labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: 'Pemasukan'),
                  Tab(text: 'Pengeluaran'),
                  Tab(text: 'Laporan'),
                ],
              ),
            ),
            // Filter Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              color: Colors.grey[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Semua',
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
                              'Filter',
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
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTransactionList(_getFilteredTransactions().where((t) => t.isPositive).toList()),
                  _buildTransactionList(_getFilteredTransactions().where((t) => !t.isPositive).toList()),
                  _buildReportTab(), // Laporan dengan chart
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<WalletHistory> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(transaction);
      },
    );
  }

  Widget _buildTransactionItem(WalletHistory transaction) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailDompetPage(transaction: transaction),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconForTransactionType(transaction.type),
              color: Colors.pink[300],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.bankName,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.formattedDateTime,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            transaction.formattedAmount,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTransactionType(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.topup:
        return Icons.add_circle_outline;
      case WalletTransactionType.payment:
        return Icons.payment_outlined;
      case WalletTransactionType.transfer:
        return Icons.swap_horiz_outlined;
      case WalletTransactionType.refund:
        return Icons.refresh_outlined;
    }
  }

  Widget _buildReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Filter
          Row(
            children: [
              _buildPeriodChip('Bulan Ini', _selectedPeriod == 'Bulan Ini'),
              const SizedBox(width: 8),
              _buildPeriodChip('Bulan Lalu', _selectedPeriod == 'Bulan Lalu'),
              const SizedBox(width: 8),
              _buildPeriodChip('3 Bulan', _selectedPeriod == '3 Bulan'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Period Label
          Text(
            _selectedPeriod,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Selisih',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp. 3.750.000',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppStyles.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppStyles.primaryColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pemasukan',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+Rp.4.800.000',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppStyles.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.pink[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pengeluaran',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '-Rp.850.000',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.pink[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Doughnut Chart
          SizedBox(
            height: 200,
            child: SfCircularChart(
              margin: EdgeInsets.zero,
              series: <CircularSeries>[
                DoughnutSeries<ChartData, String>(
                  dataSource: _getChartData(),
                  xValueMapper: (ChartData data, _) => data.category,
                  yValueMapper: (ChartData data, _) => data.value,
                  pointColorMapper: (ChartData data, _) => data.color,
                  innerRadius: '70%',
                  radius: '90%',
                  dataLabelSettings: DataLabelSettings(
                    isVisible: false,
                  ),
                ),
              ],
              annotations: <CircularChartAnnotation>[
                CircularChartAnnotation(
                  widget: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '18%',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppStyles.primaryColor,
                        ),
                      ),
                      Text(
                        'Pengeluaran',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Category Sections
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'Pemasukan';
                    });
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: 2,
                        color: _selectedCategory == 'Pemasukan' ? AppStyles.primaryColor : Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: _selectedCategory == 'Pemasukan' ? FontWeight.w600 : FontWeight.w500,
                          color: _selectedCategory == 'Pemasukan' ? AppStyles.primaryColor : Colors.grey[600],
                        ),
                        child: const Text('Pemasukan'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'Pengeluaran';
                    });
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: 2,
                        color: _selectedCategory == 'Pengeluaran' ? AppStyles.primaryColor : Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: _selectedCategory == 'Pengeluaran' ? FontWeight.w600 : FontWeight.w500,
                          color: _selectedCategory == 'Pengeluaran' ? AppStyles.primaryColor : Colors.grey[600],
                        ),
                        child: const Text('Pengeluaran'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Transaction List for Report
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                ),
              );
            },
            child: Column(
              key: ValueKey(_selectedCategory),
              children: (_selectedCategory == 'Pemasukan' 
                  ? _allTransactions.where((t) => t.isPositive).take(2)
                  : _allTransactions.where((t) => !t.isPositive).take(2)
              ).map((transaction) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: _buildTransactionItem(transaction),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppStyles.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppStyles.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
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
            _categoryFilters.clear();
            _categoryFilters.addAll(tempCategoryFilters);
          });
          Navigator.pop(context);
        },
        onReset: () {
          setState(() {
            _selectedSortOrder = 'Terbaru';
            _startDate = null;
            _endDate = null;
            _categoryFilters.updateAll((key, value) => true);
          });
        },
        title: 'Filter Riwayat Dompet',
      ),
    );
  }

  List<WalletHistory> _getFilteredTransactions() {
    List<WalletHistory> filtered = List.from(_allTransactions);
    
    // Filter by date range
    if (_startDate != null || _endDate != null) {
      filtered = filtered.where((transaction) {
        final transactionDate = transaction.date;
        
        if (_startDate != null && _endDate != null) {
          return transactionDate.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
                 transactionDate.isBefore(_endDate!.add(const Duration(days: 1)));
        } else if (_startDate != null) {
          return transactionDate.isAfter(_startDate!.subtract(const Duration(days: 1)));
        } else if (_endDate != null) {
          return transactionDate.isBefore(_endDate!.add(const Duration(days: 1)));
        }
        
        return true;
      }).toList();
    }
    
    // Filter by category
    filtered = filtered.where((transaction) {
      String category = _getTransactionCategory(transaction);
      return _categoryFilters[category] == true;
    }).toList();
    
    // Sort by date
    if (_selectedSortOrder == 'Terbaru') {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    } else {
      filtered.sort((a, b) => a.date.compareTo(b.date));
    }
    
    return filtered;
  }

  String _getTransactionCategory(WalletHistory transaction) {
    switch (transaction.type) {
      case WalletTransactionType.topup:
        return 'Top Up';
      case WalletTransactionType.payment:
        return 'Pembayaran';
      case WalletTransactionType.transfer:
        return 'Transfer';
      default:
        return 'Lainnya';
    }
  }

  List<ChartData> _getChartData() {
    return [
      ChartData('Pemasukan', 82, AppStyles.primaryColor),
      ChartData('Pengeluaran', 18, Colors.pink[300]!),
    ];
  }
}

class ChartData {
  ChartData(this.category, this.value, this.color);
  final String category;
  final double value;
  final Color color;
}
