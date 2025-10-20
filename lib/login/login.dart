import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 🔥 Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🧠 Text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ⚙️ State variables
  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // 🎨 Theme colors
  final Color darkGreen = const Color(0xFF0C3D2E);

  // 🧹 Dispose controllers when page is destroyed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 📧 Login using Email & Password
  Future<void> _loginWithEmail() async {
    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    // 🧩 Basic validation
    if (!EmailValidator.validate(email)) {
      setState(() {
        _emailError = 'Please enter a valid email.';
        _isLoading = false;
      });
      return;
    }
    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Please enter your password.';
        _isLoading = false;
      });
      return;
    }

    try {
      // ✅ Attempt sign-in
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      // 🚫 If email not verified yet
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        setState(() {
          _emailError = 'Please verify your email first.';
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent again.')),
        );
        return;
      }

      // 🗂️ Ensure Firestore record exists
      if (user != null) {
        final docRef = _firestore.collection('users').doc(user.uid);
        final docSnap = await docRef.get();

        if (!docSnap.exists) {
          await docRef.set({
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'isVerified': true,
            'authProvider': 'email',
          });
        } else {
          await docRef.update({'isVerified': true});
        }
      }

      // 🎉 Success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );

      // 🔁 Navigate back or to homepage
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // ⚠️ Handle Firebase errors
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _emailError = 'Email not registered.';
            break;
          case 'wrong-password':
            _passwordError = 'Incorrect password.';
            break;
          case 'invalid-email':
            _emailError = 'Invalid email format.';
            break;
          default:
            _emailError = e.message;
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🔑 Sign in with Google
  Future<void> _signInWithGoogle() async {
    try {
      setState(() => _isLoading = true);

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // Cancelled

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // 🗂️ Save new Google user to Firestore
      final userDoc = _firestore.collection('users').doc(user!.uid);
      if (!(await userDoc.get()).exists) {
        await userDoc.set({
          'username': googleUser.displayName ?? 'No Name',
          'email': googleUser.email,
          'createdAt': FieldValue.serverTimestamp(),
          'isVerified': true,
          'authProvider': 'google',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in with Google successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🔁 Password Reset
  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (!EmailValidator.validate(email)) {
      setState(() => _emailError = 'Enter a valid email first.');
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset email sent successfully!',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: darkGreen,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No account found with that email.',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: darkGreen,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        debugPrint("Password reset failed: ${e.code}");
      }
    }
  }

  // UI Building
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
                "Login to AgriConnect.",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 40),

              // 📩 Email Input
              _buildTextField(
                "Email",
                controller: _emailController,
                errorText: _emailError,
              ),
              const SizedBox(height: 15),

              // 🔒 Password Input
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
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
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

              // 🔘 Login Button
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
                      ? const CircularProgressIndicator(color: Colors.white)
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
                style:
                GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 15),

              // 🌐 Google Sign-In Button
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

              // 🔗 Go to Signup
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🧱 Reusable TextField Builder
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
            hintStyle:
            GoogleFonts.poppins(color: Colors.black38, fontSize: 14),
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

  // Reusable Social Button
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
