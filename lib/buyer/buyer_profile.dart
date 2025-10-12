import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

// Import your destination pages here (you can create them later)
import '/buyer/buyer_manage_profile.dart';
import '../app/privacy.dart';
import '/app/about_app.dart';
import '/app/help.dart';
 // or whatever your logout page is

class BuyerProfilePage extends StatelessWidget {
  const BuyerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 👤 User Avatar + Name + Email
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 10),
            Text(
              "UserUser",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "user22@gmail.com",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // ⚙️ Account Section
            _buildSection([
              _buildTile(
                context,
                "Manage Profile",
                Ionicons.person_outline,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuyerManageProfilePage()),
                ),
              ),
            ]),

            const SizedBox(height: 16),

            // 🔒 App Info Section
            _buildSection([
              _buildTile(
                context,
                "Privacy & Confidentiality",
                Ionicons.lock_closed_outline,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPage()),
                ),
              ),
              _buildTile(
                context,
                "About App",
                Ionicons.information_outline,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutAppPage()),
                ),
              ),
              _buildTile(
                context,
                "Help",
                Ionicons.help_circle_outline,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpPage()),
                ),
              ),
            ]),

            const SizedBox(height: 16),

            // 🚪 Log Out Button

          ],
        ),
      ),
    );
  }

  // 🔸 Section container
  Widget _buildSection(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: tiles),
    );
  }

  // 🔹 Reusable list tile widget
  Widget _buildTile(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap, {
        Color? textColor,
        Color? iconColor,
      }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor ?? Colors.green),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: textColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Ionicons.chevron_forward_outline, color: Colors.grey),
    );
  }
}
