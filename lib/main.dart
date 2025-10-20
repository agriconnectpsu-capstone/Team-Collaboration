import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login/login.dart';
import 'registration/registerpage.dart';
import '/login/signup.dart';
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

        if (!snapshot.hasData) {
          return const LoginPage();
        }

        final user = snapshot.data!;

        // 🔒 If email not verified (only for password accounts)
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

        return FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('users').doc(user.uid).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const SignupPage();
            }

            final data =
                userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
            final String? role = data['role'];

            if (role == null || role.isEmpty) {
              return const RegisterPage();
            }

            final regCollection = role == 'farmer'
                ? 'farmer_registration'
                : 'business_registration';

            return FutureBuilder<DocumentSnapshot>(
              future:
              _firestore.collection(regCollection).doc(user.uid).get(),
              builder: (context, regSnapshot) {
                if (regSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!regSnapshot.hasData || !regSnapshot.data!.exists) {
                  return const RegisterPage();
                }

                if (role == 'farmer') {
                  return const FarmerHomepage();
                } else {
                  return const BuyerHomePage();
                }
              },
            );
          },
        );
      },
    );
  }
}

