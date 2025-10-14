import 'package:agriconnectapp/buyer/manage_profile/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class BuyerManageProfilePage extends StatelessWidget {
  const BuyerManageProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Manage Profile",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.green[700],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Ionicons.information_circle_outline, color: Colors.green),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 👤 User avatar and info
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
                color: Colors.black87,
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

            // 🧩 Profile Options
            _buildSection([
              _buildTile(
                context,
                "Edit Profile",
                Ionicons.create_outline,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfilePage()),
                  );
                },
              ),
              _buildTile(
                context,
                "Order History",
                Ionicons.receipt_outline,
                    () {
                  // Navigate to Order History Page
                },
              ),
              _buildTile(
                context,
                "Shipping Details",
                Ionicons.location_outline,
                    () {
                  // Navigate to Shipping Details Page
                },
              ),
              _buildTile(
                context,
                "Change Password",
                Ionicons.lock_closed_outline,
                    () {
                  // Navigate to Change Password Page
                },
              ),
            ]),
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

  // 🔹 List item
  Widget _buildTile(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Ionicons.chevron_forward_outline, color: Colors.grey),
    );
  }
}