import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/class_data.dart';
import '../../../core/data/student_data.dart';
import '../../../core/models/academic_info_model.dart';
import '../../../core/services/odoo_api_service.dart';
import '../../../core/utils/app_styles.dart';
import '../../shared/widgets/index.dart';
import '../../shared/widgets/student_selection_widget.dart';

class InfoAkademikPage extends StatefulWidget {
  const InfoAkademikPage({super.key});

  @override
  State<InfoAkademikPage> createState() => _InfoAkademikPageState();
}

class _InfoAkademikPageState extends State<InfoAkademikPage> {
  // Mock Schedule Data (tetap)
  final List<JadwalHarian> _jadwalPelajaran = [
    JadwalHarian(hari: 'Senin', pelajaran: [
      MataPelajaran(jam: '07:00 - 08:30', nama: 'Matematika'),
      MataPelajaran(jam: '08:30 - 10:00', nama: 'Bahasa Indonesia'),
      MataPelajaran(jam: '10:30 - 12:00', nama: 'Fisika'),
    ]),
    JadwalHarian(hari: 'Selasa', pelajaran: [
      MataPelajaran(jam: '07:00 - 08:30', nama: 'Kimia'),
      MataPelajaran(jam: '08:30 - 10:00', nama: 'Bahasa Inggris'),
    ]),
    JadwalHarian(hari: 'Rabu', pelajaran: [
      MataPelajaran(jam: '07:00 - 08:30', nama: 'Biologi'),
      MataPelajaran(jam: '08:30 - 10:00', nama: 'Sejarah'),
      MataPelajaran(jam: '10:30 - 12:00', nama: 'Penjaskes'),
    ]),
    JadwalHarian(hari: 'Kamis', pelajaran: [
      MataPelajaran(jam: '07:00 - 08:30', nama: 'Matematika'),
      MataPelajaran(jam: '08:30 - 10:00', nama: 'Bahasa Arab'),
    ]),
    JadwalHarian(hari: 'Jumat', pelajaran: [
      MataPelajaran(jam: '07:00 - 08:30', nama: 'Fiqih'),
      MataPelajaran(jam: '08:30 - 10:00', nama: 'Aqidah Akhlak'),
    ]),
  ];

  // State dari API
  final OdooApiService _odoo = OdooApiService();
  Map<String, String> _nameToId = {};
  List<String> _childrenNames = [];
  String _selectedStudentName = StudentData.defaultStudent;
  String? _selectedSiswaId;
  bool _isStudentOverlayVisible = false;
  bool _isLoading = true;
  String? _error;

  // Profil akademik yang ditampilkan
  String _namaLengkap = '-';
  String _namaPanggilan = '-';
  String _tempatLahir = '-';
  String _tanggalLahir = '-';
  String _jenisKelamin = '-';
  String _kelas = '-';
  String _semester = '-';
  String _jumlahSiswa = '-';
  String _avatarUrl = '';
  // Data sekolah tambahan
  String _nis = '';
  String _nisn = '';
  String _tahunAjaran = '';
  String _kelasRuang = '';
  String _jenjang = '';
  String _tingkat = '';
  String _musyrif = '';
  String _kamar = '';
  String _halaqoh = '';
  String _penanggungJawab = '';

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Ambil siswa_id yang terakhir dipilih
      final prefs = await SharedPreferences.getInstance();
      final savedSiswaId = prefs.getString('siswa_id');

      // Ambil daftar anak dari server untuk peta nama→id
      final children = await _odoo.getChildren();
      _nameToId.clear();
      final names = <String>[];
      for (final c in children) {
        final name = (c['name'] ?? c['nama'] ?? '').toString();
        final id = (c['siswa_id'] ?? c['student_id'] ?? c['id'])?.toString() ?? '';
        if (name.isNotEmpty && id.isNotEmpty) {
          names.add(name);
          _nameToId[name] = id;
        }
      }

