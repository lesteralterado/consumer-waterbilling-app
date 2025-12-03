import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DashboardTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final Function(int) onTabChanged;

  const DashboardTabBar({
    Key? key,
    required this.tabController,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
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
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 2.w,
                            height: 2.w,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: tabController,
              onTap: onTabChanged,
              isScrollable: false,
              labelColor: AppTheme.lightTheme.colorScheme.primary,
              unselectedLabelColor:
                  AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              indicatorColor: AppTheme.lightTheme.colorScheme.primary,
              indicatorWeight: 3,
              labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle:
                  AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: 'Dashboard'),
                Tab(text: 'Bills'),
                Tab(text: 'Payments'),
                Tab(text: 'Issues'),
                Tab(text: 'Profile'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(20.h);
}
