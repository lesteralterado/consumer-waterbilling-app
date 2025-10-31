import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/account_status_card.dart';
import './widgets/dashboard_tab_bar.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/recent_activity_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isRefreshing = false;
  DateTime _lastUpdated = DateTime.now();

  // Mock data for dashboard
  final Map<String, dynamic> _accountData = {
    "customerName": "Maria Santos",
    "accountNumber": "AQ-2024-001234",
    "status": "Current",
    "currentBill": 1250.75,
    "dueDate": DateTime.now().add(const Duration(days: 15)),
    "meterReading": "1,247",
    "lastUpdated": DateTime.now(),
  };

  final List<Map<String, dynamic>> _recentActivities = [
    {
      "id": 1,
      "type": "payment",
      "title": "Bill Payment Successful",
      "description": "Payment via GCash for October 2024 bill",
      "amount": 1180.50,
      "date": DateTime.now().subtract(const Duration(days: 2)),
      "status": "completed"
    },
    {
      "id": 2,
      "type": "notification",
      "title": "New Bill Generated",
      "description": "Your November 2024 water bill is now available",
      "date": DateTime.now().subtract(const Duration(days: 5)),
      "status": "unread"
    },
    {
      "id": 3,
      "type": "meter_reading",
      "title": "Meter Reading Updated",
      "description": "Monthly meter reading recorded: 1,247 m³",
      "date": DateTime.now().subtract(const Duration(days: 7)),
      "status": "completed"
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _refreshData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
      _lastUpdated = DateTime.now();
    });
  }

  void _onTabChanged(int index) {
    switch (index) {
      case 0:
        // Dashboard - already here
        break;
      case 1:
        Navigator.pushNamed(context, '/bill-details');
        break;
      case 2:
        Navigator.pushNamed(context, '/payment-history');
        break;
      case 3:
        Navigator.pushNamed(context, '/issue-reporting');
        break;
      case 4:
        // Profile tab - would navigate to profile screen
        break;
    }
  }

  void _onPayBill() {
    Navigator.pushNamed(context, '/payment-methods');
  }

  void _onViewMeter() {
    Navigator.pushNamed(context, '/bill-details');
  }

  void _onReportIssue() {
    Navigator.pushNamed(context, '/issue-reporting');
  }

  void _onActivityTap(Map<String, dynamic> activity) {
    switch (activity['type']) {
      case 'payment':
        Navigator.pushNamed(context, '/payment-history');
        break;
      case 'notification':
        Navigator.pushNamed(context, '/notifications');
        break;
      case 'meter_reading':
        Navigator.pushNamed(context, '/bill-details');
        break;
      default:
        break;
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: DashboardTabBar(
        tabController: _tabController,
        onTabChanged: _onTabChanged,
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildDashboardContent(),
          Container(), // Bills placeholder
          Container(), // Payments placeholder
          Container(), // Issues placeholder
          Container(), // Profile placeholder
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onPayBill,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        icon: CustomIconWidget(
          iconName: 'payment',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 5.w,
        ),
        label: Text(
          'Pay Now',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Last updated: ${_formatLastUpdated()}',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (_isRefreshing)
                        SizedBox(
                          width: 4.w,
                          height: 4.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Account Status Card
            AccountStatusCard(
              customerName: _accountData['customerName'] as String,
              accountNumber: _accountData['accountNumber'] as String,
              status: _accountData['status'] as String,
              currentBill: _accountData['currentBill'] as double,
              dueDate: _accountData['dueDate'] as DateTime,
              meterReading: _accountData['meterReading'] as String,
            ),

            SizedBox(height: 2.h),

            // Quick Actions
            QuickActionsWidget(
              onPayBill: _onPayBill,
              onViewMeter: _onViewMeter,
              onReportIssue: _onReportIssue,
            ),

            SizedBox(height: 2.h),

            // Recent Activity
            RecentActivityWidget(
              activities: _recentActivities,
              onActivityTap: _onActivityTap,
            ),

            // Bottom padding for FAB
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  String _formatLastUpdated() {
    final now = DateTime.now();
    final difference = now.difference(_lastUpdated);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${_lastUpdated.day}/${_lastUpdated.month}/${_lastUpdated.year}';
    }
  }
}
