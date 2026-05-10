import 'package:flutter/material.dart';
import 'package:mediswiftmobile/core/constants/colors.dart';
import 'package:mediswiftmobile/views/auth/doctor_login.dart';
import 'package:mediswiftmobile/views/patient/dashboard/patient_dashboard.dart';

class PatientSignup extends StatefulWidget {
  const PatientSignup({super.key});

  @override
  State<PatientSignup> createState() => _PatientSignupState();
}

class _PatientSignupState extends State<PatientSignup> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🧑‍⚕️ Illustration
                Image.asset('assets/images/doctor_community.png', height: 160),
                const SizedBox(height: 20),

                // 💚 Title
                const Text(
                  'Join Our Community',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Create your patient account today',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 28),

                // 🧾 Signup Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 📞 Phone Number
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration(
                          "Phone number (10 digits)",
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 📧 Email
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration("Email address"),
                      ),
                      const SizedBox(height: 16),

                      // 🔒 Password
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration("Password").copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed:
                                () => setState(() {
                                  _obscurePassword = !_obscurePassword;
                                }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔒 Confirm Password
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: _inputDecoration(
                          "Confirm password",
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed:
                                () => setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ☑️ Terms Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            activeColor: AppColors.primaryGreen,
                            value: _agreeToTerms,
                            onChanged: (val) {
                              setState(() {
                                _agreeToTerms = val ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Wrap(
                              children: [
                                const Text(
                                  "I agree to the ",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "Terms of Service",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Text(
                                  " and ",
                                  style: TextStyle(fontSize: 13),
                                ),
                                Text(
                                  "Privacy Policy",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ✅ Create Account Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              _agreeToTerms
                                  ? () {
                                    // TODO: Signup logic
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => const PatientDashboard(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: Colors.grey.shade300,
                          ),
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // 🔘 OR Divider
                Row(
                  children: const [
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 0.6,
                        endIndent: 10,
                      ),
                    ),
                    Text(
                      "OR",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 0.6,
                        indent: 10,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🟢 Google Sign-Up Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Integrate Google Sign-Up logic
                    },
                    icon: Image.asset('assets/icons/google.png', height: 22),
                    label: const Text(
                      "Sign up with Google",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.primaryGreen.withOpacity(0.8),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 🔗 Bottom Links
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                              milliseconds: 600,
                            ),
                            pageBuilder: (_, animation, __) {
                              return FadeTransition(
                                opacity: animation,
                                child:  DoctorLoginPage(),
                              );
                            },
                          ),
                        );
                      },
                      child: Text(
                        "Are you a doctor?",
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Back to login
                      },
                      child: Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
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

  // 🧩 Input Decoration
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'Inter', color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFFF8F9FB),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      hoverColor: AppColors.primaryGreen.withOpacity(0.05),
    );
  }
}
