import 'dart:math';

enum SubjectCategory { diniyah, umum }

class GradeDetails {
  final int? uts;
  final int? uas;
  final int? tugas;
  final int? praktikum;

  GradeDetails({this.uts, this.uas, this.tugas, this.praktikum});

  // Mock data for grades
  factory GradeDetails.createMock() {
    final random = Random();
    // Some subjects might not have all grade components
    return GradeDetails(
      uts: random.nextBool() ? 70 + random.nextInt(31) : null, // 70-100 or null
      uas: random.nextBool() ? 70 + random.nextInt(31) : null,
      tugas: random.nextBool() ? 75 + random.nextInt(26) : null,
      praktikum: random.nextBool() ? 80 + random.nextInt(21) : null,
    );
  }

  // Calculate average score
  double get average {
    int count = 0;
    int total = 0;
    if (uts != null) { total += uts!; count++; }
    if (uas != null) { total += uas!; count++; }
    if (tugas != null) { total += tugas!; count++; }
    if (praktikum != null) { total += praktikum!; count++; }
    return count > 0 ? total / count : 0.0;
  }
}

class Subject {
  final String name;
  final SubjectCategory category;
  final GradeDetails grades;

  Subject({required this.name, required this.category, required this.grades});
}

class StudentGradeProfile {
  final String studentId;
  final String namaLengkap;
  final String namaPanggilan;
  final String tempatLahir;
  final String tanggalLahir;
  final String kelas;
  final String jenisKelamin;
  final List<Subject> subjects;

  StudentGradeProfile({
    required this.studentId,
    required this.namaLengkap,
    required this.namaPanggilan,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.kelas,
    required this.jenisKelamin,
    required this.subjects,
  });

  // Factory for mock data
  factory StudentGradeProfile.createMock(String id, String name) {
    return StudentGradeProfile(
      studentId: id,
      namaLengkap: name,
      namaPanggilan: name.split(' ').first,
      tempatLahir: 'Malang',
      tanggalLahir: '22 Juli 2004',
      kelas: 'IX 9',
      jenisKelamin: 'Laki-Laki',
      subjects: [
        Subject(name: 'Tahfidz Qur’an', category: SubjectCategory.diniyah, grades: GradeDetails.createMock()),
        Subject(name: 'Tahsin Qur’an', category: SubjectCategory.diniyah, grades: GradeDetails.createMock()),
        Subject(name: 'Hadis', category: SubjectCategory.diniyah, grades: GradeDetails.createMock()),
        Subject(name: 'Fiqih', category: SubjectCategory.diniyah, grades: GradeDetails.createMock()),
        Subject(name: 'Matematika', category: SubjectCategory.umum, grades: GradeDetails.createMock()),
        Subject(name: 'Bahasa Indonesia', category: SubjectCategory.umum, grades: GradeDetails.createMock()),
        Subject(name: 'Bahasa Inggris', category: SubjectCategory.umum, grades: GradeDetails.createMock()),
        Subject(name: 'Olahraga', category: SubjectCategory.umum, grades: GradeDetails.createMock()),
      ],
    );
  }
}