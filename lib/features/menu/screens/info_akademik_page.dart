import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

import '../../../core/data/class_data.dart';
import '../../../core/data/student_data.dart';
import '../../../core/models/academic_info_model.dart';
import '../../../core/utils/app_styles.dart';
import '../../shared/widgets/index.dart';
import '../../shared/widgets/student_selection_widget.dart';

class InfoAkademikPage extends StatefulWidget {
  const InfoAkademikPage({super.key});

  @override
  State<InfoAkademikPage> createState() => _InfoAkademikPageState();
}

class _InfoAkademikPageState extends State<InfoAkademikPage> {
  // Mock Schedule Data
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

  // Generate mock data for student profiles
  final List<_StudentProfile> _allStudentData =
      StudentData.allStudents.map((nama) {
    int index = StudentData.allStudents.indexOf(nama);
    // Mock academic info
    final academicInfo = AcademicInfo(
      studentId: (index + 1).toString(), // Example
      kelas: 'IX 9',
      semester: 1,
      jumlahSiswa: 32,
      // The schedule is the same for all students in this mock data
      // In a real app, this would come from the student's class data
      // For this example, we'll use the static schedule defined above.
    );

    // Mock personal info
    return _StudentProfile(
      id: (index + 1).toString(),
      namaLengkap: nama,
      namaPanggilan: nama.split(' ').first, // Simple logic for nickname
      tempatLahir: ['Malang', 'Surabaya', 'Jakarta'][index % 3],
      tanggalLahir: '22 Juli 200${4 + index}',
      jenisKelamin: index % 2 == 0 ? 'Laki-Laki' : 'Perempuan',
      avatarUrl: StudentData.getStudentAvatar(nama),
      academicInfo: academicInfo,
    );
  }).toList();

  late _StudentProfile _selectedStudentProfile;
  String _selectedStudentName = StudentData.defaultStudent;
  bool _isStudentOverlayVisible = false;

  @override
  void initState() {
    super.initState();
    _updateSelectedData();
  }

  void _updateSelectedData() {
    _selectedStudentProfile = _allStudentData
        .firstWhere((student) => student.namaLengkap == _selectedStudentName);
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
                  child: _buildAcademicDetails(),
                ),
              ),
            ],
          ),
          if (_isStudentOverlayVisible)
            SearchOverlayWidget(
              isVisible: _isStudentOverlayVisible,
              title: 'Pilih Santri',
              items: StudentData.allStudents,
              selectedItem: _selectedStudentName,
              onItemSelected: (nama) {
                setState(() {
                  _selectedStudentName = nama;
                  _updateSelectedData();
                  _isStudentOverlayVisible = false;
                });
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
        students: StudentData.allStudents,
        onStudentChanged: (nama) {
          setState(() {
            _selectedStudentName = nama;
            _updateSelectedData();
          });
        },
        onOverlayVisibilityChanged: (visible) => setState(() => _isStudentOverlayVisible = visible),
        avatarUrl: StudentData.getStudentAvatar(_selectedStudentName),
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
          const SizedBox(height: 24),
          _buildJadwalPelajaranCard(),
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
          _buildDetailRow('Nama Lengkap', _selectedStudentProfile.namaLengkap),
          const Divider(height: 24),
          _buildDetailRow('Nama Panggilan', _selectedStudentProfile.namaPanggilan),
          const Divider(height: 24),
          _buildDetailRow('Tempat Lahir', _selectedStudentProfile.tempatLahir),
          const Divider(height: 24),
          _buildDetailRow('Tanggal Lahir', _selectedStudentProfile.tanggalLahir),
          const Divider(height: 24),
          _buildDetailRow('Jenis Kelamin', _selectedStudentProfile.jenisKelamin),
      ],
    ));
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
          _buildDetailRow(
              'Kelas', _selectedStudentProfile.academicInfo.kelas ?? '-'),
          const Divider(height: 24),
          _buildDetailRow('Semester',
              _selectedStudentProfile.academicInfo.semester?.toString() ?? '-'),
          const Divider(height: 24),
          _buildDetailRow('Jumlah Siswa',
              _selectedStudentProfile.academicInfo.jumlahSiswa?.toString() ?? '-'),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Navigate to a new page showing class details
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DetailKelasPage(
                    className: _selectedStudentProfile.academicInfo.kelas ?? 'Kelas',
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

  Widget _buildJadwalPelajaranCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jadwal Pelajaran',
            style: AppStyles.sectionTitle(context)
                .copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ..._jadwalPelajaran.map((jadwalHarian) {
          return _buildDailySchedule(jadwalHarian);
        }),
      ],
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppStyles.bodyText(context).copyWith(color: Colors.grey[600])),
        Text(value, style: AppStyles.bodyText(context).copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

// A private model class to hold all student data, including personal and academic.
class _StudentProfile {
  final String id;
  final String namaLengkap;
  final String namaPanggilan;
  final String tempatLahir;
  final String tanggalLahir;
  final String jenisKelamin;
  final String avatarUrl;
  final AcademicInfo academicInfo;

  _StudentProfile({
    required this.id,
    required this.namaLengkap,
    required this.namaPanggilan,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.avatarUrl,
    required this.academicInfo,
  });
}

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