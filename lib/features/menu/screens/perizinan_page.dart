import 'package:alhamra_1/features/shared/widgets/student_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/data/perizinan_service.dart';
import '../../../core/models/perizinan_history.dart';
import '../../../core/services/odoo_api_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/data/student_data.dart';
import '../../../core/utils/app_styles.dart';
import '../../shared/widgets/index.dart';

class PerizinanPage extends StatefulWidget {
  const PerizinanPage({super.key});

  @override
  State<PerizinanPage> createState() => _PerizinanPageState();
}

class _PerizinanPageState extends State<PerizinanPage> {
  // --- State Management ---
  String _selectedStudentName = StudentData.defaultStudent;
  bool _isStudentOverlayVisible = false;
  bool _loading = false;
  String? _errorMessage;
  List<PerizinanHistory> _riwayat = [];
  bool _submitting = false;
  List<String> _allStudents = const [];
  final Map<String, String> _nameToSiswaId = {};
  final OdooApiService _odoo = OdooApiService();

  // --- Form State ---
  final _formKey = GlobalKey<FormState>();
  final _keperluanController = TextEditingController();
  final _penjemputController = TextEditingController();
  DateTime? _tanggalJemput;
  DateTime? _tanggalKembali;
  final PerizinanService _service = PerizinanService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadChildrenAndInitSelection();
      await _fetchRiwayat();
    });
  }

  @override
  void dispose() {
    _keperluanController.dispose();
    _penjemputController.dispose();
    super.dispose();
  }

  Future<void> _fetchRiwayat() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final items = await _service.fetchRiwayat(page: 1, limit: 20);
      if (!mounted) return;
      setState(() {
        _riwayat = items..sort((a, b) => b.tglIjin.compareTo(a.tglIjin));
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
      final children = await _odoo.getChildren();
      final names = <String>[];
      _nameToSiswaId.clear();
      for (final c in children) {
        final map = Map<String, dynamic>.from(c);
        final name = (map['name'] ?? map['nama'] ?? '').toString();
        final idVal = map['id'] ?? map['siswa_id'] ?? map['siswaId'];
        final siswaId = idVal?.toString() ?? '';
        if (name.isNotEmpty) {
          names.add(name);
          if (siswaId.isNotEmpty) _nameToSiswaId[name] = siswaId;
        }
      }
      setState(() {
        _allStudents = names.isEmpty ? [StudentData.defaultStudent] : names;
      });

      // Sinkronkan pilihan awal dengan AuthProvider/prefs
      final auth = context.read<AuthProvider>();
      final prefs = await SharedPreferences.getInstance();
      final savedSiswaId = prefs.getString('siswa_id');
      String initialName = auth.selectedStudent.isNotEmpty
          ? auth.selectedStudent
          : (_allStudents.isNotEmpty ? _allStudents.first : StudentData.defaultStudent);
      if (savedSiswaId != null && savedSiswaId.isNotEmpty) {
        final byName = _nameToSiswaId.entries
            .firstWhere((e) => e.value == savedSiswaId, orElse: () => const MapEntry('', ''))
            .key;
        if (byName.isNotEmpty) initialName = byName;
      }
      setState(() { _selectedStudentName = initialName; });
      if (auth.selectedStudent != initialName) {
        try { auth.selectStudent(initialName); } catch (_) {}
      }
      final id = _nameToSiswaId[initialName];
      if (id != null && id.isNotEmpty) {
        try { await prefs.setString('siswa_id', id); } catch (_) {}
      }
    } catch (e) {
      // fallback: keep default student
    }
  }

  void _updateSelectedData() {
    // Reset form when student changes
    setState(() {
      _formKey.currentState?.reset();
      _keperluanController.clear();
      _penjemputController.clear();
      _tanggalJemput = null;
      _tanggalKembali = null;
    });
    _fetchRiwayat();
  }

  Future<void> _submitPerizinan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggalJemput == null || _tanggalKembali == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal penjemputan dan tanggal kembali wajib diisi')),
      );
      return;
    }
    if (_tanggalKembali!.isBefore(_tanggalJemput!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal kembali harus setelah atau sama dengan tanggal penjemputan')),
      );
      return;
    }

    setState(() { _submitting = true; });
    try {
      await _service.submitPerizinan(
        keperluan: _keperluanController.text.trim(),
        penjemput: _penjemputController.text.trim(),
        tglIjin: _tanggalJemput!,
        tglKembali: _tanggalKembali!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan perizinan berhasil dikirim')),
      );
      // Reset form dan refresh riwayat
      setState(() {
        _formKey.currentState?.reset();
        _keperluanController.clear();
        _penjemputController.clear();
        _tanggalJemput = null;
        _tanggalKembali = null;
      });
      await _fetchRiwayat();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengajukan perizinan: $e')),
      );
    } finally {
      if (mounted) setState(() { _submitting = false; });
    }
  }

  // --- UI Builders ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.primaryColor,
      appBar: CustomAppBar(
        title: 'Formulir Perizinan',
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
                  child: _buildPerizinanForm(),
                ),
              ),
            ],
          ),
          if (_isStudentOverlayVisible)
            SearchOverlayWidget(
              isVisible: _isStudentOverlayVisible,
              title: 'Pilih Santri',
              items: _allStudents.isEmpty ? [StudentData.defaultStudent] : _allStudents,
              selectedItem: context.watch<AuthProvider>().selectedStudent.isEmpty
                  ? _selectedStudentName
                  : context.watch<AuthProvider>().selectedStudent,
              onItemSelected: (nama) async {
                setState(() { _isStudentOverlayVisible = false; });
                // 1) Update provider
                try { context.read<AuthProvider>().selectStudent(nama); } catch (_) {}
                // 2) Persist siswa_id jika ada
                final id = _nameToSiswaId[nama];
                if (id != null && id.isNotEmpty) {
                  try { final prefs = await SharedPreferences.getInstance(); await prefs.setString('siswa_id', id); } catch (_) {}
                }
                // 3) Update UI & data
                setState(() { _selectedStudentName = nama; });
                _updateSelectedData();
              },
              onClose: () => setState(() => _isStudentOverlayVisible = false),
              searchHint: 'Cari santri...',
              avatarUrl: StudentData.getStudentAvatar(
                context.watch<AuthProvider>().selectedStudent.isEmpty
                    ? _selectedStudentName
                    : context.watch<AuthProvider>().selectedStudent,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: StudentSelectionWidget(
        selectedStudent: context.watch<AuthProvider>().selectedStudent.isEmpty
            ? _selectedStudentName
            : context.watch<AuthProvider>().selectedStudent,
        students: _allStudents.isEmpty ? [StudentData.defaultStudent] : _allStudents,
        onStudentChanged: (nama) async {
          // 1) Update provider
          try { context.read<AuthProvider>().selectStudent(nama); } catch (_) {}
          // 2) Persist siswa_id jika tersedia
          final id = _nameToSiswaId[nama];
          if (id != null && id.isNotEmpty) {
            try { final prefs = await SharedPreferences.getInstance(); await prefs.setString('siswa_id', id); } catch (_) {}
          }
          // 3) Update UI & data
          setState(() { _selectedStudentName = nama; });
          _updateSelectedData();
        },
        onOverlayVisibilityChanged: (visible) =>
            setState(() => _isStudentOverlayVisible = visible),
        avatarUrl: StudentData.getStudentAvatar(
          context.watch<AuthProvider>().selectedStudent.isEmpty
              ? _selectedStudentName
              : context.watch<AuthProvider>().selectedStudent,
        ),
      ),
    );
  }

  Widget _buildPerizinanForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Perizinan',
              style: AppStyles.sectionTitle(context)
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _keperluanController,
              decoration: const InputDecoration(
                labelText: 'Keperluan',
                hintText: 'Contoh: Pulang kampung, acara keluarga',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Keperluan tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _penjemputController,
              decoration: const InputDecoration(
                labelText: 'Penjemput',
                hintText: 'Contoh: Ayah, Ibu, Kakak',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama penjemput tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildDatePicker(
              'Tanggal Penjemputan',
              _tanggalJemput,
              (date) => setState(() => _tanggalJemput = date),
            ),
            const SizedBox(height: 20),
            _buildDatePicker(
              'Tanggal Kembali',
              _tanggalKembali,
              (date) => setState(() => _tanggalKembali = date),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitPerizinan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Ajukan Perizinan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Riwayat Perizinan',
              style: AppStyles.sectionTitle(context)
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              )
            else if (_riwayat.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const Text('Belum ada riwayat perizinan'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _riwayat.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _riwayat[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
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
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppStyles.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.event, color: AppStyles.primaryColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.keperluan.isEmpty ? '-' : item.keperluan,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text('${DateFormat('d MMM yyyy', 'id_ID').format(item.tglIjin)} • ${DateFormat('d MMM yyyy', 'id_ID').format(item.tglKembali)}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(item.name, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: item.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: item.statusColor.withOpacity(0.2)),
                          ),
                          child: Text(item.state, style: TextStyle(color: item.statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(
      String label, DateTime? selectedDate, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppStyles.bodyText(context)
                .copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              locale: const Locale('id', 'ID'),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme:
                        const ColorScheme.light(primary: AppStyles.primaryColor),
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                          .format(selectedDate)
                      : 'Pilih tanggal',
                  style: AppStyles.bodyText(context).copyWith(
                    color: selectedDate != null
                        ? Colors.black87
                        : Colors.grey[600],
                  ),
                ),
                const Icon(Icons.calendar_today,
                    color: AppStyles.primaryColor, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}