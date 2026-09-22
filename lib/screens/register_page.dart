import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const Color primaryGreen = Color(0xFF078B49);
  static const Color darkText = Color(0xFF202735);
  static const Color greyText = Color(0xFF71839F);
  static const Color background = Color(0xFFF6F8F7);

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String selectedRole = 'citizen';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> register() async {
    final String name =
        nameController.text.trim();

    final String email =
        emailController.text.trim().toLowerCase();

    final String password =
        passwordController.text;

    final String confirmPassword =
        confirmPasswordController.text;

    // Name
    if (name.isEmpty) {
      _showMessage('Please enter your full name.');
      return;
    }

    // Email
    if (email.isEmpty) {
      _showMessage('Please enter your email address.');
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    // Password
    if (password.isEmpty) {
      _showMessage('Please create a password.');
      return;
    }

    if (password.length < 6) {
      _showMessage(
        'Password must contain at least 6 characters.',
      );
      return;
    }

    // Confirm password
    if (confirmPassword.isEmpty) {
      _showMessage(
        'Please confirm your password.',
      );
      return;
    }

    if (password != confirmPassword) {
      _showMessage(
        'Passwords do not match.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await _authService.register(
        fullName: name,
        email: email,
        password: password,
        role: selectedRole,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      // Email confirmation enabled
      if (response.session == null) {
        _showSuccessDialog();
      } else {
        _showMessage(
          'Account created successfully.',
        );

        Navigator.pop(context);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      String message =
          'Registration failed. Please try again.';

      final errorText =
          error.toString().toLowerCase();

      if (errorText.contains(
        'user already registered',
      )) {
        message =
            'An account with this email already exists.';
      } else if (errorText.contains(
        'password',
      )) {
        message =
            'Please choose a stronger password.';
      } else if (errorText.contains(
        'network',
      )) {
        message =
            'Network error. Please check your internet connection.';
      }

      _showMessage(message);
    }
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),

          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: primaryGreen,
                size: 30,
              ),

              SizedBox(width: 10),

              Text(
                'Account Created',
                style: TextStyle(
                  color: darkText,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),

          content: const Text(
            'Your Sahyog account has been created successfully.\n\n'
            'Please check your email and verify your account before logging in.',
            style: TextStyle(
              color: greyText,
              height: 1.5,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },

              child: const Text(
                'Go to Login',
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
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
        behavior:
            SnackBarBehavior.floating,
        backgroundColor: darkText,
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

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFDDE3EA),
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFDDE3EA),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
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

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        surfaceTintColor: background,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(
            Icons.arrow_back,
            color: darkText,
          ),
        ),

        title: const Text(
          'Create Account',
          style: TextStyle(
            color: darkText,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),

        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            24,
            10,
            24,
            30,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 480,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,

                children: [

                  const SizedBox(height: 10),

                  // ==================================================
                  // LOGO
                  // ==================================================

                  Center(
                    child: Container(
                      width: 85,
                      height: 85,

                      padding:
                          const EdgeInsets.all(10),

                      decoration:
                          const BoxDecoration(
                        color: Colors.white,
                        shape:
                            BoxShape.circle,
                      ),

                      child: Image.asset(
                        'assets/images/sahyog_logo.png',

                        fit: BoxFit.contain,

                        errorBuilder:
                            (context, error, stackTrace) {
                          return const Icon(
                            Icons.groups_rounded,
                            color:
                                primaryGreen,
                            size: 40,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Join Sahyog',
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: darkText,
                      fontSize: 26,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Create your account and become part of the collaboration.',
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: greyText,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // CARD
                  // ==================================================

                  Container(
                    padding:
                        const EdgeInsets.all(22),

                    decoration:
                        BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 25,
                          offset:
                              const Offset(
                            0,
                            10,
                          ),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        // FULL NAME

                        const Text(
                          'Full Name',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller:
                              nameController,

                          textCapitalization:
                              TextCapitalization.words,

                          textInputAction:
                              TextInputAction.next,

                          decoration:
                              _inputDecoration(
                            hintText:
                                'Enter your full name',
                            icon:
                                Icons.person_outline,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // EMAIL

                        const Text(
                          'Email Address',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller:
                              emailController,

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

                        const SizedBox(height: 18),

                        // PASSWORD

                        const Text(
                          'Password',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller:
                              passwordController,

                          obscureText:
                              obscurePassword,

                          textInputAction:
                              TextInputAction.next,

                          decoration:
                              _inputDecoration(
                            hintText:
                                'Create a password',
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

                        const SizedBox(height: 18),

                        // CONFIRM PASSWORD

                        const Text(
                          'Confirm Password',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller:
                              confirmPasswordController,

                          obscureText:
                              obscureConfirmPassword,

                          textInputAction:
                              TextInputAction.done,

                          onSubmitted: (_) {
                            if (!isLoading) {
                              register();
                            }
                          },

                          decoration:
                              _inputDecoration(
                            hintText:
                                'Confirm your password',
                            icon:
                                Icons
                                    .lock_reset_outlined,

                            suffixIcon:
                                IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },

                              icon: Icon(
                                obscureConfirmPassword
                                    ? Icons
                                        .visibility_outlined
                                    : Icons
                                        .visibility_off_outlined,

                                color: greyText,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ROLE

                        const Text(
                          'Account Type',
                          style: TextStyle(
                            color: darkText,
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          initialValue: selectedRole,
                          decoration:
                              _inputDecoration(
                            hintText:
                                'Select account type',
                            icon:
                                Icons
                                    .account_circle_outlined,
                          ),

                          items: const [
                            DropdownMenuItem(
                              value: 'citizen',
                              child:
                                  Text('Citizen'),
                            ),
                            DropdownMenuItem(
                              value: 'university',
                              child:
                                  Text('University'),
                            ),
                            DropdownMenuItem(
                              value: 'industry',
                              child:
                                  Text('Industry'),
                            ),
                            DropdownMenuItem(
                              value: 'government',
                              child:
                                  Text('Government'),
                            ),
                          ],

                          onChanged:
                              (value) {
                            if (value != null) {
                              setState(() {
                                selectedRole =
                                    value;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 28),

                        // REGISTER BUTTON

                        SizedBox(
                          width: double.infinity,
                          height: 54,

                          child:
                              ElevatedButton(
                            onPressed:
                                isLoading
                                    ? null
                                    : register,

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
                                      strokeWidth:
                                          2.5,
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    style:
                                        TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // LOGIN LINK

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [
                            const Text(
                              'Already have an account?',
                              style: TextStyle(
                                color: greyText,
                                fontSize: 13,
                              ),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                );
                              },

                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color:
                                      primaryGreen,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}