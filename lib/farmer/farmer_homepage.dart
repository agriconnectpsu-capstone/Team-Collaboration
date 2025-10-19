import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmerHomepage extends StatelessWidget {
  const FarmerHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32), // same dark green
        title: Text(
          'Farmer Homepage',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "Welcome, Farmer!",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E1E1E),
          ),
        ),
      ),
    );
  }
}
