import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediswiftmobile/views/doctor/dashboard/doctor_dashboard.dart';
import 'package:mediswiftmobile/views/auth/doctor_signup.dart';

class DoctorLoginPage extends StatefulWidget {
  const DoctorLoginPage({super.key});

  @override
  State<DoctorLoginPage> createState() => _DoctorLoginPageState();
}

class _DoctorLoginPageState extends State<DoctorLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool obscurePassword = true;

  Future<void> _loginDoctor() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter all fields"),
        ),
      );
      return;
    }

    // 🔹 Load doctor.json
    final String response = await rootBundle.loadString(
      'assets/doctor.json',
    );

    final List<dynamic> doctors = json.decode(response);

    // 🔹 Find matching doctor
    final matchedDoctor = doctors.firstWhere(
      (doc) =>
          doc['email'] != null &&
          doc['email'].toString().toLowerCase() == email,
      orElse: () => null,
    );

    if (matchedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Doctor not found"),
        ),
      );
      return;
    }

    // 🔹 Navigate to Dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorDashboard(
          doctor: matchedDoctor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E5F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                // 🩺 Doctor Banner
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage(
                        "assets/images/doctor_illustration.png",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 👨‍⚕️ Heading
                const Text(
                  "Welcome Doctor",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Sign in to your professional account",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter',
                  ),
                ),

                const SizedBox(height: 26),

                // 📦 Login Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 📧 Email Field
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Email address",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                            fontFamily: 'Inter',
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF5646E8),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🔒 Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                            fontFamily: 'Inter',
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF5646E8),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // 🔘 Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _loginDoctor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5646E8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ❓ Forgot Password
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "Forgot password?",
                          style: TextStyle(
                            color: Color(0xFF5646E8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // 🔄 Switch Login
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Color(0xFF5646E8),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Are you a patient?",
                        style: TextStyle(
                          color: Color(0xFF5646E8),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 🆕 Signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "New doctor? ",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontFamily: 'Inter',
                      ),
                    ),
                    GestureDetector(
  onTap: () {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder:
            (_, animation, __) => FadeTransition(
              opacity: animation,
              child: const DoctorSignupPage(),
            ),
      ),
    );
  },
  child: const Text(
    "Sign up",
                        style: TextStyle(
                          color: Color(0xFF5646E8),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}