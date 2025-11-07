enum TahsinStatus {
  murojaah,
  mumtaz,
  jayyidJiddan,
  lancar,
  pentashihan,
  kurangLancar,
}

class TahsinEntry {
  final String materi; // e.g., Makharijul Huruf, Sifatul Huruf, Ahkamul Madd
  final TahsinStatus status;
  final String id;
  final int jumlahBaris;
  final String keterangan;
  final String ustadPembimbing;
  final DateTime tanggal;

  TahsinEntry({
    required this.materi,
    required this.status,
    required this.id,
    required this.jumlahBaris,
    required this.keterangan,
    required this.ustadPembimbing,
    required this.tanggal,
  });
}

class StudentTahsinProfile {
  final String studentId;
  final List<TahsinEntry> entries;

  StudentTahsinProfile({
    required this.studentId,
    required this.entries,
  });

  factory StudentTahsinProfile.createMock(String id) {
    final now = DateTime.now();
    return StudentTahsinProfile(
      studentId: id,
      entries: [
        TahsinEntry(
          materi: 'Tartil',
          status: TahsinStatus.murojaah,
          id: 'TS/25.07.0001',
          jumlahBaris: 10,
          keterangan: 'Mengulang materi tartil dasar',
          ustadPembimbing: 'Ustadz Hasan',
          tanggal: now.subtract(const Duration(days: 1)),
        ),
        TahsinEntry(
          materi: 'Tartil',
          status: TahsinStatus.mumtaz,
          id: 'TS/25.07.0002',
          jumlahBaris: 15,
          keterangan: 'Bacaan sangat baik dan fasih',
          ustadPembimbing: 'Ustadz Hasan',
          tanggal: now.subtract(const Duration(days: 2)),
        ),
        TahsinEntry(
          materi: 'Tartil',
          status: TahsinStatus.jayyidJiddan,
          id: 'TS/25.07.0003',
          jumlahBaris: 12,
          keterangan: 'Bacaan baik dengan sedikit catatan',
          ustadPembimbing: 'Ustadz Umar',
          tanggal: now.subtract(const Duration(days: 4)),
        ),
        TahsinEntry(
          materi: 'Tartil',
          status: TahsinStatus.kurangLancar,
          id: 'TS/25.07.0004',
          jumlahBaris: 5,
          keterangan: 'Perlu banyak latihan, masih terbata-bata',
          ustadPembimbing: 'Ustadz Hasan',
          tanggal: now.subtract(const Duration(days: 5)),
        ),
        TahsinEntry(
          materi: 'Tartil',
          status: TahsinStatus.pentashihan,
          id: 'TS/25.07.0005',
          jumlahBaris: 0,
          keterangan: 'Proses perbaikan makhraj dan tajwid',
          ustadPembimbing: 'Ustadz Umar',
          tanggal: now.subtract(const Duration(days: 7)),
        ),
        TahsinEntry(
          materi: 'Tartil',
          status: TahsinStatus.lancar,
          id: 'TS/25.07.0006',
          jumlahBaris: 15,
          keterangan: 'Bacaan lancar tanpa pengulangan',
          ustadPembimbing: 'Ustadz Hasan',
          tanggal: now.subtract(const Duration(days: 10)),
        ),
      ],
    );
  }
}