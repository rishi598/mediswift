import 'package:flutter/material.dart';

class DoctorDashboard extends StatefulWidget {
  final Map doctor;

  const DoctorDashboard({super.key, required this.doctor});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int selectedTab = 0;

  final List<Map<String, dynamic>> appointments = [
    {
      "name": "Sarah Johnson",
      "age": "29 years",
      "date": "Dec 23, 2024 at 2:00 PM",
      "problem":
          "Experiencing chest pain and shortness of breath for the past 2 days. ECG urgent consultation.",
      "type": "Video Consultation",
      "status": "Pending",
      "image": "https://i.pravatar.cc/150?img=32",
    },
    {
      "name": "John Davis",
      "age": "45 years",
      "date": "Dec 23, 2024 at 10:00 AM",
      "problem":
          "Follow-up consultation for hypertension medication adjustment.",
      "type": "Chat Consultation",
      "status": "Pending",
      "image": "https://i.pravatar.cc/150?img=12",
    },
    {
      "name": "Emily Wilson",
      "age": "35 years",
      "date": "Dec 23, 2024 at 4:00 PM",
      "problem":
          "Regular check-up and ECG review, family history of heart disease.",
      "type": "In-Person Visit",
      "status": "Pending",
      "image": "https://i.pravatar.cc/150?img=47",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final doctorName = widget.doctor["doctorName"] ?? "Doctor";

    final specialization = widget.doctor["specialization"] ?? "Cardiologist";

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),

      body: SafeArea(
        child: Column(
          children: [
            // 👨‍⚕️ Top Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: Colors.white,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(
                      "assets/images/default_doctor.png",
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dr. $doctorName",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            fontFamily: 'Poppins',
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          specialization,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.notifications_none,
                    size: 22,
                    color: Colors.black87,
                  ),

                  const SizedBox(width: 14),

                  const Icon(
                    Icons.person_outline,
                    size: 22,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),

            // 📊 Stats Cards
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: "Pending\nCases",
                      count: "5",
                      color: Colors.orange,
                      icon: Icons.access_time,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildStatCard(
                      title: "Completed\nToday",
                      count: "12",
                      color: Colors.green,
                      icon: Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ),

            // 🔘 Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 0;
                        });
                      },
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color:
                              selectedTab == 0
                                  ? const Color(0xFF4169E1)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 10,
                              color:
                                  selectedTab == 0
                                      ? Colors.white
                                      : Colors.black54,
                            ),

                            const SizedBox(width: 6),

                            Text(
                              "Pending",
                              style: TextStyle(
                                color:
                                    selectedTab == 0
                                        ? Colors.white
                                        : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 1;
                        });
                      },
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color:
                              selectedTab == 1
                                  ? const Color(0xFF4169E1)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color:
                                  selectedTab == 1
                                      ? Colors.white
                                      : Colors.black54,
                            ),

                            const SizedBox(width: 6),

                            Text(
                              "Completed",
                              style: TextStyle(
                                color:
                                    selectedTab == 1
                                        ? Colors.white
                                        : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 📋 Appointment List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final item = appointments[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        // 👤 Patient Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(item["image"]),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item["name"],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          "Pending",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    item["age"],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 13,
                                        color: Colors.blueGrey,
                                      ),

                                      const SizedBox(width: 4),

                                      Expanded(
                                        child: Text(
                                          item["date"],
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 13,
                                        color: Colors.blueGrey,
                                      ),

                                      const SizedBox(width: 4),

                                      Text(
                                        item["type"],
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // 📝 Problem
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item["problem"],
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: Colors.grey.shade700,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 📄 Report Link
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "📎 Report Attached\nView Blood Pressure Report",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ✅ Buttons
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Accept",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF14B866),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: SizedBox(
                                height: 38,
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Deny",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE53935),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 Stat Card
  Widget _buildStatCard({
    required String title,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontFamily: 'Inter',
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ],
      ),
    );
  }
}
