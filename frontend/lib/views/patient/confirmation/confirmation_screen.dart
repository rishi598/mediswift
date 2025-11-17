import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediswiftmobile/core/constants/colors.dart';

class ConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> appointmentData;
  const ConfirmationScreen({super.key, required this.appointmentData});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_bottom_rounded;
    }
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return "Your appointment has been confirmed by the doctor.";
      case 'rejected':
        return "Unfortunately, your appointment request was declined.";
      default:
        return "Your appointment request has been sent.\nPlease wait for doctor confirmation.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = appointmentData['doctorName'] ?? "Doctor";
    final specialization =
        appointmentData['specialization'] ?? "Specialization";
    final date = appointmentData['selectedDate'] ?? "";
    final time = appointmentData['selectedTime'] ?? "";
    final payment = appointmentData['modeOfPayment'] ?? "N/A";
    final status = appointmentData['status'] ?? "pending";

    final formattedDate = DateFormat(
      'MMM d, yyyy',
    ).format(DateTime.parse(date));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Appointment Confirmation",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // ✅ Success or Pending Icon
            Icon(
              _getStatusIcon(status),
              size: 80,
              color: _getStatusColor(status),
            ),
            const SizedBox(height: 20),

            Text(
              _getStatusMessage(status),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            // 🧾 Appointment Receipt Style Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow("Doctor", doctorName),
                  _infoRow("Specialization", specialization),
                  _infoRow("Date", formattedDate),
                  _infoRow("Time", time),
                  _infoRow("Payment", payment),
                  const Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Status",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),
            // 🎯 Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Go to Home",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to "My Appointments"
                  },
                  child: const Text(
                    "View My Appointments",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
