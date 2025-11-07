enum AttendanceStatus { hadir, izin, alpa, libur }

class AttendanceDetail {
  final AttendanceStatus status;
  final String? reason;

  AttendanceDetail({required this.status, this.reason});
}

class AttendanceData {
  final String studentId;
  final double attendancePercentage;
  final int alphaCount;
  final int izinCount;
  final int hadirCount;
  final Map<DateTime, AttendanceDetail> dailyStatus;

  AttendanceData({
    required this.studentId,
    required this.attendancePercentage,
    required this.alphaCount,
    required this.izinCount,
    required this.hadirCount,
    required this.dailyStatus,
  });

  // Factory for mock data
  factory AttendanceData.createMock(String id) {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);

    return AttendanceData(
      studentId: id,
      attendancePercentage: 85.0,
      alphaCount: 1,
      izinCount: 2,
      hadirCount: 12,
      dailyStatus: {
        today.subtract(const Duration(days: 1)):
            AttendanceDetail(status: AttendanceStatus.hadir),
        today.subtract(const Duration(days: 2)):
            AttendanceDetail(status: AttendanceStatus.hadir),
        today.subtract(const Duration(days: 3)): AttendanceDetail(
            status: AttendanceStatus.alpa, reason: 'Ketiduran dan terlambat bangun.'),
        today.subtract(const Duration(days: 4)):
            AttendanceDetail(status: AttendanceStatus.hadir),
        today.subtract(const Duration(days: 7)): AttendanceDetail(
            status: AttendanceStatus.izin, reason: 'Sakit, ada surat keterangan dari dokter.'),
        today.subtract(const Duration(days: 8)):
            AttendanceDetail(status: AttendanceStatus.hadir),
        today.subtract(const Duration(days: 9)): AttendanceDetail(
            status: AttendanceStatus.izin, reason: 'Menghadiri acara keluarga di luar kota.'),
      },
    );
  }
}