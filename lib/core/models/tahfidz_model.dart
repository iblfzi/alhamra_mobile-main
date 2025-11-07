enum TahfidzStatus {
  murojaah,
  mumtaz,
  jayyidJiddan,
  lancar,
  pentashihan,
  kurangLancar,
}

class TahfidzEntry {
  final String surahName;
  final TahfidzStatus status;
  final String id;
  final int jumlahBaris;
  final String keterangan;
  final String ustadPembimbing;
  final DateTime tanggal;
  // Optional fields from server for detailed rows
  final String? ayatAwal;
  final String? ayatAkhir;
  final int? pageAwal;
  final int? pageAkhir;
  final String? nilai;
  final String? stateLabel;

  TahfidzEntry({
    required this.surahName,
    required this.status,
    required this.id,
    required this.jumlahBaris,
    required this.keterangan,
    required this.ustadPembimbing,
    required this.tanggal,
    this.ayatAwal,
    this.ayatAkhir,
    this.pageAwal,
    this.pageAkhir,
    this.nilai,
    this.stateLabel,
  });
}

class StudentTahfidzProfile {
  final String studentId;
  final List<TahfidzEntry> entries;

  StudentTahfidzProfile({
    required this.studentId,
    required this.entries,
  });

  factory StudentTahfidzProfile.createMock(String id) {
    final now = DateTime.now();
    return StudentTahfidzProfile(
      studentId: id,
      entries: [
        TahfidzEntry(
          surahName: 'Al-Ma’idah',
          status: TahfidzStatus.murojaah,
          id: 'TQ/24.01.0421',
          jumlahBaris: 15,
          keterangan: 'Mengulang hafalan juz 6',
          ustadPembimbing: 'Ustadz Abdullah',
          tanggal: now.subtract(const Duration(days: 1)),
          ayatAwal: '1',
          ayatAkhir: '10',
          pageAwal: 1,
          pageAkhir: 2,
          nilai: 'Murojaah',
          stateLabel: 'Draft',
        ),
        TahfidzEntry(
          surahName: 'An-Nisa',
          status: TahfidzStatus.mumtaz,
          id: 'TQ/24.01.0422',
          jumlahBaris: 20,
          keterangan: 'Setoran baru halaman 50',
          ustadPembimbing: 'Ustadz Abdullah',
          tanggal: now.subtract(const Duration(days: 2)),
          ayatAwal: '20',
          pageAwal: 50,
          nilai: 'Mumtaz',
          stateLabel: 'Done',
        ),
        TahfidzEntry(
          surahName: 'Ali ‘Imran',
          status: TahfidzStatus.jayyidJiddan,
          id: 'TQ/24.01.0423',
          jumlahBaris: 10,
          keterangan: 'Hafalan lancar dengan sedikit catatan',
          ustadPembimbing: 'Ustadz Ibrahim',
          tanggal: now.subtract(const Duration(days: 4)),
          ayatAwal: '5',
          ayatAkhir: '15',
          pageAwal: 30,
          pageAkhir: 31,
          nilai: 'Jayyid Jiddan',
          stateLabel: 'Done',
        ),
        TahfidzEntry(
          surahName: 'Al-Baqarah',
          status: TahfidzStatus.kurangLancar,
          id: 'TQ/24.01.0424',
          jumlahBaris: 5,
          keterangan: 'Perlu banyak pengulangan, masih terbata-bata',
          ustadPembimbing: 'Ustadz Abdullah',
          tanggal: now.subtract(const Duration(days: 5)),
          ayatAwal: '253',
          nilai: '-',
          stateLabel: 'Draft',
        ),
        TahfidzEntry(
          surahName: 'Yusuf',
          status: TahfidzStatus.pentashihan,
          id: 'TQ/24.01.0425',
          jumlahBaris: 0,
          keterangan: 'Proses perbaikan makhraj dan tajwid',
          ustadPembimbing: 'Ustadz Ibrahim',
          tanggal: now.subtract(const Duration(days: 7)),
          nilai: 'Pentashihan',
          stateLabel: 'Draft',
        ),
        TahfidzEntry(
          surahName: 'Ar-Ra\'d',
          status: TahfidzStatus.lancar,
          id: 'TQ/24.01.0426',
          jumlahBaris: 12,
          keterangan: 'Setoran lancar tanpa pengulangan',
          ustadPembimbing: 'Ustadz Abdullah',
          tanggal: now.subtract(const Duration(days: 10)),
          nilai: 'Lancar',
          stateLabel: 'Done',
        ),
      ],
    );
  }
}
