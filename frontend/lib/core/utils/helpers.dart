import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediswiftmobile/core/constants/colors.dart';
import 'package:mediswiftmobile/views/doctor/dashboard/doctor_dashboard.dart';
import 'package:mediswiftmobile/views/patient/dashboard/patient_dashboard.dart';

class LoginHelper {
  static Future<void> handleLogin({
    required BuildContext context,
    required String emailOrPhone,
    required String password,
    required String expectedUserType, // "patient" or "doctor"
  }) async {
    try {
      // ✅ Load JSON from assets
      final String response = await rootBundle.loadString('assets/user.json');
      final data = jsonDecode(response);

      final List users = data['users'];

      // ✅ Find user by email or phone
      final user = users.firstWhere(
        (u) =>
            (u['email_address'] == emailOrPhone ||
                u['phone_number'] == emailOrPhone) &&
            u['password'] == password,
        orElse: () => null,
      );

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid email/phone or password"),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // ✅ Check user type (restrict login)
      if (user['type_of_user'] != expectedUserType) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Invalid credentials — please login in the correct portal",
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // ✅ Navigate to correct dashboard
      if (expectedUserType == "patient") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorDashboard()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading user data: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
