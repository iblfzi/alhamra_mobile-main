
/// Status tagihan
/// - unpaid: Belum Bayar
/// - partial: Terbayar Sebagian
/// - paid: Lunas
enum BillStatus { pending, unpaid, partial, paid }

/// Model data Tagihan untuk integrasi API.
/// Pisahkan state UI (mis. selected) dari model ini.
class Bill {
  const Bill({
    required this.id,
    required this.title,
    this.subtitle,
    required this.amount,
    this.amountPaid,
    required this.dueDate,
    required this.status,
    required this.period,
  });

  final String id;
  final String title;
  final String? subtitle;
  /// Total nominal tagihan (dalam rupiah)
  final int amount;
  /// Nominal yang sudah dibayar (opsional; gunakan untuk menghitung outstanding saat status partial)
  final int? amountPaid;
  final DateTime dueDate;
  final BillStatus status;
  /// Periode seperti "November 2024"
  final String period;

  /// Tagihan masih bisa dibayar jika status bukan paid (lunas)
  bool get isPayable => status == BillStatus.unpaid || status == BillStatus.partial;

  /// Sisa yang harus dibayar (outstanding). Jika paid, maka 0.
  int get outstanding {
    if (status == BillStatus.paid) return 0;
    final paid = amountPaid ?? 0;
    final out = amount - paid;
    return out < 0 ? 0 : out;
  }

  Bill copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? amount,
    int? amountPaid,
    DateTime? dueDate,
    BillStatus? status,
    String? period,
  }) {
    return Bill(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      amount: amount ?? this.amount,
      amountPaid: amountPaid ?? this.amountPaid,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      period: period ?? this.period,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'amount': amount,
        'amountPaid': amountPaid,
        'dueDate': dueDate.toIso8601String(),
        'status': _statusToString(status),
        'period': period,
      };

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      amount: (json['amount'] as num).toInt(),
      amountPaid: json['amountPaid'] == null ? null : (json['amountPaid'] as num).toInt(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: _statusFromString(json['status'] as String),
      period: json['period'] as String,
    );
  }

  static BillStatus _statusFromString(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
      case 'menunggu':
        return BillStatus.pending;
      case 'unpaid':
      case 'belum_bayar':
      case 'belum bayar':
        return BillStatus.unpaid;
      case 'partial':
      case 'terbayar_sebagian':
      case 'terbayar sebagian':
        return BillStatus.partial;
      case 'paid':
      case 'lunas':
        return BillStatus.paid;
      default:
        return BillStatus.unpaid;
    }
  }

  static String _statusToString(BillStatus status) {
    switch (status) {
      case BillStatus.pending:
        return 'pending';
      case BillStatus.unpaid:
        return 'unpaid';
      case BillStatus.partial:
        return 'partial';
      case BillStatus.paid:
        return 'paid';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bill && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Bill(id: $id, title: $title, status: ${_statusToString(status)})';
}
