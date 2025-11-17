import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediswiftmobile/core/constants/colors.dart';
import 'package:mediswiftmobile/views/patient/dashboard/appointment_page.dart';
import 'package:mediswiftmobile/widgets/bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class DoctorTileScreen extends StatefulWidget {
  final String specialization;
  const DoctorTileScreen({super.key, required this.specialization});

  @override
  State<DoctorTileScreen> createState() => _DoctorTileScreenState();
}

class _DoctorTileScreenState extends State<DoctorTileScreen> {
  List<dynamic> _doctors = [];
  List<dynamic> _favorites = [];
  bool _showFavorites = false;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    final String response = await rootBundle.loadString('assets/doctor.json');
    final data = json.decode(response);

    setState(() {
      _doctors =
          data
              .where(
                (doc) =>
                    doc['specialization'].toString().toLowerCase() ==
                    widget.specialization.toLowerCase(),
              )
              .toList();

      // 🔹 Sort doctors by recommendationCount (descending)
      _doctors.sort(
        (a, b) =>
            (b['recommendationCount']).compareTo(a['recommendationCount']),
      );
    });
  }

  void _toggleFavorite(Map<String, dynamic> doctor) {
    setState(() {
      if (_favorites.contains(doctor)) {
        _favorites.remove(doctor);
      } else {
        _favorites.add(doctor);
      }
    });
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
        title: Row(
          children: [
            Image.asset(
              'assets/icons/ic_heart.png',
              height: 24,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(width: 8),
            Text(
              widget.specialization,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // TODO: Search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Toggle Tabs
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
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showFavorites = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            !_showFavorites
                                ? AppColors.primaryGreen
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          "All",
                          style: TextStyle(
                            color:
                                !_showFavorites ? Colors.white : Colors.black87,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showFavorites = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            _showFavorites
                                ? AppColors.primaryGreen
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          "Favorites",
                          style: TextStyle(
                            color:
                                _showFavorites ? Colors.white : Colors.black87,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Doctors List
          Expanded(
            child:
                displayedDoctors.isEmpty
                    ? Center(
                      child: Text(
                        _showFavorites
                            ? "You have no favorites yet"
                            : "No doctors available",
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    )
                    : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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

  Widget _buildDoctorCard(
    Map<String, dynamic> doctor,
    bool isFavorite,
    int index,
  ) {
    bool isTopDoctor = index == 0 || doctor['recommendationCount'] > 120;

    // ---------------------------------------------
    // 🔍 CHECK IF DOCTOR IS ON LEAVE TODAY
    // ---------------------------------------------
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Parse offDays list from doctor.json
    final List offDayRanges = doctor['offDays'] ?? [];

    bool isDoctorOnLeaveToday = false;

    for (final range in offDayRanges) {
      try {
        final String fromStr = range['from'];
        final String toStr = range['to'];

        // Parse ISO or dd-MM-yyyy formats
        final from =
            DateTime.tryParse(fromStr) ??
            DateFormat('dd-MM-yyyy').parse(fromStr);
        final to =
            DateTime.tryParse(toStr) ?? DateFormat('dd-MM-yyyy').parse(toStr);

        // Check if today's date falls inside the range
        if (!todayOnly.isBefore(from) && !todayOnly.isAfter(to)) {
          isDoctorOnLeaveToday = true;
          break;
        }
      } catch (_) {}
    }

    return GestureDetector(
      onTap:
          isDoctorOnLeaveToday
              ? null
              : () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder:
                        (_, animation, __) => FadeTransition(
                          opacity: animation,
                          child: AppointmentPage(doctor: doctor),
                        ),
                  ),
                );
              },
      child: Opacity(
        opacity: isDoctorOnLeaveToday ? 0.5 : 1.0,
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
              // Doctor Image
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset(
                  doctor["image"] ?? 'assets/images/default_doctor.png',
                  width: 55,
                  height: 55,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),

              // Doctor Info
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
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        // 🔴 On Leave Tag
                        if (isDoctorOnLeaveToday)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "On Leave",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor['specialization'],
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Consultation Fee: ₹${doctor['cost'] ?? 'N/A'}",
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "${doctor['starCount'] ?? 4.5}",
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ❤️ Favorite Button
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
