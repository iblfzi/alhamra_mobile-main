
/// Tipe transaksi dompet
enum WalletTransactionType { 
  topup,    // Top up saldo
  payment,  // Pembayaran tagihan
  transfer, // Transfer antar akun
  refund    // Pengembalian dana
}

/// Model riwayat dompet
class WalletHistory {
  const WalletHistory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
    this.description,
    this.bankName = 'Bank Mandiri',
    this.referenceId,
  });

  final String id;
  final String title;
  final String subtitle;
  final int amount; // dalam rupiah
  final DateTime date;
  final WalletTransactionType type;
  final String? description;
  final String bankName;
  final String? referenceId;

  /// Format amount ke string rupiah
  String get formattedAmount {
    final sign = (type == WalletTransactionType.payment || type == WalletTransactionType.transfer) ? '- ' : '';
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

  /// Warna berdasarkan tipe transaksi
  bool get isPositive => type == WalletTransactionType.topup || type == WalletTransactionType.refund;

  WalletHistory copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? amount,
    DateTime? date,
    WalletTransactionType? type,
    String? description,
    String? bankName,
    String? referenceId,
  }) {
    return WalletHistory(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      description: description ?? this.description,
      bankName: bankName ?? this.bankName,
      referenceId: referenceId ?? this.referenceId,
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
        'referenceId': referenceId,
      };

  factory WalletHistory.fromJson(Map<String, dynamic> json) {
    return WalletHistory(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      amount: (json['amount'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      type: _typeFromString(json['type'] as String),
      description: json['description'] as String?,
      bankName: json['bankName'] as String? ?? 'Bank Mandiri',
      referenceId: json['referenceId'] as String?,
    );
  }

  static WalletTransactionType _typeFromString(String s) {
    switch (s.toLowerCase()) {
      case 'topup':
      case 'top_up':
        return WalletTransactionType.topup;
      case 'payment':
      case 'pembayaran':
        return WalletTransactionType.payment;
      case 'transfer':
        return WalletTransactionType.transfer;
      case 'refund':
      case 'pengembalian':
        return WalletTransactionType.refund;
      default:
        return WalletTransactionType.topup;
    }
  }

  static String _typeToString(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.topup:
        return 'topup';
      case WalletTransactionType.payment:
        return 'payment';
      case WalletTransactionType.transfer:
        return 'transfer';
      case WalletTransactionType.refund:
        return 'refund';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletHistory && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WalletHistory(id: $id, title: $title, type: ${_typeToString(type)})';
}
