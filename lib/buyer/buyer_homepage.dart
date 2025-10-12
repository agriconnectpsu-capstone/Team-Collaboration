import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/buyer_widgets.dart';
import '/buyer/buyer_request.dart'; // <-- make sure this file exists

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({super.key});

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  int _selectedIndex = 0;

  final List<String> _titles = ["Home", "Request", "Orders", "Profile"];

  // ✅ Each tab’s content and logic
  late final List<Widget> _pages = [
    const HomeContent(),
    const BuyerRequestPage(),
    Center(
      child: Text("Orders Page",
          style:
          GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
    ),
    Center(
      child: Text("Profile Page",
          style:
          GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
    ),
  ];

  void _onTabChange(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return BuyerWidgets(
      title: _titles[_selectedIndex],
      body: _pages[_selectedIndex],
      currentIndex: _selectedIndex,
      onTabChange: _onTabChange,
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> categories = ["Spices", "Vegetables", "Rice", "Fruits"];

    final List<Map<String, String>> products = List.generate(
      6,
          (index) => {
        "name": "Watermelon Red Round",
        "price": "₱ 60.00 / kg",
        "condition": "Fresh",
        "image": "https://i.imgur.com/YvNQ1kB.png",
      },
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 🏷️ Categories
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                bool selected = index == 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(
                      categories[index],
                      style: GoogleFonts.poppins(
                        color: selected ? Colors.white : Colors.green.shade700,
                      ),
                    ),
                    selected: selected,
                    onSelected: (_) {},
                    selectedColor: Colors.green,
                    backgroundColor: Colors.white,
                    shape: StadiumBorder(
                      side: BorderSide(color: Colors.green.shade200),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // 🛒 Recent Products Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Products",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade900,
                  fontSize: 18,
                ),
              ),
              Text(
                "Filter",
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 🧺 Product Grid
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 230,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      child: Image.network(
                        product["image"]!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product["name"]!,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Per Kilogram",
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            "Condition: ${product["condition"]!}",
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product["price"]!,
                            style: GoogleFonts.poppins(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}