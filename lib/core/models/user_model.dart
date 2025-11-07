class UserModel {
  final String uid;
  final String fullName;
  final String gender;
  final String phoneNumber;
  final String address;
  final String email;
  final DateTime? lastLogin;
  
  // Odoo specific fields
  final int? partnerId;
  final int? orangtuaId;
  final dynamic siswaId; // bisa false atau int
  final String? username;
  final String? avatar128;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.gender,
    required this.phoneNumber,
    required this.address,
    required this.email,
    this.lastLogin,
    this.partnerId,
    this.orangtuaId,
    this.siswaId,
    this.username,
    this.avatar128,
  });

  /// Factory constructor untuk data dari Odoo API
  factory UserModel.fromOdoo(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'].toString(),
      fullName: data['name'] ?? '',
      gender: '', // Tidak ada di response Odoo, bisa diambil dari API lain
      phoneNumber: '', // Tidak ada di response Odoo, bisa diambil dari API lain
      address: '', // Tidak ada di response Odoo, bisa diambil dari API lain
      email: data['username'] ?? '',
      partnerId: data['partner_id'] as int?,
      orangtuaId: data['orangtua_id'] as int?,
      siswaId: data['siswa_id'],
      username: data['username'] as String?,
      avatar128: data['avatar_128'] as String?,
      lastLogin: DateTime.now(),
    );
  }

  /// Factory constructor untuk data lokal (backward compatibility)
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      fullName: data['namaLengkap'] ?? data['name'] ?? '',
      gender: data['jenisKelamin'] ?? '',
      phoneNumber: data['nomorHp'] ?? '',
      address: data['alamatLengkap'] ?? '',
      email: data['emailPengguna'] ?? data['username'] ?? '',
      lastLogin: data['lastLogin'] != null 
          ? DateTime.parse(data['lastLogin']) 
          : null,
      partnerId: data['partner_id'] as int?,
      orangtuaId: data['orangtua_id'] as int?,
      siswaId: data['siswa_id'],
      username: data['username'] as String?,
      avatar128: data['avatar_128'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'namaLengkap': fullName,
      'name': fullName,
      'jenisKelamin': gender,
      'nomorHp': phoneNumber,
      'alamatLengkap': address,
      'emailPengguna': email,
      'username': username ?? email,
      'lastLogin': lastLogin?.toIso8601String(),
      'partner_id': partnerId,
      'orangtua_id': orangtuaId,
      'siswa_id': siswaId,
      'avatar_128': avatar128,
    };
  }
  
  /// Get avatar image from base64
  String? get avatarBase64 => avatar128;
  
  /// Check if user is a parent (orangtua)
  bool get isParent => orangtuaId != null && orangtuaId != false;
  
  /// Check if user is a student (siswa)
  bool get isStudent => siswaId != null && siswaId != false;
}
