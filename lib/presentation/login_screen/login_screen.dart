import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http; // Add this Line

import '../../core/app_export.dart';

class LoginScreen extends StatefulWidget {

  // IMPORTANT: Change this to your computer's IP address
  // Find it by running 'ipconfig' (Windows) or 'ifconfig' (Mac/Linux)
  final String apiUrl = 'http://172.26.208.1:3000/api/login'; 

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  String? _usernameError;
  String? _passwordError;

  late AnimationController _logoAnimationController;
  late AnimationController _formAnimationController;
  late Animation<double> _logoAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;

  // Mock credentials for demonstration
  final Map<String, String> _mockCredentials = {
    'admin@aquapay.ph': 'admin123',
    'customer@aquapay.ph': 'customer123',
    'user@aquapay.ph': 'user123',
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometricAvailability();
    _loadSavedCredentials();
  }

  void _initializeAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeIn,
    ));

    _logoAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _formAnimationController.forward();
    });
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      setState(() {
        _isBiometricAvailable =
            isAvailable && isDeviceSupported && availableBiometrics.isNotEmpty;
      });

      if (_isBiometricAvailable) {
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
        });
      }
    } catch (e) {
      setState(() {
        _isBiometricAvailable = false;
      });
    }
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUsername = prefs.getString('saved_username');
      if (savedUsername != null && savedUsername.isNotEmpty) {
        setState(() {
          _usernameController.text = savedUsername;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_username', _usernameController.text);
    } catch (e) {
      // Handle error silently
    }
  }

  void _validateUsername(String value) {
    setState(() {
      if (value.isEmpty) {
        _usernameError = 'Username or email is required';
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value) &&
          value.length < 3) {
        _usernameError = 'Enter a valid email or username';
      } else {
        _usernameError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (value.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
    });
  }

  bool get _isFormValid {
    return _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _usernameError == null &&
        _passwordError == null;
  }

  Future<void> _handleLogin() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1500));

      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      // Check mock credentials
      if (_mockCredentials.containsKey(username) &&
          _mockCredentials[username] == password) {
        // Save credentials for future use
        await _saveCredentials();

        // Success haptic feedback
        if (!kIsWeb) {
          HapticFeedback.lightImpact();
        }

        // Show success message
        Fluttertoast.showToast(
          msg: "Login successful! Welcome to AquaPay",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
          textColor: Colors.white,
        );

        // Navigate to dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // Show error for invalid credentials
        _showErrorMessage('Invalid username or password. Please try again.');
      }
    } catch (e) {
      _showErrorMessage(
          'Network error. Please check your connection and try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    if (!_isBiometricAvailable || !_isBiometricEnabled) return;

    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your AquaPay account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        // Success haptic feedback
        if (!kIsWeb) {
          HapticFeedback.lightImpact();
        }

        Fluttertoast.showToast(
          msg: "Biometric authentication successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
          textColor: Colors.white,
        );

        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      _showErrorMessage('Biometric authentication failed. Please try again.');
    }
  }

  void _showErrorMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.error,
      textColor: Colors.white,
    );
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Reset Password',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Password reset functionality will be available soon. Please contact customer support for assistance.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleRegister() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Customer Registration',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'New customer registration is available at our office or through our website. Please visit your nearest AquaPay service center.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
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
    _logoAnimationController.dispose();
    _formAnimationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 8.h),

                    // Logo Section
                    AnimatedBuilder(
                      animation: _logoAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoAnimation.value,
                          child: Column(
                            children: [
                              Container(
                                width: 25.w,
                                height: 25.w,
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4.w),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: CustomIconWidget(
                                    iconName: 'water_drop',
                                    color: Colors.white,
                                    size: 12.w,
                                  ),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                'AquaPay',
                                style: AppTheme
                                    .lightTheme.textTheme.headlineMedium
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Water Utility Billing',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 6.h),

                    // Form Section
                    SlideTransition(
                      position: _formSlideAnimation,
                      child: FadeTransition(
                        opacity: _formFadeAnimation,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Username Field
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.lightTheme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(2.w),
                                  border: Border.all(
                                    color: _usernameError != null
                                        ? AppTheme.lightTheme.colorScheme.error
                                        : AppTheme
                                            .lightTheme.colorScheme.outline,
                                    width: 1,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _usernameController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  onChanged: _validateUsername,
                                  decoration: InputDecoration(
                                    hintText: 'Username or Email',
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.all(3.w),
                                      child: CustomIconWidget(
                                        iconName: 'person',
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                        size: 6.w,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 4.h,
                                    ),
                                  ),
                                  style:
                                      AppTheme.lightTheme.textTheme.bodyLarge,
                                ),
                              ),

                              if (_usernameError != null) ...[
                                SizedBox(height: 1.h),
                                Padding(
                                  padding: EdgeInsets.only(left: 2.w),
                                  child: Text(
                                    _usernameError!,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color:
                                          AppTheme.lightTheme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],

                              SizedBox(height: 3.h),

                              // Password Field
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.lightTheme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(2.w),
                                  border: Border.all(
                                    color: _passwordError != null
                                        ? AppTheme.lightTheme.colorScheme.error
                                        : AppTheme
                                            .lightTheme.colorScheme.outline,
                                    width: 1,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  textInputAction: TextInputAction.done,
                                  onChanged: _validatePassword,
                                  onFieldSubmitted: (_) => _handleLogin(),
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.all(3.w),
                                      child: CustomIconWidget(
                                        iconName: 'lock',
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                        size: 6.w,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                      icon: CustomIconWidget(
                                        iconName: _isPasswordVisible
                                            ? 'visibility_off'
                                            : 'visibility',
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                        size: 6.w,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 4.h,
                                    ),
                                  ),
                                  style:
                                      AppTheme.lightTheme.textTheme.bodyLarge,
                                ),
                              ),

                              if (_passwordError != null) ...[
                                SizedBox(height: 1.h),
                                Padding(
                                  padding: EdgeInsets.only(left: 2.w),
                                  child: Text(
                                    _passwordError!,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color:
                                          AppTheme.lightTheme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],

                              SizedBox(height: 2.h),

                              // Forgot Password Link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _handleForgotPassword,
                                  child: Text(
                                    'Forgot Password?',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 4.h),

                              // Login Button
                              SizedBox(
                                height: 7.h,
                                child: ElevatedButton(
                                  onPressed: _isLoading || !_isFormValid
                                      ? null
                                      : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2.w),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          width: 6.w,
                                          height: 6.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          'Login',
                                          style: AppTheme
                                              .lightTheme.textTheme.titleMedium
                                              ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),

                              // Biometric Login Button
                              if (_isBiometricAvailable &&
                                  _isBiometricEnabled) ...[
                                SizedBox(height: 3.h),
                                SizedBox(
                                  height: 7.h,
                                  child: OutlinedButton.icon(
                                    onPressed: _isLoading
                                        ? null
                                        : _handleBiometricLogin,
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(2.w),
                                      ),
                                    ),
                                    icon: CustomIconWidget(
                                      iconName: 'fingerprint',
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      size: 6.w,
                                    ),
                                    label: Text(
                                      'Use Biometric',
                                      style: AppTheme
                                          .lightTheme.textTheme.titleMedium
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              SizedBox(height: 6.h),

                              // Register Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'New Customer? ',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _handleRegister,
                                    child: Text(
                                      'Register',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
