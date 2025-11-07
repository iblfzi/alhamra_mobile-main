 // lib/features/home/data/dashboard_data.dart
 
 /// Model untuk data keuangan di dashboard.
 class KeuanganOverview {
   final String totalTagihan;
   final String saldoUangSaku;
   final String saldoDompet;
   final double persentaseLunas;
 
   KeuanganOverview({
     required this.totalTagihan,
     required this.saldoUangSaku,
     required this.saldoDompet,
     required this.persentaseLunas,
   });
 }
 
 /// Model untuk data kesantrian di dashboard.
 class KesantrianOverview {
   final String totalHafalan;
   final String setoranTerakhir;
   final String detailSetoran;
   final int jumlahPelanggaran;
   final int jumlahIzin;
 
   KesantrianOverview({
     required this.totalHafalan,
     required this.setoranTerakhir,
     required this.detailSetoran,
     required this.jumlahPelanggaran,
     required this.jumlahIzin,
   });
 }
 
 /// Model untuk data akademik di dashboard.
 class AkademikOverview {
   final int totalAbsen;
   final double rataRataNilai;
   final List<NilaiBulanan> perkembanganNilai;
 
   AkademikOverview({
     required this.totalAbsen,
     required this.rataRataNilai,
     required this.perkembanganNilai,
   });
 }
 
 /// Model untuk data nilai per bulan (untuk chart).
 class NilaiBulanan {
   final String bulan;
   final double nilai;
 
   NilaiBulanan(this.bulan, this.nilai);
 }
 
 /// Kelas utama yang menampung semua data overview.
 class DashboardData {
   final KeuanganOverview keuangan;
   final KesantrianOverview kesantrian;
   final AkademikOverview akademik;
 
   DashboardData({
     required this.keuangan,
     required this.kesantrian,
     required this.akademik,
   });
 
   /// Factory untuk membuat data dummy/contoh.
   factory DashboardData.getSampleData() {
     return DashboardData(
       keuangan: KeuanganOverview(
         totalTagihan: 'Rp 2.000.000',
         saldoUangSaku: 'Rp 100.000',
         saldoDompet: 'Rp 200.000',
         persentaseLunas: 70,
       ),
       kesantrian: KesantrianOverview(
         totalHafalan: '10 Juz',
         setoranTerakhir: 'Al-Baqarah Ayat 1-10',
         detailSetoran: '5 Halaman, Ayat 1-10 Juz 1',
         jumlahPelanggaran: 2,
         jumlahIzin: 3,
       ),
       akademik: AkademikOverview(
         totalAbsen: 5,
         rataRataNilai: 85.5,
         perkembanganNilai: [
           NilaiBulanan('Okt', 80),
           NilaiBulanan('Nov', 85),
           NilaiBulanan('Des', 82),
           NilaiBulanan('Jan', 90),
           NilaiBulanan('Feb', 88),
           NilaiBulanan('Agu', 92), // Sesuai request, mungkin maksudnya bulan lain (e.g., Mar)
         ],
       ),
     );
   }
 }