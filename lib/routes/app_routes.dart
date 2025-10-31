import 'package:flutter/material.dart';
import '../presentation/notifications/notifications.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/bill_details/bill_details.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/payment_methods/payment_methods.dart';
import '../presentation/payment_confirmation/payment_confirmation.dart';
import '../presentation/issue_reporting/issue_reporting.dart';
import '../presentation/payment_history/payment_history.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String notifications = '/notifications';
  static const String splash = '/splash-screen';
  static const String billDetails = '/bill-details';
  static const String login = '/login-screen';
  static const String dashboard = '/dashboard';
  static const String paymentMethods = '/payment-methods';
  static const String paymentConfirmation = '/payment-confirmation';
  static const String issueReporting = '/issue-reporting';
  static const String paymentHistory = '/payment-history';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    notifications: (context) => const Notifications(),
    splash: (context) => const SplashScreen(),
    billDetails: (context) => const BillDetails(),
    login: (context) => const LoginScreen(),
    dashboard: (context) => const Dashboard(),
    paymentMethods: (context) => const PaymentMethods(),
    paymentConfirmation: (context) => const PaymentConfirmation(),
    issueReporting: (context) => const IssueReporting(),
    paymentHistory: (context) => const PaymentHistory(),
    // TODO: Add your other routes here
  };
}
