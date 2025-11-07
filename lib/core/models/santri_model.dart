
/// Model data untuk Santri
class Santri {
  final String id;
  final String namaLengkap;
  final String namaPanggilan;
  final String tempatLahir;
  final DateTime tanggalLahir;
  final String jenisKelamin;
  final String hobi;
  final String citaCita;
  final String agama;
  final String golonganDarah;
  final String fotoUrl;
  final String nomorInduk;

  Santri({
    required this.id,
    required this.namaLengkap,
    required this.namaPanggilan,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.hobi,
    required this.citaCita,
    required this.agama,
    required this.golonganDarah,
    required this.fotoUrl,
    required this.nomorInduk,
  });

  /// Fungsi untuk mendapatkan inisial nama
  String get inisial {
    if (namaLengkap.isEmpty) return '';
    List<String> parts = namaLengkap.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length > 1) {
      return parts.first[0].toUpperCase() + parts.last[0].toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '';
  }

  /// Factory constructor for creating a new Santri instance from a map.
  factory Santri.fromMap(Map<String, dynamic> map) {
    return Santri(
      id: map['id'] ?? '',
      namaLengkap: map['namaLengkap'] ?? '',
      namaPanggilan: map['namaPanggilan'] ?? '',
      tempatLahir: map['tempatLahir'] ?? '',
      tanggalLahir: DateTime.parse(map['tanggalLahir']),
      jenisKelamin: map['jenisKelamin'] ?? '',
      hobi: map['hobi'] ?? '',
      citaCita: map['citaCita'] ?? '',
      agama: map['agama'] ?? '',
      golonganDarah: map['golonganDarah'] ?? '',
      fotoUrl: map['fotoUrl'] ?? '',
      nomorInduk: map['nomorInduk'] ?? '',
    );
  }

  /// A method for converting a Santri instance to a map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaLengkap': namaLengkap,
      'namaPanggilan': namaPanggilan,
      'tempatLahir': tempatLahir,
      'tanggalLahir': tanggalLahir.toIso8601String(),
      'jenisKelamin': jenisKelamin,
      'hobi': hobi,
      'citaCita': citaCita,
      'agama': agama,
      'golonganDarah': golonganDarah,
      'fotoUrl': fotoUrl,
      'nomorInduk': nomorInduk,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Santri &&
      other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
