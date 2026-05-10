import 'package:flutter/material.dart';
import 'package:mediswiftmobile/core/constants/colors.dart';

class DoctorDashboard extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const DoctorDashboard({super.key, required this.doctor});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Doctor Dashboard",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👨‍⚕️ Doctor Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage(
                      'assets/images/default_doctor.png',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor['doctorName'] ?? 'Doctor',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor['specialization'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          doctor['clinicName'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📊 Stats Row
            Row(
              children: [
                _statCard(
                  title: "Rating",
                  value: "${doctor['starCount'] ?? 0}",
                  icon: Icons.star,
                  color: Colors.amber,
                ),
                const SizedBox(width: 12),
                _statCard(
                  title: "Recommended",
                  value: "${doctor['recommendationCount'] ?? 0}",
                  icon: Icons.thumb_up,
                  color: AppColors.primaryGreen,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 📅 Actions
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            _actionTile(
              icon: Icons.event_available,
              title: "Today's Appointments",
              subtitle: "View & manage today’s bookings",
              onTap: () {
                // TODO: Navigate to Doctor Appointments Page
              },
            ),

            _actionTile(
              icon: Icons.calendar_month,
              title: "Manage Availability",
              subtitle: "Set working days & time slots",
              onTap: () {
                // TODO: Availability management screen
              },
            ),

            _actionTile(
              icon: Icons.beach_access,
              title: "Mark Leave",
              subtitle: "Add off days or leave ranges",
              onTap: () {
                // TODO: Leave management screen
              },
            ),

            _actionTile(
              icon: Icons.logout,
              title: "Logout",
              subtitle: "Sign out from doctor account",
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 📊 Small Stat Card
  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Action Tile
  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: AppColors.primaryGreen),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
