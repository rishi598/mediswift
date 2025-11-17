import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mediswiftmobile/core/constants/colors.dart';
import 'package:mediswiftmobile/widgets/bottom_nav_bar.dart';

class PatientAppointmentPage extends StatefulWidget {
  const PatientAppointmentPage({super.key});

  @override
  State<PatientAppointmentPage> createState() => _PatientAppointmentPageState();
}

class _PatientAppointmentPageState extends State<PatientAppointmentPage> {
  List<dynamic> appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      // Load appointment data from local file
      final String response = await rootBundle.loadString(
        'assets/appointment.json',
      );
      final List<dynamic> data = json.decode(response);

      // 🧩 Get the first patient's email dynamically from appointment.json
      // (Later this will be replaced with logged-in user's email from backend)
      const simulatedLoggedInEmail = "sneha.rishi@gmail.com";

      final loggedInEmail = simulatedLoggedInEmail.toLowerCase();

      if (loggedInEmail == null) {
        debugPrint("⚠️ No patient email found in appointment.json");
        return;
      }

      // 🔍 Filter appointments matching that email
      final filteredAppointments =
          data.where((appointment) {
            final patientEmail =
                appointment['patientEmail']?.toString().toLowerCase();
            return patientEmail == loggedInEmail;
          }).toList();

      // 🧾 Update state
      setState(() {
        appointments = filteredAppointments;
      });

      debugPrint(
        "✅ Loaded ${filteredAppointments.length} appointments for $loggedInEmail",
      );
    } catch (e) {
      debugPrint("❌ Error loading appointments: $e");
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.redAccent;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.hourglass_bottom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "My Appointments",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),

      body: SafeArea(
        child:
            appointments.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.grey,
                        size: 70,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "You have no active appointments",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Book your first appointment to get started!",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.only(
                    bottom: 70,
                  ), // 👈 space for bottom bar
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final ap = appointments[index];

                      // ✅ Safe date parsing (handles both String & Map formats)
                      final dateStr = ap['selectedDate'];
                      String formattedDate = '';

                      if (dateStr is String) {
                        // Normal case (already a String like "2025-11-11")
                        try {
                          formattedDate = DateFormat(
                            'MMM d, yyyy',
                          ).format(DateTime.parse(dateStr));
                        } catch (_) {
                          formattedDate = dateStr;
                        }
                      } else if (dateStr is Map) {
                        // Firebase-like or nested date map
                        final seconds = dateStr['seconds'];
                        if (seconds != null) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            seconds * 1000,
                          );
                          formattedDate = DateFormat(
                            'MMM d, yyyy',
                          ).format(date);
                        } else if (dateStr['date'] != null) {
                          formattedDate = dateStr['date'];
                        }
                      } else {
                        formattedDate = 'Unknown Date';
                      }

                      // 🕓 Time
                      final time = ap['selectedTime'] ?? 'N/A';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ap['doctorName'] ?? 'Unknown Doctor',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "$formattedDate • $time",
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _statusButton(
                                ap['status'] ?? 'pending',
                                ap['status'] == 'accepted'
                                    ? Colors.green
                                    : ap['status'] == 'rejected'
                                    ? Colors.red
                                    : Colors.orange,
                                ap['status'] == 'accepted'
                                    ? Icons.check_circle_outline
                                    : ap['status'] == 'rejected'
                                    ? Icons.cancel_outlined
                                    : Icons.hourglass_bottom,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Column(
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
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _statusButton(String text, Color color, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16, color: color),
      label: Text(text, style: TextStyle(fontFamily: 'Inter', color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
