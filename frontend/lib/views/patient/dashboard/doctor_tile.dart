import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mediswiftmobile/core/constants/colors.dart';
import 'package:mediswiftmobile/views/patient/dashboard/appointment_page.dart';
import 'package:mediswiftmobile/widgets/bottom_nav_bar.dart';

class DoctorTileScreen extends StatefulWidget {
  final String specialization;
  const DoctorTileScreen({super.key, required this.specialization});

  @override
  State<DoctorTileScreen> createState() => _DoctorTileScreenState();
}

class _DoctorTileScreenState extends State<DoctorTileScreen> {
  List<dynamic> _doctors = [];
  final List<dynamic> _favorites = [];
  bool _showFavorites = false;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    final String response = await rootBundle.loadString('assets/doctor.json');
    final List<dynamic> data = json.decode(response);

    final filtered =
        data.where((doc) {
          return doc['specialization'].toString().toLowerCase() ==
              widget.specialization.toLowerCase();
        }).toList();

    filtered.sort(
      (a, b) => (b['recommendationCount'] ?? 0).compareTo(
        a['recommendationCount'] ?? 0,
      ),
    );

    setState(() {
      _doctors = filtered;
    });
  }

  void _toggleFavorite(Map<String, dynamic> doctor) {
    setState(() {
      _favorites.contains(doctor)
          ? _favorites.remove(doctor)
          : _favorites.add(doctor);
    });
  }

  // 🔐 CORE FIX — determine if doctor has ANY future valid date
  bool _doctorHasAnyFutureDate(Map<String, dynamic> doctor) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final List<String> availableDays =
        (doctor['availableDays'] ?? [])
            .map<String>((d) => d.toString().toLowerCase())
            .toList();

    final List offDayRanges = doctor['offDays'] ?? [];

    // Check next 14 calendar days
    for (int i = 0; i < 14; i++) {
      final DateTime date = today.add(Duration(days: i));
      final String weekday = DateFormat('EEEE').format(date).toLowerCase();

      // ❌ not working day
      if (!availableDays.contains(weekday)) continue;

      // ❌ check leave ranges
      bool isOnLeave = false;
      for (final range in offDayRanges) {
        try {
          final from =
              DateTime.tryParse(range['from']) ??
              DateFormat('dd-MM-yyyy').parse(range['from']);
          final to =
              DateTime.tryParse(range['to']) ??
              DateFormat('dd-MM-yyyy').parse(range['to']);

          if (!date.isBefore(from) && !date.isAfter(to)) {
            isOnLeave = true;
            break;
          }
        } catch (_) {}
      }

      // ✅ found at least one valid future date
      if (!isOnLeave) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final displayedDoctors = _showFavorites ? _favorites : _doctors;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.specialization,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          // Toggle Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTab("All", !_showFavorites, () {
                  setState(() => _showFavorites = false);
                }),
                _buildTab("Favorites", _showFavorites, () {
                  setState(() => _showFavorites = true);
                }),
              ],
            ),
          ),

          // Doctor List
          Expanded(
            child:
                displayedDoctors.isEmpty
                    ? const Center(
                      child: Text(
                        "No doctors available",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: displayedDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = displayedDoctors[index];
                        final isFavorite = _favorites.contains(doctor);
                        return _buildDoctorCard(doctor, isFavorite, index);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(
    Map<String, dynamic> doctor,
    bool isFavorite,
    int index,
  ) {
    final bool hasFutureDate = _doctorHasAnyFutureDate(doctor);

    return GestureDetector(
      onTap:
          hasFutureDate
              ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AppointmentPage(doctor: doctor),
                  ),
                );
              }
              : null,
      child: Opacity(
        opacity: hasFutureDate ? 1.0 : 0.45,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage(
                  doctor['image'] ?? 'assets/images/default_doctor.png',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Dr. ${doctor['doctorName']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (!hasFutureDate)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "No Slots Available",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor['specialization'],
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Consultation Fee: ₹${doctor['cost']}",
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.redAccent,
                ),
                onPressed: () => _toggleFavorite(doctor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
