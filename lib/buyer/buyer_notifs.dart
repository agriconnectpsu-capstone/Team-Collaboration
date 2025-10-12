import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class BuyerNotifsPage extends StatefulWidget {
  const BuyerNotifsPage({super.key});

  @override
  State<BuyerNotifsPage> createState() => _BuyerNotifsPageState();
}

class _BuyerNotifsPageState extends State<BuyerNotifsPage> {
  String selectedFilter = 'Latest';

  // Simulated backend data — replace this with your API/Firebase later
  final List<Map<String, String>> notifications = [
    {
      'title': '@User.Seller wants to transact..........',
      'type': 'Latest',
    },
    {
      'title': '@User.Seller wants to transact..........',
      'type': 'Price',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter notifications based on selected category
    final filteredNotifications = notifications
        .where((n) => n['type'] == selectedFilter || selectedFilter == 'Latest')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.chevron_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: implement edit/delete functionality
            },
            child: Text(
              'Edit',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // 🔘 Filter Buttons Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildFilterButton('Latest'),
                const SizedBox(width: 8),
                _buildFilterButton('Price'),
                const SizedBox(width: 8),
                _buildFilterButton('Type'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 📜 Notifications List
          Expanded(
            child: filteredNotifications.isEmpty
                ? Center(
              child: Text(
                'No notifications available',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: filteredNotifications.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final notif = filteredNotifications[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notif['title'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    final bool isSelected = selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}