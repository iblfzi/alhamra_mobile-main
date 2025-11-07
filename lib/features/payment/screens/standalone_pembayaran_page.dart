import 'package:alhamra_1/features/payment/widgets/bill_card.dart';

import '../../../core/utils/app_styles.dart';
import '../../../core/models/bill.dart';
import '../../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'pembayaran_flow_bsi.dart';

class StandalonePembayaranPage extends StatefulWidget {
  const StandalonePembayaranPage({super.key});

  @override
  State<StandalonePembayaranPage> createState() => _StandalonePembayaranPageState();
}

class _StandalonePembayaranPageState extends State<StandalonePembayaranPage> {
  final TextEditingController _searchController = TextEditingController();

  // Filters
  int _statusIndex = 0; // 0: Semua, 1: Belum Bayar, 2: Jatuh Tempo, 3: Lunas
  String _selectedPeriod = 'Semua Periode';

  // Dummy data meniru tampilan referensi (SPP, Uang Makan, Seragam, dsb)
  final List<Bill> _allBills = [
    Bill(
      id: 'INV-0001',
      title: 'SPP November 2024',
      subtitle: 'Tagihan SPP bulan berjalan',
      amount: 350000,
      dueDate: DateTime(2024, 11, 10),
      status: BillStatus.unpaid,
      period: 'November 2024',
    ),
    Bill(
      id: 'INV-0002',
      title: 'Uang Makan November 2024',
      subtitle: 'Paket makan bulanan',
      amount: 250000,
      dueDate: DateTime(2024, 11, 12),
      status: BillStatus.partial,
      period: 'November 2024',
    ),
    Bill(
      id: 'INV-0003',
      title: 'Seragam Putra 2024',
      subtitle: 'Pembelian seragam',
      amount: 420000,
      dueDate: DateTime(2024, 10, 28),
      status: BillStatus.unpaid,
      period: 'Oktober 2024',
    ),
    Bill(
      id: 'INV-0004',
      title: 'SPP Oktober 2024',
      subtitle: 'Tagihan SPP bulan berjalan',
      amount: 350000,
      dueDate: DateTime(2024, 10, 10),
      status: BillStatus.paid,
      period: 'Oktober 2024',
    ),
    Bill(
      id: 'INV-0005',
      title: 'Kegiatan Santri',
      subtitle: 'Iuran kegiatan semester',
      amount: 150000,
      dueDate: DateTime(2024, 9, 20),
      status: BillStatus.paid,
      period: 'September 2024',
    ),
  ];

  final List<String> _periods = const [
    'Semua Periode',
    'November 2024',
    'Oktober 2024',
    'September 2024',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // UI state: selected map id -> bool
  final Map<String, bool> _selected = {};

  bool _isSelected(String id) => _selected[id] ?? false;
  void _setSelected(String id, bool v) => _selected[id] = v;

  @override
  Widget build(BuildContext context) {
    final filtered = _applyFilters();

    final baseTheme = Theme.of(context);
    final themed = baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(fontFamily: 'Poppins'),
    );

    return Theme(
      data: themed,
      child: Scaffold(
        backgroundColor: const Color(0xFF2196F3),
        appBar: AppBar(
          title: const Text(
            'Tagihan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                // Simulasi refresh data
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data tagihan diperbarui')),
                );
                setState(() {});
              },
              tooltip: 'Segarkan',
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 8),
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
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final bill = filtered[index];
                          return BillCard(
                            bill: bill,
                            selected: _isSelected(bill.id),
                            onSelectedChanged: (v) {
                              setState(() => _setSelected(bill.id, v));
                            },
                            onTap: () {
                              // TODO: Navigate to detail tagihan
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Detail: ${bill.title}')),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildSelectedBar(filtered),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari tagihan (contoh: SPP, Makan, Seragam)',
                    prefixIcon: const Icon(Icons.search),
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
              ),
              const SizedBox(width: 12),
              // Period dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    items: _periods
                        .map((p) => DropdownMenuItem<String>(
                              value: p,
                              child: Text(p),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedPeriod = val ?? 'Semua Periode'),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Status chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua', 0),
                _buildFilterChip('Belum Bayar', 1),
                _buildFilterChip('Terbayar Sebagian', 2),
                _buildFilterChip('Lunas', 3),
              ].expand((w) sync* {
                yield w;
                yield const SizedBox(width: 8);
              }).toList()
                ..removeLast(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final selected = _statusIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppStyles.primaryColor.withOpacity(0.15),
      labelStyle: TextStyle(
        color: selected ? AppStyles.primaryColor : Colors.black87,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      onSelected: (_) => setState(() => _statusIndex = index),
      side: BorderSide(color: selected ? AppStyles.primaryColor : Colors.grey.shade300),
    );
  }

  Widget _buildSelectedBar(List<Bill> visible) {
    final payable = visible.where((b) => b.isPayable).toList();
    final selectedBills = payable.where((b) => _isSelected(b.id)).toList();
    final selectedCount = selectedBills.length;
    final allSelected = payable.isNotEmpty && selectedCount == payable.length;
    final selectedTotal = selectedBills.fold<int>(0, (prev, b) => prev + b.outstanding);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8 + 8),
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
            Checkbox(
              value: allSelected,
              onChanged: payable.isEmpty ? null : (v) {
                setState(() {
                  for (final b in payable) {
                    _setSelected(b.id, v ?? false);
                  }
                });
              },
              shape: const CircleBorder(),
              activeColor: AppStyles.primaryColor,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pilih Semua ($selectedCount/${payable.length})',
                    style: AppStyles.bodyText(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _rupiah(selectedTotal),
                    style: AppStyles.saldoValue(context).copyWith(fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: selectedCount > 0
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PembayaranConfirmPage(bills: selectedBills),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.lock_outline),
              label: const Text('Bayar Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context).tidakAdaTagihan, style: AppStyles.bodyText(context).copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(AppLocalizations.of(context).cobaUbahFilter, style: AppStyles.bodyText(context).copyWith(color: Colors.black54)),
        ],
      ),
    );
  }

  List<Bill> _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    return _allBills.where((b) {
      // Filter query
      final matchQuery = query.isEmpty ||
          b.title.toLowerCase().contains(query) ||
          (b.subtitle?.toLowerCase() ?? '').contains(query) ||
          b.id.toLowerCase().contains(query);

      // Filter status
      bool matchStatus = true;
      switch (_statusIndex) {
        case 1:
          matchStatus = b.status == BillStatus.unpaid;
          break;
        case 2:
          matchStatus = b.status == BillStatus.partial;
          break;
        case 3:
          matchStatus = b.status == BillStatus.paid;
          break;
        default:
          matchStatus = true; // Semua
      }

      // Filter periode
      final matchPeriod = _selectedPeriod == 'Semua Periode' || b.period == _selectedPeriod;

      return matchQuery && matchStatus && matchPeriod;
    }).toList();
  }


  String _rupiah(int amount) {
    final s = amount.toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return 'Rp ${s.replaceAllMapped(reg, (m) => '.')}';
  }
}

