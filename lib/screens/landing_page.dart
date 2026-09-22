import 'package:flutter/material.dart';

import 'login_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const Color primaryGreen = Color(0xFF078B49);
  static const Color darkText = Color(0xFF202735);
  static const Color greyText = Color(0xFF71839F);

  // ============================================================
  // GET STARTED
  // ============================================================

  void _openLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ========================================================
              // SAHYOG LOGO
              // ========================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  18,
                  24,
                  18,
                ),
                child: SizedBox(
                  height: 125,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/sahyog_logo_transparent.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // ========================================================
              // HERO IMAGE
              // ========================================================

              SizedBox(
                width: double.infinity,
                height: 350,
                child: Image.asset(
                  'assets/images/hero_image.png',
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      color: const Color(0xFFE5F4EC),
                      child: const Center(
                        child: Icon(
                          Icons.groups_rounded,
                          color: primaryGreen,
                          size: 90,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ========================================================
              // INTRODUCTION
              // ========================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  30,
                  32,
                  30,
                  0,
                ),
                child: Column(
                  children: [
                    const Text(
                      'Connect & Build Better',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: darkText,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Bridging Citizens, Universities, Industries, and Government for fast-track civic progress and validated problem-solving.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: greyText,
                        fontSize: 19,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 34),

                    // ==================================================
                    // COLLABORATORS TITLE
                    // ==================================================

                    const Text(
                      'COLLABORATORS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: darkText,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // FIRST ROW
                    // ==================================================

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _collaboratorCard(
                            icon: Icons.person_outline,
                            title: 'Citizen',
                            description:
                                'Report local civic issues instantly',
                            iconBackground:
                                const Color(0xFFE5F5E9),
                            iconColor:
                                const Color(0xFF078B49),
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: _collaboratorCard(
                            icon: Icons.menu_book_outlined,
                            title: 'University',
                            description:
                                'Design smart technical solutions',
                            iconBackground:
                                const Color(0xFFE2F2FF),
                            iconColor:
                                const Color(0xFF0088CC),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // SECOND ROW
                    // ==================================================

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _collaboratorCard(
                            icon:
                                Icons.business_center_outlined,
                            title: 'Industry',
                            description:
                                'Sponsor resources & materials',
                            iconBackground:
                                const Color(0xFFF0E4FF),
                            iconColor:
                                const Color(0xFF7A3FE5),
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: _collaboratorCard(
                            icon:
                                Icons.workspace_premium_outlined,
                            title: 'Government',
                            description:
                                'Approve, monitor & implement',
                            iconBackground:
                                const Color(0xFFFFF1C9),
                            iconColor:
                                const Color(0xFFD88600),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // ========================================================
              // GET STARTED BUTTON
              // ========================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 58,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 82,
                  child: ElevatedButton(
                    onPressed: () {
                      _openLogin(context);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                    ),

                    child: const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        SizedBox(width: 22),

                        Icon(
                          Icons.arrow_forward,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COLLABORATOR CARD
  // ============================================================

  Widget _collaboratorCard({
    required IconData icon,
    required String title,
    required String description,
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Container(
      height: 260,

      padding: const EdgeInsets.fromLTRB(
        18,
        20,
        18,
        18,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFFCFDFE),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: const Color(0xFFDCE4EC),
          width: 1.5,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          // ========================================================
          // ICON
          // ========================================================

          Container(
            width: 88,
            height: 88,

            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: iconColor,
              size: 48,
            ),
          ),

          const SizedBox(height: 16),

          // ========================================================
          // TITLE
          // ========================================================

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: darkText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          // ========================================================
          // DESCRIPTION
          // ========================================================

          Expanded(
            child: Center(
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: greyText,
                  fontSize: 17,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}