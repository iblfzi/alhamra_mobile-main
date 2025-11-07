// Data models for notifications
class NotificationItem {
  final String id;
  final String title;
  final String amount;
  final NotificationType type;
  final NotificationStatus status;
  final DateTime date;
  final String section;

  NotificationItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.status,
    required this.date,
    required this.section,
  });
}

enum NotificationType {
  transaksi,
  perijinan,
  pengumuman,
}

enum NotificationStatus {
  approved,
  pending,
  rejected,
  read,
  unread,
}
