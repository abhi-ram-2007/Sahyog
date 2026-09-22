import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'report_issue_page.dart';

class SuccessPage extends StatelessWidget {
  final String trackingId;
  final String title;
  final String category;
  final String description;
  final String location;

  const SuccessPage({
    super.key,
    required this.trackingId,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
  });

  static const Color green = Color(0xFF078B49);
  static const Color darkText = Color(0xFF182131);
  static const Color greyText = Color(0xFF71839F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,

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
          'Report Submitted',
          style: TextStyle(
            color: darkText,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            30,
            20,
            30,
          ),
          child: Column(
            children: [
              // ====================================================
              // SUCCESS ICON
              // ====================================================

              Container(
                width: 105,
                height: 105,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F7ED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: green,
                  size: 65,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Problem Reported Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkText,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Your report has been received and routed for validation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: greyText,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 25),

              // ====================================================
              // TRACKING CARD
              // ====================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE2E6EA),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TRACKING ID',
                      style: TextStyle(
                        color: greyText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trackingId,
                            style: const TextStyle(
                              color: darkText,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        IconButton(
                          tooltip: 'Copy tracking ID',
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text: trackingId,
                              ),
                            );

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Tracking ID copied.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.copy_outlined,
                            color: green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Category: $category',
                      style: const TextStyle(
                        color: greyText,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Location: $location',
                      style: const TextStyle(
                        color: greyText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ====================================================
              // THANK YOU MESSAGE
              // ====================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFFAF4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      color: green,
                      size: 28,
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'We will notify you about the progress. Thank you for being a responsible citizen!',
                        style: TextStyle(
                          color: Color(0xFF305943),
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ====================================================
              // BACK TO CITIZEN DASHBOARD
              // ====================================================

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Back to Citizen Dashboard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ====================================================
              // REPORT ANOTHER ISSUE
              // ====================================================

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ReportIssuePage(),
                    ),
                  );
                },
                child: const Text(
                  'Report Another Issue',
                  style: TextStyle(
                    color: green,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration:
                        TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}