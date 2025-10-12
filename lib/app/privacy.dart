import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Privacy & Confidentiality",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Privacy Matters",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Effective Date: October 2025",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Privacy & Data Protection",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                    "Suspendisse ultricies, lorem nec commodo blandit, sem odio suscipit elit, "
                    "ut egestas lorem mi vel eros. Ut in urna non sapien elementum tincidunt.\n\n"
                    "We value your trust and are committed to safeguarding your personal information. "
                    "All data provided by users are used solely for app-related services and will not "
                    "be shared with third parties without your consent.\n\n"
                    "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip "
                    "ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit "
                    "esse cillum dolore eu fugiat nulla pariatur.",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Data Confidentiality",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Curabitur pretium tincidunt lacus. Nulla gravida orci a odio. "
                    "Nullam varius, turpis et commodo pharetra, est eros bibendum elit, "
                    "nec luctus magna felis sollicitudin mauris. Integer in mauris eu nibh euismod gravida.\n\n"
                    "Your profile details, transactions, and communications are stored securely. "
                    "Access is limited to authorized personnel only.",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  "© 2025 AgriConnect. All Rights Reserved.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[500],
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