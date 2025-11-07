import 'package:alhamra_1/features/shared/widgets/student_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/data/student_data.dart';
import '../../../core/models/mutabaah_model.dart';
import '../../../core/utils/app_styles.dart';
import '../../shared/widgets/index.dart';
import '../../../core/data/mutabaah_service.dart';
import '../../../core/services/odoo_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';

class MutabaahPage extends StatefulWidget {
  const MutabaahPage({super.key});

  @override
  State<MutabaahPage> createState() => _MutabaahPageState();
}

class _MutabaahPageState extends State<MutabaahPage> {
  // --- State Management ---
  late Map<String, StudentMutabaahProfile> _allMutabaahData;
  late StudentMutabaahProfile _selectedProfile;
  final String _selectedStudentName = StudentData.defaultStudent;
  bool _isStudentOverlayVisible = false;
  String? _expandedEntryId;
  late List<MutabaahEntry> _filteredEntries;
  final TextEditingController _searchController = TextEditingController();
  final MutabaahService _service = MutabaahService();
  bool _loading = false;
  String? _errorMessage;
  List<String> _allStudents = const [];
  final Map<String, String> _nameToSiswaId = {};

  // --- Filter State ---
  String _selectedSortOrder = 'Terbaru';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _generateMockData();
    _selectedProfile = _allMutabaahData[_selectedStudentName]!;
    _filterMutabaahEntries();
    _searchController.addListener(_filterMutabaahEntries);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChildrenAndInitSelection();
      _loadMutabaah();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _generateMockData() {
    _allMutabaahData = {
      for (var student in StudentData.allStudents)
        student: StudentMutabaahProfile.createMock(
            (StudentData.allStudents.indexOf(student) + 1).toString())
    };
  }

  void _updateSelectedData() {
    setState(() {
      _selectedProfile = _allMutabaahData[_selectedStudentName]!;
      // Reset filters and search when student changes
      _searchController.clear();
      _selectedSortOrder = 'Terbaru';
      _startDate = null;
      _endDate = null;
      _filterMutabaahEntries(); // Apply reset filters
    });
    _loadMutabaah();
  }

  void _filterMutabaahEntries() {
    final query = _searchController.text.toLowerCase();
    var filtered = _selectedProfile.entries.where((entry) {
      final searchMatch = entry.kegiatan.toLowerCase().contains(query);

      // Normalize dates to ignore time component for correct comparison
      final entryDate =
          DateTime(entry.tanggal.year, entry.tanggal.month, entry.tanggal.day);
      final startDate = _startDate != null
          ? DateTime(_startDate!.year, _startDate!.month, _startDate!.day)
          : null;
      final endDate = _endDate != null
          ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day)
          : null;

      final isAfterStartDate =
          startDate == null || !entryDate.isBefore(startDate);
      final isBeforeEndDate = endDate == null || !entryDate.isAfter(endDate);

      return searchMatch && isAfterStartDate && isBeforeEndDate;
    }).toList();

    // Sorting
    filtered.sort((a, b) {
      return _selectedSortOrder == 'Terbaru'
          ? b.tanggal.compareTo(a.tanggal)
          : a.tanggal.compareTo(b.tanggal);
    });

