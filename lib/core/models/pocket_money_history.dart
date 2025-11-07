
/// Tipe transaksi uang saku
enum PocketMoneyTransactionType { 
  incoming, // Dana masuk (dari orang tua)
  outgoing  // Dana keluar (pengeluaran santri)
}

/// Model riwayat uang saku
class PocketMoneyHistory {
  const PocketMoneyHistory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
    this.description,
    this.bankName = 'Bank Mandiri',
  });

  final String id;
  final String title;
  final String subtitle;
  final int amount; // dalam rupiah
  final DateTime date;
  final PocketMoneyTransactionType type;
  final String? description;
  final String bankName;

  /// Format amount ke string rupiah
  String get formattedAmount {
    final sign = type == PocketMoneyTransactionType.incoming ? '' : '- ';
    final s = amount.toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return '${sign}Rp ${s.replaceAllMapped(reg, (m) => '.')}';
  }

  /// Format tanggal dan waktu
  String get formattedDateTime {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year} $hour:$minute WIB';
  }

  PocketMoneyHistory copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? amount,
    DateTime? date,
    PocketMoneyTransactionType? type,
    String? description,
    String? bankName,
  }) {
    return PocketMoneyHistory(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      description: description ?? this.description,
      bankName: bankName ?? this.bankName,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'amount': amount,
        'date': date.toIso8601String(),
        'type': _typeToString(type),
        'description': description,
        'bankName': bankName,
      };

  factory PocketMoneyHistory.fromJson(Map<String, dynamic> json) {
    return PocketMoneyHistory(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      amount: (json['amount'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      type: _typeFromString(json['type'] as String),
      description: json['description'] as String?,
      bankName: json['bankName'] as String? ?? 'Bank Mandiri',
    );
  }

  static PocketMoneyTransactionType _typeFromString(String s) {
    switch (s.toLowerCase()) {
      case 'incoming':
      case 'masuk':
        return PocketMoneyTransactionType.incoming;
      case 'outgoing':
      case 'keluar':
        return PocketMoneyTransactionType.outgoing;
      default:
        return PocketMoneyTransactionType.incoming;
    }
  }

  static String _typeToString(PocketMoneyTransactionType type) {
    switch (type) {
      case PocketMoneyTransactionType.incoming:
        return 'incoming';
      case PocketMoneyTransactionType.outgoing:
        return 'outgoing';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PocketMoneyHistory && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PocketMoneyHistory(id: $id, title: $title, type: ${_typeToString(type)})';
}
