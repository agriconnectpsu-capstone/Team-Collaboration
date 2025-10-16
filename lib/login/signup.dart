import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String _passwordStrength = '';

  final Color darkGreen = const Color(0xFF0C3D2E);

  @override
  void initState() {
    super.initState();

    // Real-time validation listeners
    _usernameController.addListener(_validateUsername);
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  void _validateUsername() {
    setState(() {
      _usernameError =
      _usernameController.text.trim().isEmpty ? 'Username is required' : null;
    });
  }

  void _validateEmail() {
    setState(() {
      _emailError = !EmailValidator.validate(_emailController.text.trim())
          ? 'Please input a real email'
          : null;
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    String? error;
    if (password.length < 6) {
      error = 'Your password should be at least 6 characters long';
    } else if (!RegExp(r'[!@#\$&*~]').hasMatch(password)) {
      error = 'Your password needs at least 1 special character';
    }
    setState(() {
      _passwordError = error;
      _passwordStrength = _getPasswordStrength(password);
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      _confirmPasswordError =
      _confirmPasswordController.text != _passwordController.text
          ? "It doesn't match your password"
          : null;
    });
  }

  String _getPasswordStrength(String password) {
    if (password.isEmpty) return '';
    int score = 0;
    if (password.length >= 6) score++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    switch (score) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
      case 3:
        return 'Medium';
      case 4:
        return 'Strong';
      default:
        return '';
    }
  }

  Future<void> _registerWithEmail() async {
    _validateUsername();
    _validateEmail();
    _validatePassword();
    _validateConfirmPassword();

    if (_usernameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return; // There are validation errors
    }

    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Store username and email in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': false,
        'authProvider': 'email',
      });

      // Show a dialog with "Resend Email" option
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Verify your email'),
          content: const Text(
              'A verification email has been sent. Please verify your email before logging in.'),
          actions: [
            TextButton(
              onPressed: () async {
                // Resend verification email
                await userCredential.user!.sendEmailVerification();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Verification email sent again.'),
                  ),
                );
              },
              child: const Text('Resend Email'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Please input a valid email.';
          break;
        case 'weak-password':
          message = 'Your password is too weak.';
          break;
        default:
          message = e.message ?? 'An error occurred.';
      }
      setState(() {
        _emailError = message;
      });
    } catch (e) {
      print(e);
    }
  }


  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // user canceled

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      // Store user in Firestore if new
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

      // Auto login successful, navigate or pop
      Navigator.pop(context); // or push to home page
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                "Hello!",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Register to get started.",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 40),

              // Username
              _buildTextField(
                "Username",
                controller: _usernameController,
                errorText: _usernameError,
              ),
              const SizedBox(height: 15),

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
                errorText: _passwordError,
                obscureText: _obscurePassword,
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
              if (_passwordStrength.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password Strength: $_passwordStrength',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _passwordStrength == 'Weak'
                              ? Colors.red
                              : _passwordStrength == 'Medium'
                              ? Colors.orange
                              : Colors.green),
                    ),
                  ),
                ),
              const SizedBox(height: 15),

              // Confirm Password
              _buildTextField(
                "Confirm password",
                controller: _confirmPasswordController,
                errorText: _confirmPasswordError,
                obscureText: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black38,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                ),
              ),
              const SizedBox(height: 25),

              // Register button
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
                  onPressed: _registerWithEmail,
                  child: Text(
                    "Register",
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
                "Or Register with",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
              ),

              const SizedBox(height: 15),

              // Social Login buttons
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
                    "Already have an account?",
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: Text(
                      " Login Now",
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
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                errorText,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500),
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