    setState(() {
      _filteredEntries = filtered;
    });
  }

  // --- UI Builders ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.primaryColor,
      appBar: CustomAppBar(
        title: 'Mutabaah',
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildStudentSelector(),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _buildMutabaahDetails(),
                ),
              ),
            ],
          ),
          if (_isStudentOverlayVisible)
            SearchOverlayWidget(
              isVisible: _isStudentOverlayVisible,
              title: 'Pilih Santri',
              items: _allStudents.isEmpty ? [StudentData.defaultStudent] : _allStudents,
              selectedItem: context.watch<AuthProvider>().selectedStudent,
              onItemSelected: (nama) async {
                setState(() { _isStudentOverlayVisible = false; });
                _updateSelectedData();
                final id = _nameToSiswaId[nama];
                if (id != null && id.isNotEmpty) {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('siswa_id', id);
                  } catch (_) {}
                }
                try {
                  // ignore: use_build_context_synchronously
                  context.read<AuthProvider>().selectStudent(nama);
                } catch (_) {}
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _loadMutabaah();
                });
              },
              onClose: () => setState(() => _isStudentOverlayVisible = false),
              searchHint: 'Cari santri...',
              avatarUrl: StudentData.getStudentAvatar(
                context.watch<AuthProvider>().selectedStudent.isEmpty
                    ? StudentData.defaultStudent
                    : context.watch<AuthProvider>().selectedStudent,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _loadMutabaah() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      // Resolve siswa_id from current selected student, fallback to prefs
      final selectedName = context.read<AuthProvider>().selectedStudent;
      String? siswaId = _nameToSiswaId[selectedName];
      if (siswaId == null || siswaId.isEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          siswaId = prefs.getString('siswa_id');
        } catch (_) {}
      }
      final items = await _service.fetchRiwayat(page: 1, limit: 50, siswaId: siswaId);
      if (!mounted) return;
      final mapped = items
          .map<MutabaahEntry>((it) => MutabaahEntry(
                id: it.id,
                kegiatan: it.sesi.isNotEmpty ? 'Mutabaah ${it.sesi}' : 'Mutabaah',
                tanggal: it.tanggal,
                keterangan: '',
                pencatat: '',
                sesi: it.sesi,
                noReferensi: it.noReferensi,
                totalSkor: it.totalSkor,
                status: it.status,
                rincian: it.rincian
                    .map((d) => MutabaahDetail(
                          kategori: d.kategori,
                          aktivitas: d.aktivitas,
                          dilakukan: d.dilakukan,
                          skor: d.skor,
                          keterangan: d.keterangan,
                        ))
                    .toList(),
              ))
          .toList()
            ..sort((a, b) => b.tanggal.compareTo(a.tanggal));

      setState(() {
        _selectedProfile =
            StudentMutabaahProfile(studentId: _selectedProfile.studentId, entries: mapped);
        _filteredEntries = mapped;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadChildrenAndInitSelection() async {
    try {
      final odoo = OdooApiService();
      await odoo.loadSession();
      final children = await odoo.getChildren();
      final names = <String>[];
      _nameToSiswaId.clear();
      for (final c in children) {
        final name = (c['name'] ?? c['nama'] ?? '').toString();
        final id = c['id']?.toString() ?? '';
        if (name.isNotEmpty && id.isNotEmpty) {
          names.add(name);
          _nameToSiswaId[name] = id;
        }
      }
      if (!mounted) return;
      setState(() {
        _allStudents = names.isEmpty ? StudentData.allStudents : names;
      });
      final provider = context.read<AuthProvider>();
      var selected = provider.selectedStudent;
      if (selected.isEmpty || !_nameToSiswaId.containsKey(selected)) {
        if (names.isNotEmpty) {
          selected = names.first;
          provider.selectStudent(selected);
        }
      }
      if (selected.isNotEmpty && _nameToSiswaId.containsKey(selected)) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('siswa_id', _nameToSiswaId[selected]!);
      }
      // Do not set local selected name; rely on provider for display
    } catch (_) {}
  }

  Widget _buildStudentSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: StudentSelectionWidget(
        selectedStudent: context.watch<AuthProvider>().selectedStudent,
        students: _allStudents.isEmpty ? [StudentData.defaultStudent] : _allStudents,
        onStudentChanged: (nama) async {
          _updateSelectedData();
          final id = _nameToSiswaId[nama];
          if (id != null && id.isNotEmpty) {
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('siswa_id', id);
            } catch (_) {}
          }
          try {
            // ignore: use_build_context_synchronously
            context.read<AuthProvider>().selectStudent(nama);
          } catch (_) {}
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadMutabaah();
          });
        },
        onOverlayVisibilityChanged: (visible) =>
            setState(() => _isStudentOverlayVisible = visible),
        avatarUrl: StudentData.getStudentAvatar(
          context.watch<AuthProvider>().selectedStudent.isEmpty
              ? StudentData.defaultStudent
              : context.watch<AuthProvider>().selectedStudent,
        ),
      ),
    );
  }

  Widget _buildMutabaahDetails() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: _buildSearchAndFilter(),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Padding(padding: EdgeInsets.all(16), child: Text(_errorMessage!, style: TextStyle(color: Colors.red))))
                  : (_filteredEntries.isEmpty
              ? const Center(child: Text('Tidak ada data yang cocok.'))
              : Container(
                  margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _filteredEntries[index];
                      return _buildMutabaahItem(entry);
                    },
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
                  ),
                )),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mutabaah',
          style: AppStyles.sectionTitle(context)
              .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari Berdasarkan Kegiatan',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: _showFilterBottomSheet,
              icon: const Icon(Icons.filter_list, size: 20),
              label: const Text('Filter'),
              style: TextButton.styleFrom(
                foregroundColor: AppStyles.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMutabaahItem(MutabaahEntry entry) {
    final isExpanded = _expandedEntryId == entry.id;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedEntryId = isExpanded ? null : entry.id;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.kegiatan,
                        style: AppStyles.bodyText(context).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d MMMM yyyy', 'id_ID').format(entry.tanggal),
                        style: AppStyles.bodyText(context).copyWith(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if ((entry.status ?? '').isNotEmpty)
                      Text(entry.status!, style: AppStyles.bodyText(context).copyWith(color: AppStyles.primaryColor, fontWeight: FontWeight.bold)),
                    if ((entry.noReferensi ?? '').isNotEmpty)
                      Text(entry.noReferensi!, style: AppStyles.bodyText(context).copyWith(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) _buildMutabaahDetailCard(entry),
      ],
    );
  }

  Widget _buildMutabaahDetailCard(MutabaahEntry entry) {
    final rincian = entry.rincian ?? [];
    final siswaName = context.watch<AuthProvider>().selectedStudent;
    return Container(
      padding: const EdgeInsets.fromLTRB(36, 0, 16, 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Header seperti server: "Mutabaah Harian / PR/..."
          Text(
            'Mutabaah Harian / ${(entry.noReferensi ?? entry.id)}',
            style: AppStyles.bodyText(context).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Tanggal', DateFormat('dd/MM/yyyy').format(entry.tanggal)),
          const SizedBox(height: 8),
          _buildDetailRow('Sesi', (entry.sesi ?? '-')),
          const SizedBox(height: 8),
          _buildDetailRow('Siswa', siswaName),
          const SizedBox(height: 8),
          _buildDetailRow('Halaqoh', '-'),
          const SizedBox(height: 16),
          // Tabel Rincian: Aktivitas | Kategori | Dilakukan
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Text('Aktivitas / Perbuatan', style: AppStyles.bodyText(context).copyWith(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Kategori', style: AppStyles.bodyText(context).copyWith(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Dilakukan', style: AppStyles.bodyText(context).copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          ...rincian.map((d) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Text(d.aktivitas, style: AppStyles.bodyText(context)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(d.kategori, style: AppStyles.bodyText(context)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          d.dilakukan ? Icons.check_box : Icons.check_box_outline_blank,
                          size: 18,
                          color: d.dilakukan ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Text('TOTAL NILAI', style: AppStyles.bodyText(context).copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Skor Mutabaah   ${entry.totalSkor ?? '-'}', style: AppStyles.bodyText(context)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.bodyText(context).copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style:
                AppStyles.bodyText(context).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    // Temporary state for the bottom sheet
    String tempSortOrder = _selectedSortOrder;
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filter Mutabaah', style: AppStyles.heading2(context)),
                  const SizedBox(height: 24),
                  Text('Urutkan Berdasarkan',
                      style: AppStyles.bodyText(context)
                          .copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                          child: _buildSortButton(
                              'Terbaru', tempSortOrder == 'Terbaru',
                              () => setModalState(() => tempSortOrder = 'Terbaru'))),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildSortButton(
                              'Terlama', tempSortOrder == 'Terlama',
                              () => setModalState(() => tempSortOrder = 'Terlama'))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker('Dari', tempStartDate,
                            (date) => setModalState(() => tempStartDate = date),
                            onClear: () =>
                                setModalState(() => tempStartDate = null)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePicker('Sampai', tempEndDate,
                            (date) => setModalState(() => tempEndDate = date),
                            onClear: () =>
                                setModalState(() => tempEndDate = null)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              tempSortOrder = 'Terbaru';
                              tempStartDate = null;
                              tempEndDate = null;
                            });
                          },
                          child: const Text('Atur Ulang'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedSortOrder = tempSortOrder;
                              _startDate = tempStartDate;
                              _endDate = tempEndDate;
                              _filterMutabaahEntries();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Terapkan'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortButton(String label, bool isSelected, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor:
            isSelected ? AppStyles.primaryColor.withOpacity(0.1) : Colors.transparent,
        side: BorderSide(
            color: isSelected ? AppStyles.primaryColor : Colors.grey.shade300),
      ),
      child: Text(label,
          style:
              TextStyle(color: isSelected ? AppStyles.primaryColor : Colors.black87)),
    );
  }

  Widget _buildDatePicker(String label, DateTime? selectedDate,
      Function(DateTime) onDateSelected, {VoidCallback? onClear}) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2101),
          locale: const Locale('id', 'ID'),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppStyles.primaryColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppStyles.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_today,
                  size: 18, color: AppStyles.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppStyles.bodyText(context).copyWith(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedDate != null
                        ? DateFormat('d MMM yyyy', 'id_ID').format(selectedDate)
                        : 'Pilih tanggal',
                    style: AppStyles.bodyText(context).copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: selectedDate != null
                          ? Colors.black87
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            if (selectedDate != null && onClear != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.close, size: 16, color: Colors.black54),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}