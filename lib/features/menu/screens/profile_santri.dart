import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/data/student_data.dart';
import '../../../../core/models/santri_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/services/odoo_api_service.dart';
import '../../shared/widgets/index.dart';
import '../../shared/widgets/student_selection_widget.dart';

class ProfileSantriPage extends StatefulWidget {
  const ProfileSantriPage({super.key});

  @override
  State<ProfileSantriPage> createState() => _ProfileSantriPageState();
}

class _ProfileSantriPageState extends State<ProfileSantriPage> {
  final OdooApiService _api = OdooApiService();
  List<Santri> _allSantri = [];
  Santri? _selectedSantri;
  bool _isStudentOverlayVisible = false;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _detail;
  String? _lastSyncedSelectedName;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadDetailForSelected() async {
    final sel = _selectedSantri;
    if (sel == null) return;
    try {
      int? idInt = int.tryParse(sel.id);
      if (idInt == null) {
        // Attempt to extract numeric ID from any non-numeric string
        final digits = RegExp(r'\d+').firstMatch(sel.id)?.group(0);
        idInt = digits != null ? int.tryParse(digits) : null;
      }
      if (idInt == null) return;
      final d = await _api.getStudentProfile(idInt);
      setState(() {
        _detail = d;
      });
      // Optionally normalize into existing Santri for base fields
      final nama = (d['name'] ?? sel.namaLengkap).toString();
      final nis = (d['nis'] ?? sel.nomorInduk).toString();
      final genderCode = (d['jns_kelamin'] ?? '').toString();
      final gender = genderCode == 'L' ? 'Laki-Laki' : genderCode == 'P' ? 'Perempuan' : sel.jenisKelamin;
      final birth = (d['tgl_lahir'] ?? '').toString();
      DateTime dob = sel.tanggalLahir;
      try { if (birth.isNotEmpty) dob = DateTime.parse(birth); } catch (_) {}
      final tmpLahir = (d['tmp_lahir'] ?? sel.tempatLahir).toString();
      setState(() {
        _selectedSantri = Santri(
          id: sel.id,
          namaLengkap: nama,
          namaPanggilan: nama.split(' ').isNotEmpty ? nama.split(' ').first : nama,
          tempatLahir: tmpLahir,
          tanggalLahir: dob,
          jenisKelamin: gender,
          hobi: sel.hobi,
          citaCita: sel.citaCita,
          agama: sel.agama,
          golonganDarah: sel.golonganDarah,
          fotoUrl: sel.fotoUrl,
          nomorInduk: nis,
        );
      });
    } catch (e) {
      setState(() { _error = e.toString(); });
    }
  }

