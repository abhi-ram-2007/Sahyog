import 'package:flutter/material.dart';

import '../dashboards/citizen_dashboard.dart';
import '../dashboards/university_dashboard.dart';
import '../dashboards/industry_dashboard.dart';
import '../dashboards/government_dashboard.dart';

import '../services/auth_service.dart';

import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color primaryGreen = Color(0xFF078B49);
  static const Color darkText = Color(0xFF202735);
  static const Color greyText = Color(0xFF71839F);
  static const Color background = Color(0xFFF6F8F7);

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final AuthService _authService = AuthService();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login() async {
    final String email =
        emailController.text.trim().toLowerCase();

    final String password =
        passwordController.text;

    // Email validation
    if (email.isEmpty) {
      _showMessage(
        'Please enter your email address.',
      );
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage(
        'Please enter a valid email address.',
      );
      return;
    }

    // Password validation
    if (password.isEmpty) {
      _showMessage(
        'Please enter your password.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Login through Supabase Authentication
      await _authService.login(
        email: email,
        password: password,
      );

      // Get authority/role from profiles table
      final String role =
          await _authService.getUserRole();

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      // Open the dashboard according to the role
      _openDashboard(role);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      final String errorMessage =
          error.toString().toLowerCase();

      String message =
          'Login failed. Please try again.';

      if (errorMessage.contains(
        'invalid login credentials',
      )) {
        message =
            'Incorrect email or password.';
      } else if (errorMessage.contains(
        'email not confirmed',
      )) {
        message =
            'Please verify your email before logging in.';
      } else if (errorMessage.contains(
        'network',
      )) {
        message =
            'Network error. Please check your internet connection.';
      } else if (errorMessage.contains(
        'profiles',
      )) {
        message =
            'Your account profile could not be found.';
      }

      _showMessage(message);
    }
  }

  // ============================================================
  // OPEN DASHBOARD
  // ============================================================

  void _openDashboard(String role) {
    Widget dashboard;

    switch (role) {
      case 'citizen':
        dashboard = const CitizenDashboard();
        break;

      case 'university':
        dashboard = const UniversityDashboard();
        break;

      case 'industry':
        dashboard = const IndustryDashboard();
        break;

      case 'government':
        dashboard = const GovernmentDashboard();
        break;

      default:
        _showMessage(
          'Invalid authority assigned to this account.',
        );
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => dashboard,
      ),
    );
  }

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkText,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(
        color: greyText,
        fontSize: 14,
      ),

      prefixIcon: Icon(
        icon,
        color: primaryGreen,
      ),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFDDE3EA),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFDDE3EA),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryGreen,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 30,
            ),

            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,

                children: [
                  // ==================================================
                  // LOGO
                  // ==================================================

                  Center(
                    child: Container(
                      width: 105,
                      height: 105,

                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.06,
                            ),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Padding(
                        padding:
                            const EdgeInsets.all(12),

                        child: Image.asset(
                          'assets/images/sahyog_logo_transparent.png',

                          fit: BoxFit.contain,

                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons.groups_rounded,
                              color: primaryGreen,
                              size: 48,
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // WELCOME
                  // ==================================================

                  const Text(
                    'Welcome to Sahyog',
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: darkText,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Connect. Collaborate. Create change.',
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: greyText,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ==================================================
                  // LOGIN CARD
                  // ==================================================

                  Container(
                    padding: const EdgeInsets.all(22),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.05,
                          ),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        // ==================================================
                        // SIGN IN TITLE
                        // ==================================================

                        const Text(
                          'Sign in',

                          style: TextStyle(
                            color: darkText,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Sign in using your registered Sahyog account.',

                          style: TextStyle(
                            color: greyText,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ==================================================
                        // EMAIL
                        // ==================================================

                        const Text(
                          'Email Address',

                          style: TextStyle(
                            color: darkText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller: emailController,

                          keyboardType:
                              TextInputType.emailAddress,

                          textInputAction:
                              TextInputAction.next,

                          decoration:
                              _inputDecoration(
                            hintText:
                                'Enter your email',

                            icon:
                                Icons.email_outlined,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // PASSWORD
                        // ==================================================

                        const Text(
                          'Password',

                          style: TextStyle(
                            color: darkText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller:
                              passwordController,

                          obscureText:
                              obscurePassword,

                          textInputAction:
                              TextInputAction.done,

                          onSubmitted: (_) {
                            if (!isLoading) {
                              login();
                            }
                          },

                          decoration:
                              _inputDecoration(
                            hintText:
                                'Enter your password',

                            icon:
                                Icons.lock_outline,

                            suffixIcon:
                                IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword =
                                      !obscurePassword;
                                });
                              },

                              icon: Icon(
                                obscurePassword
                                    ? Icons
                                        .visibility_outlined
                                    : Icons
                                        .visibility_off_outlined,

                                color: greyText,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                        // ==================================================
                        // LOGIN BUTTON
                        // ==================================================

                        SizedBox(
                          width: double.infinity,
                          height: 54,

                          child: ElevatedButton(
                            onPressed:
                                isLoading
                                    ? null
                                    : login,

                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  primaryGreen,

                              foregroundColor:
                                  Colors.white,

                              elevation: 0,

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),
                              ),
                            ),

                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,

                                    child:
                                        CircularProgressIndicator(
                                      color:
                                          Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Login',

                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ==================================================
                        // OR DIVIDER
                        // ==================================================

                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color:
                                    Colors.grey.shade300,
                              ),
                            ),

                            const Padding(
                              padding:
                                  EdgeInsets.symmetric(
                                horizontal: 12,
                              ),

                              child: Text(
                                'OR',

                                style: TextStyle(
                                  color: greyText,
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),

                            Expanded(
                              child: Divider(
                                color:
                                    Colors.grey.shade300,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // REGISTER LINK
                        // ==================================================

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [
                            const Text(
                              "Don't have an account?",

                              style: TextStyle(
                                color: greyText,
                                fontSize: 13,
                              ),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const RegisterPage(),
                                  ),
                                );
                              },

                              child: const Text(
                                'Register',

                                style: TextStyle(
                                  color: primaryGreen,
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // FOOTER
                  // ==================================================

                  const Text(
                    'Sahyog • Connecting citizens, institutions and government',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: greyText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}