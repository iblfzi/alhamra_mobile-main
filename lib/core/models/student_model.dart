class StudentModel {
  final int id;
  final String name;
  final String? nis; // Nomor Induk Siswa
  final int? partnerId;
  final String? gender;
  final String? birthDate;
  final String? className;
  final String? avatar128;

  StudentModel({
    required this.id,
    required this.name,
    this.nis,
    this.partnerId,
    this.gender,
    this.birthDate,
    this.className,
    this.avatar128,
  });

  /// Factory constructor untuk data dari Odoo API
  factory StudentModel.fromOdoo(Map<String, dynamic> data) {
    return StudentModel(
      id: data['id'] as int,
      name: data['name'] ?? '',
      nis: data['nis'] as String?,
      partnerId: data['partner_id'] is List 
          ? (data['partner_id'] as List)[0] as int?
          : data['partner_id'] as int?,
      gender: data['gender'] as String?,
      birthDate: data['birth_date'] as String?,
      className: data['class_name'] as String?,
      avatar128: data['avatar_128'] as String?,
    );
  }

  /// Factory constructor untuk data lokal (backward compatibility)
  factory StudentModel.fromMap(Map<String, dynamic> data) {
    return StudentModel(
      id: data['id'] as int,
      name: data['name'] ?? '',
      nis: data['nis'] as String?,
      partnerId: data['partner_id'] as int?,
      gender: data['gender'] as String?,
      birthDate: data['birth_date'] as String?,
      className: data['class_name'] as String?,
      avatar128: data['avatar_128'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nis': nis,
      'partner_id': partnerId,
      'gender': gender,
      'birth_date': birthDate,
      'class_name': className,
      'avatar_128': avatar128,
    };
  }

  /// Get display ID (NIS atau ID)
  String get displayId => nis ?? id.toString();

  /// Get gender display
  String get genderDisplay {
    if (gender == 'male') return 'Laki-laki';
    if (gender == 'female') return 'Perempuan';
    return '-';
  }
}
