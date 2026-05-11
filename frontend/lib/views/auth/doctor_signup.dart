import 'package:flutter/material.dart';
import 'package:mediswiftmobile/views/doctor/dashboard/doctor_dashboard.dart';
import 'package:mediswiftmobile/views/auth/doctor_login.dart';
import 'package:mediswiftmobile/views/auth/patient_login.dart';

class DoctorSignupPage extends StatefulWidget {
  const DoctorSignupPage({super.key});

  @override
  State<DoctorSignupPage> createState() => _DoctorSignupPageState();
}

class _DoctorSignupPageState extends State<DoctorSignupPage> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? selectedSpecialization;

  final List<String> specializations = [
    "Cardiology",
    "Neurology",
    "Orthopedics",
    "Dermatology",
    "Pulmonology",
    "Pediatrics",
    "General Medicine",
  ];

  // 🚀 Signup Function
  Future<void> _signupDoctor() async {
    final name = _nameController.text.trim();

    final email = _emailController.text.trim();

    final phone = _phoneController.text.trim();

    final password = _passwordController.text.trim();

    final confirmPassword = _confirmPasswordController.text.trim();

    // ❌ Empty fields
    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        selectedSpecialization == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    // ❌ Password mismatch
    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    // 👨‍⚕️ Doctor Object
    final doctorData = {
      "doctorName": name,
      "email_address": email,
      "phone_number": phone,
      "password": password,
      "specialization": selectedSpecialization ?? "General Medicine",
      "type_of_user": "doctor",
    };

    // ✅ Navigate to Dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DoctorDashboard(doctor: doctorData)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2ECFF),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          child: Column(
            children: [
              // 👨‍⚕️ Banner
              Container(
                height: 170,
                width: double.infinity,

                margin: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),

                  image: const DecorationImage(
                    image: AssetImage("assets/images/doctor_network.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // 🩺 Heading
              const Text(
                "Join Our Network",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Create your doctor account",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontFamily: 'Inter',
                ),
              ),

              const SizedBox(height: 24),

              // 📦 Signup Card
              Container(
                width: double.infinity,

                margin: const EdgeInsets.symmetric(horizontal: 14),

                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),

                      blurRadius: 18,

                      offset: const Offset(0, 6),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    // 👤 Full Name
                    _buildTextField(
                      controller: _nameController,
                      hint: "Full name",
                    ),

                    const SizedBox(height: 16),

                    // 📧 Email
                    _buildTextField(
                      controller: _emailController,
                      hint: "Email address",
                    ),

                    const SizedBox(height: 16),

                    // 📱 Phone
                    _buildTextField(
                      controller: _phoneController,
                      hint: "Phone number",
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 16),

                    // 🩺 Specialization
                    DropdownButtonFormField<String>(
                      value: selectedSpecialization,

                      decoration: _inputDecoration("Select specialization"),

                      borderRadius: BorderRadius.circular(14),

                      items:
                          specializations.map((specialization) {
                            return DropdownMenuItem(
                              value: specialization,

                              child: Text(
                                specialization,

                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),

                      onChanged: (value) {
                        setState(() {
                          selectedSpecialization = value;
                        });
                      },
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

                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🔒 Confirm Password
                    TextField(
                      controller: _confirmPasswordController,

                      obscureText: _obscureConfirmPassword,

                      decoration: _inputDecoration("Confirm password").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,

                            color: Colors.grey,
                          ),

                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ☑️ Terms
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Checkbox(
                          value: _agreeToTerms,

                          activeColor: const Color(0xFF8E38F5),

                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                        ),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 13),

                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                ),

                                children: [
                                  TextSpan(text: "I agree to the "),

                                  TextSpan(
                                    text: "Terms of Service",

                                    style: TextStyle(
                                      color: Color(0xFF8E38F5),

                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  TextSpan(text: " and "),

                                  TextSpan(
                                    text: "Privacy Policy",

                                    style: TextStyle(
                                      color: Color(0xFF8E38F5),

                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // 🚀 Create Account
                    SizedBox(
                      width: double.infinity,

                      height: 54,

                      child: ElevatedButton(
                        onPressed:
                            _agreeToTerms
                                ? () async {
                                  await _signupDoctor();
                                }
                                : null,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8E38F5),

                          disabledBackgroundColor: Colors.grey.shade300,

                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Poppins',
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

              const SizedBox(height: 22),

              // 🌐 Google Signup
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),

                child: SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: OutlinedButton.icon(
                    onPressed: () {},

                    icon: Image.asset('assets/icons/google.png', height: 22),

                    label: const Text(
                      "Continue with Google",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,

                      side: const BorderSide(
                        color: Color(0xFF8E38F5),
                        width: 1.4,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 👨‍⚕️ Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontFamily: 'Inter',
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 500),

                          pageBuilder:
                              (_, animation, __) => FadeTransition(
                                opacity: animation,

                                child: const DoctorLoginPage(),
                              ),
                        ),
                      );
                    },

                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: Color(0xFF8E38F5),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 🧑‍🤝‍🧑 Patient Login
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),

                      pageBuilder:
                          (_, animation, __) => FadeTransition(
                            opacity: animation,

                            child: const PatientLogin(),
                          ),
                    ),
                  );
                },

                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Icon(Icons.person, size: 17, color: Color(0xFF8E38F5)),

                    SizedBox(width: 6),

                    Text(
                      "Are you a patient?",
                      style: TextStyle(
                        color: Color(0xFF8E38F5),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),
            ],
          ),
        ),
      ),
    );
  }

  // ✨ Reusable TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(hint),
    );
  }

  // 🎨 Input Decoration
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
        fontFamily: 'Inter',
      ),

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(color: Color(0xFF8E38F5), width: 1.5),
      ),
    );
  }
}
