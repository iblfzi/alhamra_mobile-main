class StudentData {
  static const List<String> allStudents = [
    'Naufal Ramadhan',
    'Aisyah Zahra',
    'Ahmad Fauzi',
    'Budi Santoso',
    'Siti Aisyah',
    'Nurul Huda',
    'Rahmat Hidayat',
  ];

  static const String defaultStudent = 'Naufal Ramadhan';

  static const String defaultAvatarUrl = 'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

  static bool isValidStudent(String studentName) {
    return allStudents.contains(studentName);
  }

  static String getStudentAvatar(String studentName) {
    // For now, return the same avatar for all students
    // In the future, this could return different avatars per student
    return defaultAvatarUrl;
  }
}
