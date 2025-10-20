import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login/login.dart';
import 'registration/registerpage.dart';
import '/registration/done/farmer_done.dart';
import '/registration/done/business_done.dart';
import '/login/signup.dart';
import '/registration/business_registration.dart';
import '/registration/farmer_registration.dart';
import '/buyer/buyer_homepage.dart';
import '/farmer/farmer_homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriConnect',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🚪 Not logged in → go to Login page
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        final user = snapshot.data!;

        // 🔒 If email not verified
        if (!user.emailVerified &&
            user.providerData[0].providerId == 'password') {
          return Scaffold(
            body: Center(
              child: AlertDialog(
                title: const Text('Email Verification Required'),
                content: const Text(
                  'Please verify your email before proceeding. '
                      'Check your inbox for the verification email.',
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await user.sendEmailVerification();
                      await _auth.signOut();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          );
        }

        // ✅ Email verified → fetch user data
        return FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('users').doc(user.uid).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // 📄 No Firestore doc → go to Signup
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const SignupPage();
            }

            final data =
                userSnapshot.data!.data() as Map<String, dynamic>? ?? {};

            final bool hasAcceptedTerms = data['hasAcceptedTerms'] ?? false;
            final bool isRegistered = data['isRegistered'] ?? false;
            final String? role = data['role'];

            // 🧭 Navigation Logic
            if (role == null || role.isEmpty) {
              return const RegisterPage();
            } else if (!hasAcceptedTerms) {
              return const RegisterPage();
            } else if (!isRegistered) {
              return const RegisterPage();
            } else {
              // ✅ Registration complete → go to specific homepage
              if (role == 'business') {
                return const BuyerHomePage();
              } else if (role == 'farmer') {
                return const FarmerHomepage();
              } else {
                return const RegisterPage();
              }
            }
          },
        );
      },
    );
  }
}