      // Tentukan yang dipilih berdasar siswa_id atau pakai pertama
      String? selectedName;
      if (savedSiswaId != null && savedSiswaId.isNotEmpty) {
        selectedName = _nameToId.entries.firstWhere(
          (e) => e.value == savedSiswaId,
          orElse: () => const MapEntry('', ''),
        ).key;
      }
      if (selectedName == null || selectedName.isEmpty) {
        selectedName = names.isNotEmpty ? names.first : _selectedStudentName;
      }

      setState(() {
        _childrenNames = names.isEmpty ? [StudentData.defaultStudent] : names;
        _selectedStudentName = selectedName!;
        _selectedSiswaId = _nameToId[_selectedStudentName];
      });

      // Fetch profil akademik
      await _loadProfile();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadProfile() async {
    try {
      final idStr = _selectedSiswaId;
      if (idStr == null || idStr.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'Siswa belum dipilih.';
        });
        return;
      }
      final id = int.tryParse(idStr) ?? -1;
      if (id < 0) {
        setState(() {
          _isLoading = false;
          _error = 'ID siswa tidak valid.';
        });
        return;
      }

      final data = await _odoo.getStudentProfile(id);

      String g = (data['gender'] ?? data['jenis_kelamin'] ?? data['jns_kelamin'] ?? '-').toString();
      if (g.isNotEmpty && g != '-') {
        final low = g.toLowerCase();
        if (low == 'l' || low.startsWith('m')) g = 'Laki-Laki';
        if (low == 'p' || low.startsWith('f') || low.contains('perem')) g = 'Perempuan';
      }

      String pick(dynamic v) => (v == null || v == false) ? '' : v.toString();
      String pickPair(dynamic v) {
        if (v is List && v.length > 1) {
          final s = v[1];
          return s?.toString() ?? '';
        }
        return v is String ? v : '';
      }

