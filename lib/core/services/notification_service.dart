import 'package:flutter/foundation.dart';
import '../../../core/models/notification_model.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Sample notification data - in real app this would come from API/database
  final List<NotificationItem> _notifications = [
    // Minggu Ini - some unread
    NotificationItem(
      id: 'INV/083/329382',
      title: 'Ket. Pembayaran Seragam XL Santri Naufal Ramadhan',
      amount: 'Rp. 2.500.000',
      type: NotificationType.transaksi,
      status: NotificationStatus.unread,
      date: DateTime.now().subtract(const Duration(days: 2)),
      section: 'Minggu Ini',
    ),
    NotificationItem(
      id: 'INV/083/329383',
      title: 'Ket. Pembayaran SPP Santri Ahmad Fauzi',
      amount: 'Rp. 1.800.000',
      type: NotificationType.transaksi,
      status: NotificationStatus.unread,
      date: DateTime.now().subtract(const Duration(days: 1)),
      section: 'Minggu Ini',
    ),
    NotificationItem(
      id: 'INV/083/329384',
      title: 'Ket. Pembayaran Uang Makan Santri Budi',
      amount: 'Rp. 500.000',
      type: NotificationType.transaksi,
      status: NotificationStatus.approved,
      date: DateTime.now().subtract(const Duration(days: 4)),
      section: 'Minggu Ini',
    ),
    NotificationItem(
      id: 'PER/083/001',
      title: 'Permohonan Izin Keluar Santri Ahmad Fauzi',
      amount: '',
      type: NotificationType.perijinan,
      status: NotificationStatus.unread,
      date: DateTime.now().subtract(const Duration(hours: 5)),
      section: 'Minggu Ini',
    ),
    NotificationItem(
      id: 'ANN/083/001',
      title: 'Pengumuman Libur Hari Raya Idul Fitri',
      amount: '',
      type: NotificationType.pengumuman,
      status: NotificationStatus.read,
      date: DateTime.now().subtract(const Duration(days: 3)),
      section: 'Minggu Ini',
    ),
    // Bulan Lalu - mostly read
    NotificationItem(
      id: 'INV/082/329380',
      title: 'Ket. Pembayaran Seragam XL Santri Naufal Ramadhan',
      amount: 'Rp. 2.500.000',
      type: NotificationType.transaksi,
      status: NotificationStatus.approved,
      date: DateTime.now().subtract(const Duration(days: 35)),
      section: 'Bulan Lalu',
    ),
  ];

  List<NotificationItem> get notifications => _notifications;

  int get unreadCount {
    return _notifications.where((notification) => 
      notification.status == NotificationStatus.unread).length;
  }

  bool get hasUnreadNotifications => unreadCount > 0;

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && _notifications[index].status == NotificationStatus.unread) {
      _notifications[index] = NotificationItem(
        id: _notifications[index].id,
        title: _notifications[index].title,
        amount: _notifications[index].amount,
        type: _notifications[index].type,
        status: NotificationStatus.read,
        date: _notifications[index].date,
        section: _notifications[index].section,
      );
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].status == NotificationStatus.unread) {
        _notifications[i] = NotificationItem(
          id: _notifications[i].id,
          title: _notifications[i].title,
          amount: _notifications[i].amount,
          type: _notifications[i].type,
          status: NotificationStatus.read,
          date: _notifications[i].date,
          section: _notifications[i].section,
        );
      }
    }
    notifyListeners();
  }

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  List<NotificationItem> getFilteredNotifications(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }
}

