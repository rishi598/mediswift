import 'package:flutter/material.dart';
import 'package:mediswiftmobile/core/constants/colors.dart';
import 'package:mediswiftmobile/views/auth/patient_login.dart';
import 'package:mediswiftmobile/views/auth/forgot_password.dart';

class PatientProfile extends StatefulWidget {
  const PatientProfile({super.key});

  @override
  State<PatientProfile> createState() => _PatientProfileState();
}

class _PatientProfileState extends State<PatientProfile> {
  bool _isTwoFactorEnabled = false;
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile Settings",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primaryGreen,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.settings_outlined, color: Colors.grey),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // 👤 Profile Info
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(
                          'assets/images/profile_avatar.jpg',
                        ),
                      ),
                    ),
                    Positioned(
                      top: 60,
                      left: 90,
                      child: InkWell(
                        onTap: () {
                          // TODO: Implement image picker logic
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(1, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    // const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(top: 88.0),
                      child: const Text(
                        "Sarah Johnson",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📝 Personal Info
            _buildSectionTitle("Personal Information"),
            _buildEditableField("Full Name", "Sarah Johnson"),
            _buildEditableField("Email Address", "sarah.johnson@email.com"),
            _buildEditableField("Phone Number", "+1 (555) 123-4567"),
            _buildEditableField("Address", "123 Main Street, NY, USA"),

            const SizedBox(height: 20),

            // 🔒 Security & Privacy
            _buildSectionTitle("Security & Privacy"),
            _buildSettingTile(
              icon: Icons.lock_outline,
              title: "Change Password",
              subtitle: "Update your password",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ForgotPassword()),
                );
              },
            ),
            _buildToggleTile(
              icon: Icons.verified_user_outlined,
              title: "Two-Factor Authentication",
              subtitle: "Add extra security to your account",
              value: _isTwoFactorEnabled,
              onChanged: (val) {
                setState(() {
                  _isTwoFactorEnabled = val;
                });
              },
            ),

            const SizedBox(height: 20),

            // ⚙️ App Settings
            _buildSectionTitle("App Settings"),
            _buildToggleTile(
              icon: Icons.dark_mode_outlined,
              title: "Dark Mode",
              subtitle: "Switch to dark theme",
              value: _isDarkMode,
              onChanged: (val) {
                setState(() {
                  _isDarkMode = val;
                });
              },
            ),
            _buildSettingTile(
              icon: Icons.logout,
              title: "Logout",
              subtitle: "Sign out of your account",
              color: Colors.redAccent,
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const PatientLogin()),
                  (route) => false,
                );
              },
            ),

            const SizedBox(height: 24),

            // Save Changes Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Profile updated successfully!"),
                      backgroundColor: AppColors.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Save Changes",
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
    );
  }

  // 🔹 Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // 🔹 Editable Text Field Tile
  Widget _buildEditableField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.edit_outlined,
            color: AppColors.primaryGreen,
            size: 20,
          ),
        ],
      ),
    );
  }

  // 🔹 Setting Tile
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primaryGreen),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Inter',
          color: Colors.grey,
          fontSize: 13,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  // 🔹 Toggle Tile
  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primaryGreen),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Inter',
          color: Colors.grey,
          fontSize: 13,
        ),
      ),
      value: value,
      activeThumbColor: AppColors.primaryGreen,
      onChanged: onChanged,
    );
  }
}
