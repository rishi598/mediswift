import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      // 🔹 Load users
      final String userResponse = await rootBundle.loadString(
        'assets/user.json',
      );
      final Map<String, dynamic> userData = jsonDecode(userResponse);
      final List users = userData['users'];

      // 🔹 Find matching user
      final user = users.firstWhere(
        (u) =>
            (u['email_address'] == emailOrPhone ||
                u['phone_number'] == emailOrPhone) &&
            u['password'] == password,
        orElse: () => null,
      );

      if (user == null) {
        _showError(context, "Invalid email/phone or password");
        return;
      }

      if (user['type_of_user'] != expectedUserType) {
        _showError(
          context,
          "Invalid credentials — please login in the correct portal",
        );
        return;
      }

      // 🔹 PATIENT LOGIN
      if (expectedUserType == "patient") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientDashboard()),
        );
        return;
      }

      // 🔹 DOCTOR LOGIN → load doctor.json
      final String doctorResponse = await rootBundle.loadString(
        'assets/doctor.json',
      );
      final List doctors = jsonDecode(doctorResponse);

      final loggedInDoctor = doctors.firstWhere(
        (d) => d['email'] == user['email_address'],
        orElse: () => null,
      );

      if (loggedInDoctor == null) {
        _showError(context, "Doctor profile not found");
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorDashboard(doctor: loggedInDoctor),
        ),
      );
    } catch (e) {
      _showError(context, "Login error: $e");
    }
  }

  static void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }
}
