import 'package:flutter/material.dart';

void main() {
  runApp(const SahyogApp());
}

class SahyogApp extends StatelessWidget {
  const SahyogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Solve Together',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D8544)),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      body: Center(
        child: Container(
          width: 424,
          height: MediaQuery.of(context).size.height,

          decoration: BoxDecoration(
            color: Colors.white,

            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),

          child: SafeArea(
            child: Column(
              children: [
                // ==================================================
                // SCROLLABLE CONTENT
                // ==================================================

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // ==================================================
                        // HEADER
                        // ==================================================

                        Container(
                          height: 66,

                          padding: const EdgeInsets.only(left: 21, right: 21),

                          color: Colors.white,

                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: [
                              // Green logo
                              Container(
                                width: 34,
                                height: 34,

                                decoration: BoxDecoration(
                                  color: const Color(0xFF2D8544),

                                  borderRadius: BorderRadius.circular(8),
                                ),

                                child: const Icon(
                                  Icons.people_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),

                              const SizedBox(width: 9),

                              // App name
                              const Text(
                                'Solve Together',

                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF204E2D),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ==================================================
                        // HERO IMAGE
                        // ==================================================
                        SizedBox(
                          width: double.infinity,
                          height: 171,

                          child: Image.network(
                            'https://images.unsplash.com/photo-1500534623283-312aade485b7?auto=format&fit=crop&w=900&q=80',

                            fit: BoxFit.cover,

                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,

                                    colors: [
                                      Color(0xFFFFD28A),
                                      Color(0xFFF49B61),
                                      Color(0xFF607D59),
                                    ],
                                  ),
                                ),

                                child: const Center(
                                  child: Icon(
                                    Icons.park_outlined,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // ==================================================
                        // CONTENT
                        // ==================================================
                        Padding(
                          padding: const EdgeInsets.fromLTRB(21, 16, 21, 24),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              // Main heading
                              const Text(
                                'Connect & Build Better',

                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF202735),
                                  height: 1.25,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Description
                              const Text(
                                'Bridging Citizens, Universities, '
                                'Industries, and Government for '
                                'fast-track civic progress and '
                                'validated problem-solving.',

                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF7887A1),
                                  height: 1.42,
                                ),
                              ),

                              const SizedBox(height: 19),

                              // Collaborators
                              const Text(
                                'COLLABORATORS',

                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF272D38),
                                  letterSpacing: 0.1,
                                ),
                              ),

                              const SizedBox(height: 11),

                              // ==================================================
                              // TWO COLUMN GRID
                              // ==================================================
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  // LEFT COLUMN
                                  Expanded(
                                    child: Column(
                                      children: [
                                        CollaboratorCard(
                                          title: 'Citizen',

                                          description: 'Report local civic issues instantly',

                                          icon: Icons.person_outline,

                                          iconColor: const Color(0xFF268A47),

                                          iconBackground: const Color(
                                            0xFFE6F4E9,
                                          ),
                                        ),

                                        const SizedBox(height: 12),

                                        CollaboratorCard(
                                          title: 'Industry',

                                          description:
                                              'Sponsor resources & materials',

                                          icon: Icons.business_center_outlined,

                                          iconColor: const Color(0xFF7D3CFF),

                                          iconBackground: const Color(
                                            0xFFF0E5FF,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // RIGHT COLUMN
                                  Expanded(
                                    child: Column(
                                      children: [
                                        CollaboratorCard(
                                          title: 'University',

                                          description: 'Design smart technical solutions',

                                          icon: Icons.menu_book_outlined,

                                          iconColor: const Color(0xFF3488C5),

                                          iconBackground: const Color(
                                            0xFFE2F2FF,
                                          ),
                                        ),

                                        const SizedBox(height: 12),

                                        CollaboratorCard(
                                          title: 'Government',

                                          description:
                                              'Approve, monitor & implement',

                                          icon:
                                              Icons.workspace_premium_outlined,

                                          iconColor: const Color(0xFFE6A500),

                                          iconBackground: const Color(
                                            0xFFFFF2C7,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // GET STARTED BUTTON
                // ==================================================
                Container(
                  width: double.infinity,

                  height: 63,

                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 2),

                  color: Colors.white,

                  child: ElevatedButton(
                    onPressed: () {},

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D8544),

                      foregroundColor: Colors.white,

                      elevation: 0,

                      padding: EdgeInsets.zero,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),

                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text(
                          'Get Started',

                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        SizedBox(width: 14),

                        Icon(Icons.arrow_forward, size: 19),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// COLLABORATOR CARD
// ============================================================

class CollaboratorCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  const CollaboratorCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 136,

      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),

      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),

        borderRadius: BorderRadius.circular(13),

        border: Border.all(color: const Color(0xFFDCE3EC), width: 1),
      ),

      child: Column(
        // ⭐ THIS CENTERS EVERYTHING HORIZONTALLY
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          // ================= ICON =================

          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),

            child: Icon(icon, color: iconColor, size: 21),
          ),

          const SizedBox(height: 7),

          // ================= TITLE =================
          Text(
            title,

            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF252B38),
            ),
          ),

          const SizedBox(height: 4),

          // ================= DESCRIPTION =================
          Expanded(
            child: Center(
              child: Text(
                description,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7887A1),
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
