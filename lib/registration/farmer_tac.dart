import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'farmer_registration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FarmerTac extends StatefulWidget {
  const FarmerTac({super.key});

  @override
  _FarmerTacState createState() => _FarmerTacState();
}

class _FarmerTacState extends State<FarmerTac> {
  bool isAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF1B5E20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''Welcome to AgriConnect, a mobile platform that connects farmers and business staff to communicate, post product requests, and transact directly.
By creating an account or using our services, you agree to these Terms and Conditions. Please read them carefully before proceeding.

1. Acceptance of Terms
By accessing or using AgriConnect, you confirm that you understand and agree to be bound by these Terms and Conditions.
If you do not agree, please do not use the app.

2. Eligibility
To use AgriConnect, you must:
• Be at least 18 years old;
• Provide accurate and complete information;
• Submit a valid government ID or BIR certificate for verification.
AgriConnect reserves the right to approve or deny any registration request.

3. Account Registration
When you register, you must choose your role as either a Farmer or Business Staff.
You agree to:
• Provide truthful and updated information;
• Keep your login credentials secure;
• Be responsible for all actions under your account.
If we detect any suspicious or unauthorized use, your account may be suspended or terminated.

4. User Verification
To maintain a safe environment, all users must submit valid identification for verification.
Submitting fake or altered documents may result in immediate account removal and potential legal action.

5. Platform Use
AgriConnect allows:
• Business staff to post product requests; and
• Farmers to respond and transact through those posts.
You agree not to:
• Post false or misleading information;
• Engage in fraudulent or illegal activities;
• Harass, spam, or impersonate others;
• Interfere with the app’s operation or security.

6. Communication and Transactions
Users can communicate directly through in-app messaging to discuss prices, quantities, and delivery.
Please note that AgriConnect:
• Does not act as a broker or intermediary;
• Is not responsible for any payment disputes, delivery delays, or product quality issues;
• Encourages both parties to verify details before confirming any transaction.
All agreements are strictly between the farmer and the business.

7. Additional Terms for Business Staff
Business staff are responsible for:
• Posting only accurate and legitimate product requests;
• Providing truthful company information;
• Communicating professionally and fairly with farmers.
Unfair or exploitative practices are strictly prohibited.

8. Additional Terms for Farmers
Farmers are responsible for:
• Providing honest product information (quality, price, quantity);
• Communicating respectfully and transparently;
• Ensuring agreed products are available as promised.

9. Data Privacy
AgriConnect values your privacy.
All personal data — including IDs and business certifications — will be collected, processed, and stored in compliance with the Data Privacy Act of 2012 (RA 10173).
By using the app, you consent to the collection and use of your information for account verification, platform functionality, and communication purposes.
For full details, please review our Privacy Policy.

10. Intellectual Property
All designs, logos, text, and software in AgriConnect are owned by the developers or licensed to them.
You may not copy, reproduce, or distribute any part of the app without written permission.

11. Account Suspension or Termination
Your account may be suspended or terminated if you:
• Violate these Terms;
• Provide false information; or
• Engage in misconduct or fraudulent activities.
You may also request to delete your account at any time by contacting support.

12. Limitation of Liability
AgriConnect is a connecting platform only.
We are not liable for:
• Product disputes or delivery problems;
• Pricing or payment disagreements;
• Damages arising from user negligence or third-party actions.
Use of the app is at your own risk.

13. Changes to Terms
We may update these Terms and Conditions from time to time.
Any updates will take effect once posted in the app. Continued use means you accept the new version.

14. Contact Us
If you have any questions or concerns, you may reach us at:
📧 agriconnect.psu@gmail.com

By tapping “Agree” or creating an account, you confirm that you have read, understood, and accepted these Terms and Conditions.

Last updated: October 2025''',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: isAccepted,
                  onChanged: (val) {
                    setState(() {
                      isAccepted = val ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'I accept the Terms & Conditions',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isAccepted
                    ? () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .set({
                      'hasAcceptedTerms': true,
                    }, SetOptions(merge: true));
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FarmerRegistration(),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'CONTINUE',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
