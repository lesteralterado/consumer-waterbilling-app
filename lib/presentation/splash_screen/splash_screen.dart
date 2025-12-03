import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isLoading = true;
  String _loadingText = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _performInitialization();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _performInitialization() async {
    try {
      // Simulate checking authentication status
      await _updateLoadingText('Checking authentication...');
      await Future.delayed(const Duration(milliseconds: 800));

      // Simulate loading user preferences
      await _updateLoadingText('Loading preferences...');
      await Future.delayed(const Duration(milliseconds: 600));

      // Simulate fetching billing configuration
      await _updateLoadingText('Fetching billing config...');
      await Future.delayed(const Duration(milliseconds: 700));

      // Simulate preparing cached data
      await _updateLoadingText('Preparing data...');
      await Future.delayed(const Duration(milliseconds: 500));

      // Complete initialization
      setState(() {
        _isLoading = false;
        _loadingText = 'Ready!';
      });

      // Wait for animation to complete before navigation
      await Future.delayed(const Duration(milliseconds: 800));

      // Navigate based on authentication status
      _navigateToNextScreen();
    } catch (e) {
      // Handle initialization errors
      _handleInitializationError();
    }
  }

  Future<void> _updateLoadingText(String text) async {
    if (mounted) {
      setState(() {
        _loadingText = text;
      });
    }
  }

  void _navigateToNextScreen() {
    // Mock authentication check - in real app, check actual auth status
    final bool isAuthenticated = _checkAuthenticationStatus();

    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login-screen');
    }
  }

  bool _checkAuthenticationStatus() {
    // Mock authentication logic - replace with actual implementation
    // For demo purposes, randomly return false to show login screen
    return false;
  }

  void _handleInitializationError() {
    setState(() {
      _isLoading = false;
      _loadingText = 'Connection failed';
    });

    // Show retry option after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _showRetryDialog();
      }
    });
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Text(
            'Connection Error',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Unable to connect to Anopog services. Please check your internet connection and try again.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performInitialization();
              },
              child: Text(
                'Retry',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.lightTheme.colorScheme.primary,
                AppTheme.lightTheme.colorScheme.primaryContainer,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // App Logo with Pulse Animation
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.95, end: 1.05),
                                duration: const Duration(milliseconds: 1500),
                                curve: Curves.easeInOut,
                                builder: (context, scale, child) {
                                  return Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      width: 45.w,
                                      height: 45.w,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.15),
                                            blurRadius: 30.0,
                                            spreadRadius: 5.0,
                                            offset: const Offset(0, 10),
                                          ),
                                          BoxShadow(
                                            color: AppTheme
                                                .lightTheme.colorScheme.primary
                                                .withValues(alpha: 0.3),
                                            blurRadius: 40.0,
                                            spreadRadius: -5.0,
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(4.w),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/anopog_logo.png',
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            // Fallback to icon if image fails to load
                                            return Center(
                                              child: Icon(
                                                Icons.water_drop_rounded,
                                                size: 30.w,
                                                color: AppTheme.lightTheme
                                                    .colorScheme.primary,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                onEnd: () {
                                  // Create infinite pulse effect
                                  if (mounted && _isLoading) {
                                    setState(() {});
                                  }
                                },
                              ),
                              SizedBox(height: 4.h),
                              // App Name with Shimmer Effect
                              ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.8),
                                      Colors.white,
                                      Colors.white.withValues(alpha: 0.8),
                                    ],
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  'ANOPOG',
                                  style: AppTheme
                                      .lightTheme.textTheme.headlineLarge
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 32.sp,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              // Tagline
                              Text(
                                'Water Utility Made Simple',
                                style: AppTheme.lightTheme.textTheme.bodyLarge
                                    ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14.sp,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Loading Section
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Loading Indicator
                    _isLoading
                        ? SizedBox(
                            width: 8.w,
                            height: 8.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.lightTheme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            size: 8.w,
                          ),
                    SizedBox(height: 2.h),

                    // Loading Text
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _loadingText,
                        key: ValueKey(_loadingText),
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onPrimary
                              .withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Footer Section
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Column(
                  children: [
                    Text(
                      'Powered by ANOPOG Solutions',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Version 1.0.0',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
