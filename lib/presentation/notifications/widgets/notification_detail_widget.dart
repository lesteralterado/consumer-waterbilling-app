import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationDetailWidget extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onClose;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;

  const NotificationDetailWidget({
    Key? key,
    required this.notification,
    this.onClose,
    this.onMarkAsRead,
    this.onDelete,
    this.onArchive,
  }) : super(key: key);

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'billing':
        return AppTheme.lightTheme.primaryColor;
      case 'service':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'maintenance':
        return const Color(0xFFFFC107);
      case 'emergency':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _formatFullTimestamp(DateTime timestamp) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year} at ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final String category = notification['category'] as String? ?? 'general';
    final String sender = notification['sender'] as String? ?? 'AquaPay';
    final String subject = notification['subject'] as String? ?? '';
    final String content = notification['content'] as String? ?? '';
    final DateTime timestamp =
        notification['timestamp'] as DateTime? ?? DateTime.now();
    final List<String> attachments =
        (notification['attachments'] as List?)?.cast<String>() ?? [];
    final List<Map<String, dynamic>> actions =
        (notification['actions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final bool isRead = notification['isRead'] as bool? ?? false;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                // Close button
                IconButton(
                  onPressed: onClose,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    size: 6.w,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: 2.w),
                // Category indicator
                Container(
                  width: 4.w,
                  height: 4.w,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 3.w),
                // Title
                Expanded(
                  child: Text(
                    'Notification Details',
                    style: AppTheme.lightTheme.textTheme.titleLarge,
                  ),
                ),
                // Actions menu
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'mark_read':
                        onMarkAsRead?.call();
                        break;
                      case 'archive':
                        onArchive?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: isRead
                                ? 'mark_email_unread'
                                : 'mark_email_read',
                            size: 5.w,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                          SizedBox(width: 3.w),
                          Text(isRead ? 'Mark as Unread' : 'Mark as Read'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'archive',
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'archive',
                            size: 5.w,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                          SizedBox(width: 3.w),
                          Text('Archive'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'delete',
                            size: 5.w,
                            color: AppTheme.lightTheme.colorScheme.error,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: AppTheme.lightTheme.colorScheme.error,
                            ),
                          ),
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
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sender and timestamp
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'From: $sender',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _formatFullTimestamp(timestamp),
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Category badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: _getCategoryColor(category),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  // Subject
                  Text(
                    subject,
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Content
                  Text(
                    content,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
                  ),
                  // Attachments
                  if (attachments.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(
                      'Attachments',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    ...attachments.map((attachment) => Container(
                          margin: EdgeInsets.only(bottom: 1.h),
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'attach_file',
                                size: 5.w,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  attachment,
                                  style:
                                      AppTheme.lightTheme.textTheme.bodyMedium,
                                ),
                              ),
                              CustomIconWidget(
                                iconName: 'download',
                                size: 5.w,
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        )),
                  ],
                  // Action buttons
                  if (actions.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    ...actions.map((action) => Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 2.h),
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: action['primary'] == true
                                  ? AppTheme.lightTheme.primaryColor
                                  : AppTheme.lightTheme.colorScheme.surface,
                              foregroundColor: action['primary'] == true
                                  ? Colors.white
                                  : AppTheme.lightTheme.primaryColor,
                              side: action['primary'] == true
                                  ? null
                                  : BorderSide(
                                      color: AppTheme.lightTheme.primaryColor),
                            ),
                            child: Text(action['label'] as String? ?? ''),
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
