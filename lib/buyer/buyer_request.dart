import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuyerRequestPage extends StatefulWidget {
  const BuyerRequestPage({super.key});

  @override
  State<BuyerRequestPage> createState() => _BuyerRequestPageState();
}

class _BuyerRequestPageState extends State<BuyerRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController productController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String countryCode = "+63";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name
            Text("Product Name",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _textField(
              controller: productController,
              hint: "Enter product name",
            ),

            const SizedBox(height: 16),
            // Quantity
            Text("Quantity",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _textField(
              controller: quantityController,
              hint: "Enter quantity",
              keyboard: TextInputType.number,
            ),

            const SizedBox(height: 16),
            // Phone Number
            Text("Phone Number",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: countryCode,
                      items: const [
                        DropdownMenuItem(value: "+63", child: Text("+63")),
                        DropdownMenuItem(value: "+1", child: Text("+1")),
                        DropdownMenuItem(value: "+44", child: Text("+44")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          countryCode = value!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _textField(
                    controller: phoneController,
                    hint: "Phone number",
                    keyboard: TextInputType.phone,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            // Location
            Text("Location",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _textField(
              controller: addressController,
              hint: "Detailed Address",
            ),

            const SizedBox(height: 30),
            // Upload Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B7A55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Product request submitted!'),
                      ),
                    );
                  }
                },
                child: Text(
                  "UPLOAD",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboard,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: (value) => value!.isEmpty ? "Required field" : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.green),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }
}