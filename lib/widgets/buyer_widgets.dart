import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

// Import your pages
import '/buyer/buyer_message.dart';
import '/buyer/buyer_notifs.dart'; // 👈 Add this import

class BuyerWidgets extends StatelessWidget {
  final Widget body;
  final String title;
  final int currentIndex;
  final Function(int)? onTabChange;

  const BuyerWidgets({
    super.key,
    required this.body,
    required this.title,
    this.currentIndex = 0,
    this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.notifications_outline, color: Colors.black),
            onPressed: () {
              // 👉 Navigate to Notifications Page here
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BuyerNotifsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Ionicons.chatbubble_ellipses, color: Colors.green),
            onPressed: () {
              // 👉 Navigate to Messages Page here
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BuyerMesssagePage()),
              );
            },
          ),
        ],
      ),

      body: body,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabChange,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Ionicons.home_outline), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Ionicons.add_circle_outline), label: "Request"),
          BottomNavigationBarItem(
              icon: Icon(Ionicons.cart_outline), label: "Orders"),
          BottomNavigationBarItem(
              icon: Icon(Ionicons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}