  Future<void> _loadChildren() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Prefer REST getChildren (auto uses current parent auth)
      final items = await _api.getChildren();
      final mapped = <Santri>[];
      for (final it in items) {
        final nama = (it['name'] ?? '').toString();
        final nis = (it['nis'] ?? it['NIS'] ?? '').toString();
        final gender = (it['gender'] ?? '').toString();
        final birth = (it['birth_date'] ?? it['birthDate'] ?? '').toString();
        DateTime dob;
        try {
          dob = birth.isNotEmpty ? DateTime.parse(birth) : DateTime(2000, 1, 1);
        } catch (_) {
          dob = DateTime(2000, 1, 1);
        }
        final id = (it['id'] ?? it['siswa_id'] ?? it['student_id'] ?? '').toString();
        final avatar = (it['avatar_url'] ?? '').toString();
        mapped.add(
          Santri(
            id: id.isNotEmpty ? id : nama,
            namaLengkap: nama,
            namaPanggilan: nama.split(' ').isNotEmpty ? nama.split(' ').first : nama,
            tempatLahir: (it['birth_place'] ?? '').toString(),
            tanggalLahir: dob,
            jenisKelamin: gender,
            hobi: (it['hobby'] ?? '').toString(),
            citaCita: (it['dream'] ?? '').toString(),
            agama: (it['religion'] ?? '').toString(),
            golonganDarah: (it['blood_type'] ?? '').toString(),
            fotoUrl: avatar.isNotEmpty ? avatar : StudentData.getStudentAvatar(nama),
            nomorInduk: nis,
          ),
        );
      }
      // Determine default selection from AuthProvider if available
      final selectedNameFromProvider = Provider.of<AuthProvider>(context, listen: false).selectedStudent;
      Santri? initial;
      if (selectedNameFromProvider.isNotEmpty) {
        initial = mapped.cast<Santri?>().firstWhere(
          (s) => s != null && s.namaLengkap == selectedNameFromProvider,
          orElse: () => null,
        );
      }
      setState(() {
        _allSantri = mapped;
        _selectedSantri = initial ?? (_allSantri.isNotEmpty ? _allSantri.first : null);
        _lastSyncedSelectedName = _selectedSantri?.namaLengkap;
        _isLoading = false;
      });
      if (_selectedSantri != null) {
        await _loadDetailForSelected();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // React to provider changes: if selectedStudent changed elsewhere (Daftar Anak), sync here
    final providerSelected = context.watch<AuthProvider>().selectedStudent;
    if (providerSelected.isNotEmpty && providerSelected != (_lastSyncedSelectedName ?? '')) {
      // Schedule post-frame to avoid setState in build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final found = _allSantri.firstWhere(
          (s) => s.namaLengkap == providerSelected,
          orElse: () => _selectedSantri ?? (_allSantri.isNotEmpty ? _allSantri.first : Santri(id: '', namaLengkap: '', namaPanggilan: '', tempatLahir: '', tanggalLahir: DateTime(2000,1,1), jenisKelamin: '', hobi: '', citaCita: '', agama: '', golonganDarah: '', fotoUrl: StudentData.defaultAvatarUrl, nomorInduk: '')),
        );
        if (found.namaLengkap != _selectedSantri?.namaLengkap) {
          setState(() {
            _selectedSantri = found;
            _lastSyncedSelectedName = found.namaLengkap;
          });
          _loadDetailForSelected();
        } else {
          _lastSyncedSelectedName = providerSelected;
        }
      });
    }
    return Scaffold(
      backgroundColor: AppStyles.primaryColor,
      appBar: CustomAppBar(
        title: 'Profil Santri',
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (!_isLoading && _allSantri.isNotEmpty) _buildStudentSelector(),
              if (!_isLoading && _allSantri.isNotEmpty) const SizedBox(height: 24),
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
                  child: _buildProfileDetails(),
                ),
              ),
            ],
          ),
          // Overlay for student selection
          if (_isStudentOverlayVisible)
            SearchOverlayWidget(
              isVisible: _isStudentOverlayVisible,
              title: 'Pilih Santri',
              items: _allSantri.map((s) => s.namaLengkap).toList(),
              selectedItem: _selectedSantri?.namaLengkap ?? '',
              onItemSelected: (nama) {
                setState(() {
                  _selectedSantri = _allSantri.firstWhere((s) => s.namaLengkap == nama, orElse: () => _selectedSantri ?? (_allSantri.isNotEmpty ? _allSantri.first : Santri(id: '', namaLengkap: '', namaPanggilan: '', tempatLahir: '', tanggalLahir: DateTime(2000,1,1), jenisKelamin: '', hobi: '', citaCita: '', agama: '', golonganDarah: '', fotoUrl: StudentData.defaultAvatarUrl, nomorInduk: '')));
                  _isStudentOverlayVisible = false;
                  _lastSyncedSelectedName = _selectedSantri?.namaLengkap;
                });
                Provider.of<AuthProvider>(context, listen: false).selectStudent(_selectedSantri!.namaLengkap);
                _loadDetailForSelected();
              },
              onClose: () {
                setState(() {
                  _isStudentOverlayVisible = false;
                });
              },
              searchHint: 'Cari santri...',
              avatarUrl: StudentData.defaultAvatarUrl,
            ),
        ],
      ),
    );
  }

  Widget _buildStudentSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: StudentSelectionWidget(
        selectedStudent: _selectedSantri?.namaLengkap ?? '',
        students: _allSantri.map((s) => s.namaLengkap).toList(),
        onStudentChanged: (nama) {
          setState(() {
            _selectedSantri = _allSantri.firstWhere((s) => s.namaLengkap == nama, orElse: () => _selectedSantri ?? (_allSantri.isNotEmpty ? _allSantri.first : Santri(id: '', namaLengkap: '', namaPanggilan: '', tempatLahir: '', tanggalLahir: DateTime(2000,1,1), jenisKelamin: '', hobi: '', citaCita: '', agama: '', golonganDarah: '', fotoUrl: StudentData.defaultAvatarUrl, nomorInduk: '')));
            _lastSyncedSelectedName = _selectedSantri?.namaLengkap;
          });
          // Update provider so Daftar Anak follows
          Provider.of<AuthProvider>(context, listen: false).selectStudent(_selectedSantri!.namaLengkap);
          _loadDetailForSelected();
        },
        onOverlayVisibilityChanged: (visible) {
          setState(() {
            _isStudentOverlayVisible = visible;
          });
        },
        avatarUrl: _selectedSantri?.fotoUrl,
      ),
    );
  }

  Widget _buildProfileDetails() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _error!,
            style: AppStyles.bodyText(context).copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_selectedSantri == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Data santri tidak tersedia.',
            style: AppStyles.bodyText(context),
          ),
        ),
      );
    }
    final s = _selectedSantri!;
    final d = _detail;
    String pick(dynamic v) => (v == null || v == false) ? '' : v.toString();
    String pickPair(dynamic v) => (v is List && v.length > 1) ? (v[1]?.toString() ?? '') : '';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pribadi',
            style: AppStyles.sectionTitle(context),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProfileDetailRow('Nama Lengkap', s.namaLengkap),
                _buildProfileDetailRow('Nama Panggilan', s.namaPanggilan),
                _buildProfileDetailRow('Nomor Induk (NIS)', s.nomorInduk),
                if (d != null) _buildProfileDetailRow('NISN', pick(d['nisn'])),
                _buildProfileDetailRow('Jenis Kelamin', s.jenisKelamin),
                _buildProfileDetailRow('Tempat Lahir', s.tempatLahir),
                _buildProfileDetailRow('Tanggal Lahir', s.tanggalLahir.year > 1900 ? DateFormat('dd MMMM yyyy', 'id_ID').format(s.tanggalLahir) : ''),
                if (d != null) _buildProfileDetailRow('Tahun Ajaran', pickPair(d['tahunajaran_id'])),
                if (d != null) _buildProfileDetailRow('Kelas/Ruang', pickPair(d['ruang_kelas_id'])),
                if (d != null) _buildProfileDetailRow('Jenjang', pick(d['jenjang'])),
                if (d != null) _buildProfileDetailRow('Tingkat', pickPair(d['tingkat'])),
                if (d != null) _buildProfileDetailRow('Musyrif', pickPair(d['musyrif_id'])),
                if (d != null) _buildProfileDetailRow('Kamar', pickPair(d['kamar_id'])),
                if (d != null) _buildProfileDetailRow('Halaqoh', pickPair(d['halaqoh_id'])),
                if (d != null) _buildProfileDetailRow('Penanggung Jawab', pickPair(d['penanggung_jawab_id'])),
                if (d != null) _buildProfileDetailRow('Nama Ayah', pick(d['ayah_nama'])),
                if (d != null) _buildProfileDetailRow('Nama Ibu', pick(d['ibu_nama'])),
                if (d != null) _buildProfileDetailRow('Nama Wali', pick(d['wali_nama'])),
                _buildProfileDetailRow('Agama', s.agama),
                _buildProfileDetailRow('Golongan Darah', s.golonganDarah),
                _buildProfileDetailRow('Hobi', s.hobi),
                _buildProfileDetailRow('Cita-Cita', s.citaCita),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailRow(String label, String value) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
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
              textAlign: TextAlign.right,
              style: AppStyles.bodyText(context).copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
