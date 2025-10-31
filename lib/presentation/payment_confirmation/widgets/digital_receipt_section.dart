import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DigitalReceiptSection extends StatefulWidget {
  final Map<String, dynamic> receiptData;

  const DigitalReceiptSection({
    Key? key,
    required this.receiptData,
  }) : super(key: key);

  @override
  State<DigitalReceiptSection> createState() => _DigitalReceiptSectionState();
}

class _DigitalReceiptSectionState extends State<DigitalReceiptSection> {
  bool _isGeneratingReceipt = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'receipt',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Digital Receipt',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Get your payment receipt instantly',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildReceiptButton(
                  icon: 'download',
                  label: 'Download PDF',
                  onTap: _downloadReceipt,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildReceiptButton(
                  icon: 'email',
                  label: 'Email Receipt',
                  onTap: _emailReceipt,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildShareButton(),
        ],
      ),
    );
  }

  Widget _buildReceiptButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isGeneratingReceipt ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
        decoration: BoxDecoration(
          color: _isGeneratingReceipt
              ? AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isGeneratingReceipt
                ? AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3)
                : AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            _isGeneratingReceipt
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  )
                : CustomIconWidget(
                    iconName: icon,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: _isGeneratingReceipt
                    ? AppTheme.textSecondaryLight
                    : AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return GestureDetector(
      onTap: _shareReceipt,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'share',
              color: AppTheme.textSecondaryLight,
              size: 18,
            ),
            SizedBox(width: 2.w),
            Text(
              'Share Receipt',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadReceipt() async {
    setState(() {
      _isGeneratingReceipt = true;
    });

    try {
      // Simulate PDF generation
      await Future.delayed(const Duration(seconds: 2));

      HapticFeedback.lightImpact();
      Fluttertoast.showToast(
        msg: "Receipt downloaded successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.successLight,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to download receipt. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.errorLight,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingReceipt = false;
        });
      }
    }
  }

  Future<void> _emailReceipt() async {
    setState(() {
      _isGeneratingReceipt = true;
    });

    try {
      // Simulate email sending
      await Future.delayed(const Duration(seconds: 2));

      HapticFeedback.lightImpact();
      Fluttertoast.showToast(
        msg: "Receipt sent to your email",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.successLight,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to send email. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.errorLight,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingReceipt = false;
        });
      }
    }
  }

  void _shareReceipt() {
    HapticFeedback.selectionClick();

    // Show share options
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Share Receipt',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            _buildShareOption('SMS', 'sms', () => _shareViaSMS()),
            _buildShareOption('Email', 'email', () => _shareViaEmail()),
            _buildShareOption(
                'Messaging Apps', 'message', () => _shareViaMessaging()),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(String title, String icon, VoidCallback onTap) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: AppTheme.lightTheme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _shareViaSMS() {
    Fluttertoast.showToast(
      msg: "Opening SMS app...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _shareViaEmail() {
    Fluttertoast.showToast(
      msg: "Opening email app...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _shareViaMessaging() {
    Fluttertoast.showToast(
      msg: "Opening messaging apps...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
