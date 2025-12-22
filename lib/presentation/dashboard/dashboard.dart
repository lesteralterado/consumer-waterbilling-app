import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../services/backend_api_service.dart';
import '../../services/payment_api_service.dart';
import './widgets/account_status_card.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/recent_activity_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isRefreshing = false;
  DateTime _lastUpdated = DateTime.now();

  // Animation controllers for tab effects
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  int _animatingIndex = -1; // Track which tab is being animated

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _latestMeterReading;
  Map<String, dynamic>? _latestBill;
  double _totalPayments = 0.0;
  bool _paymentSuccessful = false;
  Map<String, dynamic> _accountData = {
    "customerName": "Loading...",
    "accountNumber": "Loading...",
    "status": "Loading...",
    "currentBill": 0.0,
    "dueDate": DateTime.now().add(const Duration(days: 15)),
    "meterReading": "Loading...",
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

    // Initialize animation controller for tab tap effects
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _loadData();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      // ignore: avoid_print
      print('DEBUG: user_data from SharedPreferences => $userDataString');

      // Check if payment was successful recently
      final lastPaymentAmount = prefs.getDouble('last_payment_amount');
      final lastPaymentTimeString = prefs.getString('last_payment_time');
      DateTime? lastPaymentTime;
      if (lastPaymentTimeString != null) {
        lastPaymentTime = DateTime.tryParse(lastPaymentTimeString);
      }
      // If payment was recent (within last minute), consider it successful
      _paymentSuccessful = lastPaymentAmount != null &&
          lastPaymentTime != null &&
          DateTime.now().difference(lastPaymentTime).inMinutes < 1;
      // Reset the amount after checking
      if (_paymentSuccessful) {
        await prefs.remove('last_payment_amount');
        await prefs.remove('last_payment_time');
        // ignore: avoid_print
        print(
            'DEBUG: Recent payment detected: $lastPaymentAmount, will adjust currentBill');
      } else {
        // ignore: avoid_print
        print('DEBUG: No recent payment detected');
      }

      if (userDataString != null) {
        _userData = json.decode(userDataString);
        // ignore: avoid_print
        print('DEBUG: Parsed _userData => $_userData');

        final userId = int.parse(_userData!['id'].toString());
        // ignore: avoid_print
        print('DEBUG: Fetching data for userId => $userId');

        // Use BackendApiService which has working endpoints
        final meterResult =
            await BackendApiService.getLatestMeterReading(userId);
        // ignore: avoid_print
        print('DEBUG: Meter API raw response => $meterResult');
        if (meterResult['success'] != false) {
          _latestMeterReading = meterResult;
        }

        final billResult = await BackendApiService.getLatestAmountDue(userId);
        // ignore: avoid_print
        print('DEBUG: Bill API raw response => $billResult');
        // ignore: avoid_print
        print(
            'DEBUG: Bill amount_due fetched: ${billResult['amount_due']} at ${DateTime.now()}');
        if (billResult['success'] != false) {
          _latestBill = billResult;
          final billId = billResult['bill_id'];
          if (billId != null) {
            final paymentsResult =
                await PaymentApiService.getPaymentsByBillId(billId);
            // ignore: avoid_print
            print('DEBUG: Payments for bill $billId => $paymentsResult');
            if (paymentsResult['success'] == true) {
              final payments = paymentsResult['data'] as List<dynamic>? ?? [];
              _totalPayments = 0.0;
              for (var payment in payments) {
                final amount =
                    double.tryParse(payment['amount_paid'].toString()) ?? 0.0;
                _totalPayments += amount;
              }
              // ignore: avoid_print
              print('DEBUG: Total payments for bill $billId: $_totalPayments');
            }
          }
        }
      } else {
        // ignore: avoid_print
        print(
            'DEBUG: user_data is NULL in SharedPreferences - user may not be logged in');
      }
      _updateAccountData();
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: Error in _loadData => $e');
      _updateAccountData();
    }
  }

  void _updateAccountData() {
    if (_userData != null) {
      // Debug: log raw responses to help diagnose parsing issues
      // ignore: avoid_print
      print('DEBUG: _latestMeterReading => $_latestMeterReading');
      // ignore: avoid_print
      print('DEBUG: _latestBill => $_latestBill');

      // BackendApiService.getLatestMeterReading returns { success: true, reading: "value" }
      String meterReading = '0';
      if (_latestMeterReading != null &&
          _latestMeterReading!['reading'] != null) {
        meterReading = _latestMeterReading!['reading'].toString();
      }

      // BackendApiService.getLatestAmountDue returns { success: true, amount_due: 1234.56, bill_id: 1 }
      double currentBill = 0.0;
      if (_latestBill != null && _latestBill!['amount_due'] != null) {
        final amt = _latestBill!['amount_due'];
        if (amt is num) {
          currentBill = amt.toDouble();
        } else if (amt is String) {
          currentBill = double.tryParse(amt) ?? 0.0;
        }
        // Subtract total payments to get outstanding amount
        currentBill -= _totalPayments;
        // If payment was just successful, set to 0 (assuming full payment)
        if (_paymentSuccessful) {
          currentBill = 0.0;
          _paymentSuccessful = false; // Reset after use
          // ignore: avoid_print
          print('DEBUG: Recent payment detected, setting currentBill to 0.0');
        }
        // ignore: avoid_print
        print(
            'DEBUG: Calculated currentBill: $currentBill (amount_due: ${_latestBill!['amount_due']} - payments: $_totalPayments)');
      }

      DateTime dueDate = DateTime.now().add(const Duration(days: 15));
      // Note: BackendApiService doesn't return due_date, so using default or derive from system

      setState(() {
        _accountData = {
          "customerName": _userData!['full_name'] ?? 'Unknown',
          "accountNumber": _userData!['meter_number'] ?? 'N/A',
          "status": "Current",
          "currentBill": currentBill,
          "dueDate": dueDate,
          "meterReading": meterReading,
          "lastUpdated": DateTime.now(),
        };
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadData();

    setState(() {
      _isRefreshing = false;
      _lastUpdated = DateTime.now();
    });
  }

  void _onTabChanged(int index) async {
    // Trigger haptic feedback
    await HapticFeedback.lightImpact();

    // Trigger scale animation
    setState(() {
      _animatingIndex = index;
    });
    _scaleController.forward().then((_) {
      _scaleController.reverse().then((_) {
        setState(() {
          _animatingIndex = -1;
        });
      });
    });

    // Update current index after a brief delay for animation
    Future.delayed(const Duration(milliseconds: 75), () {
      setState(() {
        _currentIndex = index;
      });
    });

    switch (index) {
      case 0:
        // Dashboard - already here
        break;
      // case 1: // Bills tab commented out
      //   Navigator.pushNamed(context, '/bill-details');
      //   break;
      case 1: // Payments (was case 2)
        Navigator.pushNamed(context, '/payment-history');
        break;
      case 2: // Issues (was case 3)
        Navigator.pushNamed(context, '/issue-reporting');
        break;
      case 3: // Profile (was case 4)
        // Profile tab - show logout
        _showLogoutDialog();
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: _logout,
              child: Text(
                'Logout',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    // Close the dialog
    Navigator.of(context).pop();

    // Clear user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('saved_username');

    // Navigate back to login
    Navigator.of(context).pushReplacementNamed('/login-screen');
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      title: Row(
        children: [
          CustomImageWidget(
            imageUrl: "assets/images/logo.png",
            width: 10.w,
            height: 10.w,
            fit: BoxFit.cover,
            semanticLabel:
                "Anopog logo - stylized water drop with blue gradient background",
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Anopog',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
          icon: Stack(
            children: [
              CustomIconWidget(
                iconName: 'notifications',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
              // Note: unread count logic removed for simplicity, can be added back if needed
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    final List<Map<String, dynamic>> tabItems = [
      {'icon': Icons.home, 'label': 'Dashboard'},
      {'icon': Icons.payment, 'label': 'Payments'},
      {'icon': Icons.report_problem, 'label': 'Issues'},
      {'icon': Icons.person, 'label': 'Profile'},
    ];

    return Container(
      height: 10.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(tabItems.length, (index) {
          final item = tabItems[index];
          final isSelected = _currentIndex == index;
          final isAnimating = _animatingIndex == index;

          return Expanded(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isAnimating ? _scaleAnimation.value : 1.0,
                  child: child,
                );
              },
              child: InkWell(
                onTap: () => _onTabChanged(index),
                splashColor: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                highlightColor: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.05),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.1)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          size: 6.w,
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          fontSize: 2.5.w,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        child: Text(item['label'] as String),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildDashboardContent(),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
