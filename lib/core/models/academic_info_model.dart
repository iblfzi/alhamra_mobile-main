class MataPelajaran {
  final String jam;
  final String nama;

  MataPelajaran({
    required this.jam,
    required this.nama,
  });
}

class JadwalHarian {
  final String hari;
  final List<MataPelajaran> pelajaran;

  JadwalHarian({
    required this.hari,
    required this.pelajaran,
  });
}

class AcademicInfo {
  final String studentId;
  final String? kelas;
  final int? semester;
  final int? jumlahSiswa;

  // Old fields can be kept if they are used elsewhere,
  // or removed if they are no longer needed.
  // Making them nullable for backward compatibility.
  final double? nilaiRataRata;
  final int? peringkatKelas;
  final List<String>? catatanGuru;
  final List<String>? catatanPelanggaran;
  final int? hadir;
  final int? sakit;
  final int? izin;
  final int? alpha;

  AcademicInfo({
    required this.studentId,
    this.kelas,
    this.semester,
    this.jumlahSiswa,
    this.nilaiRataRata,
    this.peringkatKelas,
    this.catatanGuru,
    this.catatanPelanggaran,
    this.hadir,
    this.sakit,
    this.izin,
    this.alpha,
  });
}