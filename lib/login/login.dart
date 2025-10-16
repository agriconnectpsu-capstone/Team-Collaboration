import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final Color darkGreen = const Color(0xFF0C3D2E);

  @override
  void initState() {
    super.initState();

    _emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    setState(() {
      _emailError = _emailController.text.isNotEmpty &&
          !EmailValidator.validate(_emailController.text.trim())
          ? 'Please input a valid email'
          : null;
    });
  }

  Future<void> _loginWithEmail() async {
    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!userCredential.user!.emailVerified) {
        setState(() {
          _emailError = 'Please verify your email before logging in.';
        });

        // Optional: Resend verification email automatically
        await userCredential.user!.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent again.'),
          ),
        );
        return; // Stop login
      }

      // Login successful message
      Navigator.pop(context); // Or navigate to Home page
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _emailError = 'Email is not registered yet.';
            break;
          case 'wrong-password':
            _passwordError = 'Password is incorrect.';
            break;
          case 'invalid-email':
            _emailError = 'Please input a valid email.';
            break;
          default:
            _emailError = e.message;
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty ||
        !EmailValidator.validate(_emailController.text.trim())) {
      setState(() {
        _emailError = 'Please input a valid email.';
      });
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _emailError = 'Email is not registered yet.';
        } else {
          _emailError = e.message;
        }
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      // Store data in Firestore if new users
      final doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      if (!doc.exists) {
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': googleUser.displayName ?? 'No Name',
          'email': googleUser.email,
          'createdAt': FieldValue.serverTimestamp(),
          'isVerified': true,
          'authProvider': 'google',
        });
      }

      // Auto-login successful
      Navigator.pop(context); // or navigate to Home page
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text(
                "Welcome!",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Login to AgriCommerce.",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 40),

              // Email
              _buildTextField(
                "Email",
                controller: _emailController,
                errorText: _emailError,
              ),
              const SizedBox(height: 15),

              // Password
              _buildTextField(
                "Password",
                controller: _passwordController,
                obscureText: _obscurePassword,
                errorText: _passwordError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black38,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _forgotPassword,
                  child: Text(
                    "Forgot Password?",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _loginWithEmail,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : Text(
                    "Login",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Text(
                "Or Login with",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(FontAwesomeIcons.facebookF, Colors.blue),
                  const SizedBox(width: 25),
                  GestureDetector(
                    onTap: _signInWithGoogle,
                    child: _socialButton(FontAwesomeIcons.google, Colors.red),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don’t have an account?",
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupPage()),
                      );
                    },
                    child: Text(
                      " Register Now",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: darkGreen,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String hint, {
        required TextEditingController controller,
        String? errorText,
        bool obscureText = false,
        Widget? suffixIcon,
      }) {
    return Column(
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF6F6F6),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(30),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
        if (errorText != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 5, left: 10),
              child: Text(
                errorText,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _socialButton(IconData icon, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.black12),
      ),
      child: Center(
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
