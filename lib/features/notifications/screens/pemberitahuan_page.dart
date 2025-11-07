import 'package:alhamra_1/core/services/notification_service.dart';
import 'package:alhamra_1/features/notifications/screens/detail_pemberitahuan_page.dart';
import 'package:alhamra_1/features/shared/widgets/status_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_styles.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/localization/app_localizations.dart';

class PemberitahuanPage extends StatefulWidget {
  const PemberitahuanPage({super.key});
  @override
  State<PemberitahuanPage> createState() => _PemberitahuanPageState();
}

class _PemberitahuanPageState extends State<PemberitahuanPage> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Transaksi', 'Perijinan', 'Pengumuman'];
  final NotificationService _notificationService = NotificationService();
  
  // Filter state variables
  String _selectedSortOrder = 'Terbaru';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // No longer mark all as read when page is opened
    // Notifications will be marked as read individually when detail page is opened
  }

  // Get notifications from service instead of local data
  List<NotificationItem> get _allNotifications => _notificationService.notifications;

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _getFilteredNotifications();
    final groupedNotifications = _groupNotificationsBySection(filteredNotifications);

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF2196F3),
        appBar: StatusAppBar(
          title: 'Pemberitahuan',
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                // TODO: Implement search functionality
              },
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            _buildFilterTabs(),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                        itemCount: _calculateTotalItems(groupedNotifications),
                        itemBuilder: (context, index) {
                          return _buildListItem(groupedNotifications, index);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filters.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(right: index < _filters.length - 1 ? 8 : 0),
                    child: _buildFilterChip(_filters[index], index),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(width: 12),
          GestureDetector(
            onTap: _showFilterDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context).filter,
                    style: GoogleFonts.poppins(
                      color: AppStyles.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.tune,
                    color: AppStyles.primaryColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? AppStyles.primaryColor : Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPemberitahuanPage(notification: notification),
          ),
        ).then((_) {
          // Refresh the page when returning from detail page to update read status
          setState(() {});
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    notification.id,
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (notification.status == NotificationStatus.unread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              notification.title,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: notification.status == NotificationStatus.unread 
                    ? FontWeight.w700 
                    : FontWeight.w600,
              ),
            ),
            if (notification.amount.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                notification.amount,
                style: GoogleFonts.poppins(
                  color: AppStyles.primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(notification.date),
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                _buildStatusButton(notification),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(NotificationItem notification) {
    switch (notification.status) {
      case NotificationStatus.approved:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Approved',
            style: GoogleFonts.poppins(
              color: const Color(0xFF4CAF50),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case NotificationStatus.pending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Waiting',
            style: GoogleFonts.poppins(
              color: const Color(0xFFFF9800),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case NotificationStatus.rejected:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Rejected',
            style: GoogleFonts.poppins(
              color: const Color(0xFFF44336),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case NotificationStatus.read:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Read',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case NotificationStatus.unread:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'New',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1976D2),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.grey.shade600,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifications will appear here',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  List<NotificationItem> _getFilteredNotifications() {
    List<NotificationItem> filtered = [];
    
    // Filter by type
    if (_selectedFilterIndex == 0) {
      filtered = _allNotifications.where((n) => n.type == NotificationType.transaksi).toList();
    } else if (_selectedFilterIndex == 1) {
      filtered = _allNotifications.where((n) => n.type == NotificationType.perijinan).toList();
    } else {
      filtered = _allNotifications.where((n) => n.type == NotificationType.pengumuman).toList();
    }
    
    // Filter by date range
    if (_startDate != null || _endDate != null) {
      filtered = filtered.where((notification) {
        final notificationDate = notification.date;
        
        if (_startDate != null && _endDate != null) {
          return notificationDate.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
                 notificationDate.isBefore(_endDate!.add(const Duration(days: 1)));
        } else if (_startDate != null) {
          return notificationDate.isAfter(_startDate!.subtract(const Duration(days: 1)));
        } else if (_endDate != null) {
          return notificationDate.isBefore(_endDate!.add(const Duration(days: 1)));
        }
        
        return true;
      }).toList();
    }
    
    // Sort by date
    if (_selectedSortOrder == 'Terbaru') {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    } else {
      filtered.sort((a, b) => a.date.compareTo(b.date));
    }
    
    return filtered;
  }

  Map<String, List<NotificationItem>> _groupNotificationsBySection(List<NotificationItem> notifications) {
    final Map<String, List<NotificationItem>> grouped = {};
    for (final notification in notifications) {
      if (!grouped.containsKey(notification.section)) {
        grouped[notification.section] = [];
      }
      grouped[notification.section]!.add(notification);
    }
    return grouped;
  }

  int _calculateTotalItems(Map<String, List<NotificationItem>> groupedNotifications) {
    int total = 0;
    for (final entry in groupedNotifications.entries) {
      total += 1; // Section header
      total += entry.value.length; // Notification items
    }
    return total;
  }

  Widget _buildListItem(Map<String, List<NotificationItem>> groupedNotifications, int index) {
    int currentIndex = 0;
    
    for (final entry in groupedNotifications.entries) {
      if (currentIndex == index) {
        return _buildSectionHeader(entry.key);
      }
      currentIndex++;
      
      for (int i = 0; i < entry.value.length; i++) {
        if (currentIndex == index) {
          return _buildNotificationCard(entry.value[i]);
        }
        currentIndex++;
      }
    }
    
    return const SizedBox.shrink();
  }

  void _showFilterDialog() {
    String tempSortOrder = _selectedSortOrder;
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Notifications',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Sort Order Section
                  Text(
                    'Sort by Time',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSortButton(
                          'Terbaru',
                          tempSortOrder == 'Terbaru',
                          () {
                            setModalState(() {
                              tempSortOrder = 'Terbaru';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSortButton(
                          'Terlama',
                          tempSortOrder == 'Terlama',
                          () {
                            setModalState(() {
                              tempSortOrder = 'Terlama';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Date Range Section
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDatePicker(
                              tempStartDate,
                              'Pilih Tanggal Awal',
                              (date) {
                                setModalState(() {
                                  tempStartDate = date;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'To',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDatePicker(
                              tempEndDate,
                              'Pilih Tanggal Akhir',
                              (date) {
                                setModalState(() {
                                  tempEndDate = date;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedSortOrder = 'Terbaru';
                              _startDate = null;
                              _endDate = null;
                            });
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppStyles.primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Reset',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppStyles.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedSortOrder = tempSortOrder;
                              _startDate = tempStartDate;
                              _endDate = tempEndDate;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Apply',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppStyles.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppStyles.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(DateTime? selectedDate, String placeholder, Function(DateTime?) onDateSelected) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppStyles.primaryColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedDate != null
                    ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                    : placeholder,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selectedDate != null ? Colors.black87 : Colors.grey.shade500,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Kemarin';
    } else if (difference < 7) {
      return '$difference hari yang lalu';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }
}