      setState(() {
        _namaLengkap = (data['name'] ?? data['nama'] ?? _selectedStudentName).toString();
        _namaPanggilan = (data['nickname'] ?? data['nama_panggilan'] ?? data['nama_pgl'] ?? _selectedStudentName.split(' ').first).toString();
        _tempatLahir = (data['birth_place'] ?? data['tempat_lahir'] ?? data['tmp_lahir'] ?? '-').toString();
        _tanggalLahir = (data['birth_date'] ?? data['tanggal_lahir'] ?? data['tgl_lahir'] ?? '-').toString();
        _jenisKelamin = g.isEmpty ? '-' : g;
        // Kelas: coba string langsung, lalu pair id-name
        String kelasStr = (data['class_name'] ?? data['kelas_name'] ?? data['kelas'] ?? data['rombel_name'] ?? data['rombel'] ?? '').toString();
        if (kelasStr.isEmpty) kelasStr = pickPair(data['rombel_id']);
        if (kelasStr.isEmpty) kelasStr = pickPair(data['kelas_id']);
        if (kelasStr.isEmpty) kelasStr = pickPair(data['ruang_kelas_id']);
        _kelas = kelasStr.isEmpty ? '-' : kelasStr;
        // Semester: string atau pair
        String semStr = (data['semester'] ?? data['semester_name'] ?? data['semester_ke'] ?? '').toString();
        if (semStr.isEmpty) semStr = pickPair(data['semester_id']);
        _semester = semStr;
        // Jumlah siswa: banyak variasi nama
        String jml = (data['students_count'] ?? data['jumlah_siswa'] ?? data['jumlah_santri'] ?? data['rombel_student_count'] ?? data['rombel_siswa_count'] ?? data['class_size'] ?? data['student_count'] ?? '').toString();
        _jumlahSiswa = jml;
        _avatarUrl = (data['avatar'] ?? data['avatar_url'] ?? '').toString();
        // Data sekolah tambahan
        _nis = (data['nis'] ?? data['NIS'] ?? '').toString();
        _nisn = (data['nisn'] ?? '').toString();
        _tahunAjaran = pickPair(data['tahunajaran_id']);
        _kelasRuang = pickPair(data['ruang_kelas_id']);
        _jenjang = pick(data['jenjang'] ?? data['jenjang_name']);
        _tingkat = pickPair(data['tingkat']);
        _musyrif = pickPair(data['musyrif_id']);
        _kamar = pickPair(data['kamar_id']);
        _halaqoh = pickPair(data['halaqoh_id']);
        _penanggungJawab = pickPair(data['penanggung_jawab_id']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.primaryColor,
      appBar: CustomAppBar(
        title: 'Info Akademik',
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppStyles.primaryColor))
                      : _error != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 12),
                                    Text(_error!, textAlign: TextAlign.center),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: _initLoad,
                                      child: const Text('Coba Lagi'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _buildAcademicDetails(),
                ),
              ),
            ],
          ),
          if (_isStudentOverlayVisible)
            SearchOverlayWidget(
              isVisible: _isStudentOverlayVisible,
              title: 'Pilih Santri',
              items: _childrenNames.isEmpty ? [StudentData.defaultStudent] : _childrenNames,
              selectedItem: _selectedStudentName,
              onItemSelected: (nama) async {
                final id = _nameToId[nama];
                if (id != null && id.isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('siswa_id', id);
                }
                setState(() {
                  _selectedStudentName = nama;
                  _selectedSiswaId = id;
                  _isStudentOverlayVisible = false;
                  _isLoading = true;
                  _error = null;
                });
                await _loadProfile();
              },
              onClose: () => setState(() => _isStudentOverlayVisible = false),
              searchHint: 'Cari santri...',
              avatarUrl: StudentData.getStudentAvatar(_selectedStudentName),
            ),
        ],
      ),
    );
  }

  

  Widget _buildStudentSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: StudentSelectionWidget(
        selectedStudent: _selectedStudentName,
        students: _childrenNames.isEmpty ? [StudentData.defaultStudent] : _childrenNames,
        onStudentChanged: (nama) async {
          final id = _nameToId[nama];
          if (id != null && id.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('siswa_id', id);
          }
          setState(() {
            _selectedStudentName = nama;
            _selectedSiswaId = id;
            _isLoading = true;
            _error = null;
          });
          await _loadProfile();
        },
        onOverlayVisibilityChanged: (visible) => setState(() => _isStudentOverlayVisible = visible),
        avatarUrl: _avatarUrl.isNotEmpty ? _avatarUrl : StudentData.getStudentAvatar(_selectedStudentName),
      ),
    );
  }

  Widget _buildAcademicDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataDiriCard(),
          const SizedBox(height: 24),
          _buildKelasCard(),
          // Jadwal kelas dilewati sementara
        ],
      ),
    );
  }

  Widget _buildDataDiriCard() {
    return CustomCardWidget(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Data Diri Santri', style: AppStyles.sectionTitle(context)),
          const SizedBox(height: 16),
          _buildDetailRow('Nama Lengkap', _namaLengkap),
          const Divider(height: 24),
          _buildDetailRow('Nama Panggilan', _namaPanggilan),
          const Divider(height: 24),
          _buildDetailRow('Tempat Lahir', _tempatLahir),
          const Divider(height: 24),
          _buildDetailRow('Tanggal Lahir', _tanggalLahir),
          const Divider(height: 24),
          _buildDetailRow('Jenis Kelamin', _jenisKelamin),
          // Data sekolah digabungkan ke Data Diri
          const Divider(height: 24),
          _buildDetailRow('NIS', _nis.isEmpty ? '-' : _nis),
          const Divider(height: 24),
          _buildDetailRow('NISN', _nisn.isEmpty ? '-' : _nisn),
          const Divider(height: 24),
          _buildDetailRow('Tahun Ajaran', _tahunAjaran.isEmpty ? '-' : _tahunAjaran),
          const Divider(height: 24),
          _buildDetailRow('Kelas/Ruang', _kelasRuang.isEmpty ? '-' : _kelasRuang),
          const Divider(height: 24),
          _buildDetailRow('Jenjang', _jenjang.isEmpty ? '-' : _jenjang),
          const Divider(height: 24),
          _buildDetailRow('Tingkat', _tingkat.isEmpty ? '-' : _tingkat),
          const Divider(height: 24),
          _buildDetailRow('Musyrif', _musyrif.isEmpty ? '-' : _musyrif),
          const Divider(height: 24),
          _buildDetailRow('Kamar', _kamar.isEmpty ? '-' : _kamar),
          const Divider(height: 24),
          _buildDetailRow('Halaqoh', _halaqoh.isEmpty ? '-' : _halaqoh),
          const Divider(height: 24),
          _buildDetailRow('Penanggung Jawab', _penanggungJawab.isEmpty ? '-' : _penanggungJawab),
        ],
      ),
    );
  }

  Widget _buildKelasCard() {
    return CustomCardWidget(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Data Kelas Yang Ditempati Anak',
              style: AppStyles.sectionTitle(context)),
          const SizedBox(height: 16),
          _buildDetailRow('Kelas', _kelas),
          const Divider(height: 24),
          _buildDetailRow('Semester', _semester.isEmpty ? '-' : _semester),
          const Divider(height: 24),
          _buildDetailRow('Jumlah Siswa', _jumlahSiswa.isEmpty ? '-' : _jumlahSiswa),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Navigate to a new page showing class details
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DetailKelasPage(
                    className: _kelas.isEmpty ? 'Kelas' : _kelas,
                  ),
                ));
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Lihat Detail',
                      style: TextStyle(color: AppStyles.primaryColor)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios,
                      size: 14, color: AppStyles.primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySchedule(JadwalHarian jadwal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            jadwal.hari,
            style: AppStyles.bodyText(context).copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppStyles.darkGreyColor,
            ),
          ),
          const SizedBox(height: 12),
          if (jadwal.pelajaran.isEmpty)
            const Text('Tidak ada jadwal untuk hari ini.')
          else
            CustomCardWidget(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: jadwal.pelajaran.length,
                itemBuilder: (context, index) {
                  final mapel = jadwal.pelajaran[index];
                  return _buildScheduleItem(mapel);
                },
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(MataPelajaran mapel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppStyles.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.schedule,
                color: AppStyles.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mapel.nama,
                  style: AppStyles.bodyText(context)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  mapel.jam,
                  style: AppStyles.bodyText(context)
                      .copyWith(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: AppStyles.bodyText(context).copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.bodyText(context)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

// A private model class to hold all student data, including personal and academic.
// Model mock AcademicInfo tetap dipakai untuk jadwal saja

/// A new page to display the list of students in a class.
class DetailKelasPage extends StatelessWidget {
  final String className;

  const DetailKelasPage({super.key, required this.className});

  @override
  Widget build(BuildContext context) {
    // Using mock data for demonstration
    final List<String> studentsInClass = ClassData.studentsInClass;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Daftar Santri $className'),
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DataTable(
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(
                          label: Text('No.',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Nama Santri',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('NIS',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: studentsInClass.asMap().entries.map((entry) {
                      final index = entry.key;
                      final studentName = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(Text((index + 1).toString())),
                          DataCell(Text(studentName)),
                          DataCell(Text('12345${index + 1}')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download_outlined),
                label: const Text('Download PDF'),
                onPressed: () {
                  _generateAndSavePdf(context, className, studentsInClass);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAndSavePdf(
      BuildContext context, String className, List<String> students) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Membuat PDF...')),
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context pdfContext) => [
          pw.Header(
            level: 0,
            child: pw.Text('Daftar Santri Kelas $className',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20)),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['No.', 'Nama Santri', 'NIS'],
            data: List<List<String>>.generate(
              students.length,
              (index) => [
                (index + 1).toString(),
                students[index],
                '12345${index + 1}', // Example NIS from list
              ],
            ),
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 30,
            cellPadding: const pw.EdgeInsets.all(5),
            cellAlignments: {
              0: pw.Alignment.centerRight,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerRight,
            },
          ),
        ],
      ),
    );

    try {
      final output = await getTemporaryDirectory();
      final fileName = 'daftar_santri_${className.replaceAll(' ', '_')}.pdf';
      final file = File("${output.path}/$fileName");
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF berhasil disimpan di folder sementara aplikasi.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}