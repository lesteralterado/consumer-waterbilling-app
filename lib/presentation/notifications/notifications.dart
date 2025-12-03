import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../services/notification_api_service.dart';
import './widgets/notification_card_widget.dart';
import './widgets/notification_detail_widget.dart';
import './widgets/notification_empty_state_widget.dart';
import './widgets/notification_filter_widget.dart';
import './widgets/notification_search_widget.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'all';
  String _searchQuery = '';
  bool _isSelectionMode = false;
  Set<int> _selectedNotifications = {};

  // API state
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  String? _userId;

  final List<String> _categories = [
    'all',
    'billing',
    'service',
    'maintenance',
    'emergency'
  ];

  // Notifications data from API
  List<Map<String, dynamic>> _allNotifications = [
    {
      "id": 1,
      "sender": "Anopog Billing",
      "subject": "Monthly Water Bill - October 2024",
      "preview":
          "Your water bill for October 2024 is now available. Amount due: ₱1,245.50",
      "content":
          """Dear Valued Customer, Your monthly water bill for October 2024 is now ready for viewing and payment. Billing Period: October 1-31, 2024 Previous Reading: 1,234 cubic meters Current Reading: 1,267 cubic meters Consumption: 33 cubic meters Amount Due: ₱1,245.50 Due Date: November 15, 2024 You can pay your bill through the following methods: • GCash payment within the app • Online banking • Over-the-counter payments at authorized centers Thank you for choosing Anopog for your water utility needs.""",
      "category": "billing",
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "isRead": false,
      "attachments": ["October_2024_Bill.pdf"],
      "actions": [
        {"label": "View Bill", "action": "view_bill", "primary": true},
        {"label": "Pay Now", "action": "pay_now", "primary": false},
      ],
    },
    {
      "id": 2,
      "sender": "Anopog Service",
      "subject": "Scheduled Maintenance Notice",
      "preview":
          "Water service interruption scheduled for November 5, 2024 from 8:00 AM to 2:00 PM",
      "content":
          """Important Service Notice We will be conducting scheduled maintenance on our water distribution system in your area. Date: November 5, 2024 Time: 8:00 AM - 2:00 PM Affected Areas: Barangay San Miguel, Zone 1-5 During this period, you may experience: • Complete water service interruption • Low water pressure • Discolored water initially when service resumes We recommend storing water in advance for your needs during the maintenance period. Service will be restored as soon as maintenance is completed. We apologize for any inconvenience this may cause.""",
      "category": "maintenance",
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
      "isRead": true,
      "attachments": [],
      "actions": [],
    },
    {
      "id": 3,
      "sender": "Anopog Emergency",
      "subject": "Water Quality Advisory",
      "preview":
          "Temporary water quality advisory issued for your area. Boil water before consumption.",
      "content":
          """URGENT: Water Quality Advisory Due to recent heavy rainfall and flooding in the watershed area, we are issuing a precautionary boil water advisory for the following areas: Affected Areas: • Barangay San Miguel • Barangay Santa Cruz • Barangay San Juan Effective immediately until further notice, please: • Boil water for at least 1 minute before drinking • Use boiled or bottled water for cooking • Use boiled water for brushing teeth • Normal use for bathing and washing is safe We are conducting additional water quality testing and will notify you when the advisory is lifted. For questions, contact our emergency hotline: 1-800-Anopog""",
      "category": "emergency",
      "timestamp": DateTime.now().subtract(const Duration(days: 2)),
      "isRead": false,
      "attachments": ["Water_Quality_Report.pdf"],
      "actions": [
        {"label": "View Report", "action": "view_report", "primary": true},
        {
          "label": "Emergency Contact",
          "action": "emergency_contact",
          "primary": false
        },
      ],
    },
    {
      "id": 4,
      "sender": "Anopog Customer Service",
      "subject": "Payment Confirmation - October 2024",
      "preview":
          "Your payment of ₱1,180.25 has been successfully processed via GCash.",
      "content":
          """Payment Confirmation Thank you for your payment! Your transaction has been successfully processed. Transaction Details: Payment Amount: ₱1,180.25 Payment Method: GCash Transaction ID: GC-2024-10-28-001234 Date: October 28, 2024, 3:45 PM Reference Number: AP-PAY-789456123 Your account is now up to date. Your next bill will be available on November 1, 2024. Keep this confirmation for your records. If you have any questions about this payment, please contact our customer service team. Thank you for using Anopog!""",
      "category": "billing",
      "timestamp": DateTime.now().subtract(const Duration(days: 3)),
      "isRead": true,
      "attachments": ["Payment_Receipt_Oct2024.pdf"],
      "actions": [],
    },
    {
      "id": 5,
      "sender": "Anopog Service",
      "subject": "New Feature: Auto-Pay Setup",
      "preview":
          "Set up automatic payments for your water bills and never miss a due date again.",
      "content":
          """Introducing Auto-Pay for Water Bills Make your life easier with our new Auto-Pay feature! Set up automatic payments and never worry about missing a due date again. Benefits of Auto-Pay: • Never miss a payment deadline • Automatic deduction from your preferred payment method • Email notifications before each payment • Cancel or modify anytime • Secure and reliable Supported Payment Methods: • GCash • Bank accounts • Credit/Debit cards To set up Auto-Pay: 1. Go to Payment Methods in your app 2. Select "Set up Auto-Pay" 3. Choose your preferred payment method 4. Confirm your setup Start enjoying hassle-free bill payments today!""",
      "category": "service",
      "timestamp": DateTime.now().subtract(const Duration(days: 5)),
      "isRead": false,
      "attachments": [],
      "actions": [
        {
          "label": "Set up Auto-Pay",
          "action": "setup_autopay",
          "primary": true
        },
      ],
    },
    {
      "id": 6,
      "sender": "Anopog System",
      "subject": "Account Security Update",
      "preview":
          "Your account security settings have been updated successfully.",
      "content":
          """Account Security Update Your account security settings have been successfully updated. Changes Made: • Password updated • Two-factor authentication enabled • Login notifications activated These changes were made on October 25, 2024 at 2:30 PM from your registered device. If you did not make these changes, please contact our security team immediately at security@Anopog.ph or call our emergency hotline. Your account security is our priority. Thank you for keeping your account safe.""",
      "category": "service",
      "timestamp": DateTime.now().subtract(const Duration(days: 7)),
      "isRead": true,
      "attachments": [],
      "actions": [],
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    List<Map<String, dynamic>> filtered = _allNotifications;

    // Apply category filter
    if (_selectedFilter != 'all') {
      filtered = filtered
          .where((notification) => notification['category'] == _selectedFilter)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((notification) {
        final subject =
            (notification['subject'] as String? ?? '').toLowerCase();
        final content =
            (notification['content'] as String? ?? '').toLowerCase();
        final sender = (notification['sender'] as String? ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();

        return subject.contains(query) ||
            content.contains(query) ||
            sender.contains(query);
      }).toList();
    }

    return filtered;
  }

  int get _unreadCount {
    return _allNotifications
        .where((notification) => !(notification['isRead'] as bool? ?? true))
        .length;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserDataAndNotifications();
  }

  Future<void> _loadUserDataAndNotifications() async {
    try {
      // Get user data from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        final userData = json.decode(userDataString);
        _userId = userData['id'].toString();

        // Fetch notifications from API
        await _fetchNotifications();
      } else {
        setState(() {
          _errorMessage = 'User not logged in';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchNotifications() async {
    if (_userId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await NotificationApiService.fetchUserNotifications(
        userId: _userId!,
      );

      if (result['success']) {
        final notifications = result['notifications'] as List<dynamic>;
        setState(() {
          _allNotifications = notifications.map((notification) {
            // Transform backend notification format to match UI expectations
            return {
              'id': notification['id'] ?? 0,
              'sender': notification['sender'] ?? 'Anopog',
              'subject': notification['subject'] ?? 'Notification',
              'preview':
                  notification['preview'] ?? notification['content'] ?? '',
              'content': notification['content'] ?? '',
              'category': notification['category'] ?? 'service',
              'timestamp': notification['timestamp'] != null
                  ? DateTime.parse(notification['timestamp'])
                  : DateTime.now(),
              'isRead': notification['isRead'] ?? false,
              'attachments': notification['attachments'] ?? [],
              'actions': notification['actions'] ?? [],
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to fetch notifications';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _markAsRead(int notificationId) {
    setState(() {
      final index =
          _allNotifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _allNotifications[index]['isRead'] = true;
      }
    });
  }

  void _markAsUnread(int notificationId) {
    setState(() {
      final index =
          _allNotifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _allNotifications[index]['isRead'] = false;
      }
    });
  }

  void _deleteNotification(int notificationId) {
    setState(() {
      _allNotifications.removeWhere((n) => n['id'] == notificationId);
    });
  }

  void _archiveNotification(int notificationId) {
    // In a real app, this would move to archived notifications
    setState(() {
      final index =
          _allNotifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _allNotifications[index]['archived'] = true;
      }
    });
  }

  void _showNotificationDetail(Map<String, dynamic> notification) {
    // Mark as read when opened
    if (!(notification['isRead'] as bool? ?? true)) {
      _markAsRead(notification['id'] as int);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 90.h,
        child: NotificationDetailWidget(
          notification: notification,
          onClose: () => Navigator.pop(context),
          onMarkAsRead: () {
            final isRead = notification['isRead'] as bool? ?? false;
            if (isRead) {
              _markAsUnread(notification['id'] as int);
            } else {
              _markAsRead(notification['id'] as int);
            }
            Navigator.pop(context);
          },
          onDelete: () {
            _deleteNotification(notification['id'] as int);
            Navigator.pop(context);
          },
          onArchive: () {
            _archiveNotification(notification['id'] as int);
            Navigator.pop(context);
          },
        ),
      ),
    );
    ;
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedNotifications.clear();
      }
    });
  }

  void _toggleNotificationSelection(int notificationId) {
    setState(() {
      if (_selectedNotifications.contains(notificationId)) {
        _selectedNotifications.remove(notificationId);
      } else {
        _selectedNotifications.add(notificationId);
      }
    });
  }

  void _markSelectedAsRead() {
    setState(() {
      for (final id in _selectedNotifications) {
        final index = _allNotifications.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          _allNotifications[index]['isRead'] = true;
        }
      }
      _selectedNotifications.clear();
      _isSelectionMode = false;
    });
  }

  void _deleteSelected() {
    setState(() {
      _allNotifications
          .removeWhere((n) => _selectedNotifications.contains(n['id']));
      _selectedNotifications.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await _fetchNotifications();
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _filteredNotifications;

    // Show loading state
    if (_isLoading && !_isRefreshing) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              size: 6.w,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.lightTheme.primaryColor,
              ),
              SizedBox(height: 3.h),
              Text(
                'Loading notifications...',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    // Show error state
    if (_errorMessage != null && !_isRefreshing) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              size: 6.w,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ),
        body: NotificationEmptyStateWidget(
          message: _errorMessage!,
          actionText: 'Retry',
          onActionPressed: _loadUserDataAndNotifications,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            size: 6.w,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              onPressed: _selectedNotifications.isNotEmpty
                  ? _markSelectedAsRead
                  : null,
              icon: CustomIconWidget(
                iconName: 'mark_email_read',
                size: 6.w,
                color: _selectedNotifications.isNotEmpty
                    ? AppTheme.lightTheme.colorScheme.onSurface
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            IconButton(
              onPressed:
                  _selectedNotifications.isNotEmpty ? _deleteSelected : null,
              icon: CustomIconWidget(
                iconName: 'delete',
                size: 6.w,
                color: _selectedNotifications.isNotEmpty
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            IconButton(
              onPressed: _toggleSelectionMode,
              icon: CustomIconWidget(
                iconName: 'close',
                size: 6.w,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ] else ...[
            IconButton(
              onPressed: _toggleSelectionMode,
              icon: CustomIconWidget(
                iconName: 'checklist',
                size: 6.w,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'mark_all_read':
                    setState(() {
                      for (var notification in _allNotifications) {
                        notification['isRead'] = true;
                      }
                    });
                    break;
                  case 'settings':
                    // Navigate to notification settings
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'mark_email_read',
                        size: 5.w,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                      SizedBox(width: 3.w),
                      Text('Mark All as Read'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'settings',
                        size: 5.w,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                      SizedBox(width: 3.w),
                      Text('Notification Settings'),
                    ],
                  ),
                ),
              ],
              icon: CustomIconWidget(
                iconName: 'more_vert',
                size: 6.w,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('All'),
                  if (_unreadCount > 0) ...[
                    SizedBox(width: 2.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _unreadCount.toString(),
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(text: 'Unread'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          NotificationSearchWidget(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onClear: _clearSearch,
          ),
          // Filter chips
          NotificationFilterWidget(
            selectedFilter: _selectedFilter,
            onFilterChanged: _onFilterChanged,
            categories: _categories,
          ),
          // Notifications list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All notifications tab
                _buildNotificationsList(filteredNotifications),
                // Unread notifications tab
                _buildNotificationsList(
                  filteredNotifications
                      .where((n) => !(n['isRead'] as bool? ?? true))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<Map<String, dynamic>> notifications) {
    if (notifications.isEmpty) {
      return NotificationEmptyStateWidget(
        message: _searchQuery.isNotEmpty
            ? 'No notifications found'
            : _selectedFilter != 'all'
                ? 'No ${_selectedFilter} notifications'
                : 'No notifications yet',
        actionText: 'Refresh',
        onActionPressed: _refreshNotifications,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      color: AppTheme.lightTheme.primaryColor,
      child: _isRefreshing
          ? Center(
              child: Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: CircularProgressIndicator(
                  color: AppTheme.lightTheme.primaryColor,
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.only(bottom: 2.h),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final notificationId = notification['id'] as int;
                final isSelected =
                    _selectedNotifications.contains(notificationId);

                Widget notificationCard = NotificationCardWidget(
                  notification: notification,
                  onTap: _isSelectionMode
                      ? () => _toggleNotificationSelection(notificationId)
                      : () => _showNotificationDetail(notification),
                  onMarkAsRead: () => _markAsRead(notificationId),
                  onDelete: () => _deleteNotification(notificationId),
                  onArchive: () => _archiveNotification(notificationId),
                );

                if (_isSelectionMode) {
                  return Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) =>
                              _toggleNotificationSelection(notificationId),
                        ),
                        Expanded(child: notificationCard),
                      ],
                    ),
                  );
                }

                return GestureDetector(
                  onLongPress: () {
                    _toggleSelectionMode();
                    _toggleNotificationSelection(notificationId);
                  },
                  child: Slidable(
                    key: ValueKey(notificationId),
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            final isRead =
                                notification['isRead'] as bool? ?? false;
                            if (isRead) {
                              _markAsUnread(notificationId);
                            } else {
                              _markAsRead(notificationId);
                            }
                          },
                          backgroundColor: AppTheme.lightTheme.primaryColor,
                          foregroundColor: Colors.white,
                          icon: Icons.mark_email_read,
                          label: (notification['isRead'] as bool? ?? false)
                              ? 'Unread'
                              : 'Read',
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) =>
                              _archiveNotification(notificationId),
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.white,
                          icon: Icons.archive,
                          label: 'Archive',
                        ),
                        SlidableAction(
                          onPressed: (context) =>
                              _deleteNotification(notificationId),
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.error,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: notificationCard,
                  ),
                );
              }),
    );
  }
}
