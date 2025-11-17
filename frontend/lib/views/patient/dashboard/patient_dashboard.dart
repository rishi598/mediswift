import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediswiftmobile/core/constants/colors.dart';
import 'package:mediswiftmobile/views/patient/dashboard/doctor_tile.dart';
import 'package:mediswiftmobile/views/patient/profile/patient_profile.dart';
import 'package:mediswiftmobile/widgets/bottom_nav_bar.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  DateTime? lastPressedTime;

  Future<void> _handleExit() async {
    // first try graceful exit, else hard exit
    try {
      await SystemNavigator.pop();
    } catch (_) {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> systems = [
      {
        "icon": "assets/icons/ic_heart.png",
        "title": "Cardiology",
        "subtitle": "Heart & Blood",
        "color": Colors.redAccent.shade100,
      },
      {
        "icon": "assets/icons/ic_heart.png",
        "title": "Neurology",
        "subtitle": "Brain & Nerves",
        "color": Colors.deepPurpleAccent.shade100,
      },
      {
        "icon": "assets/icons/ic_heart.png",
        "title": "Orthopedics",
        "subtitle": "Bones & Joints",
        "color": Colors.orangeAccent.shade100,
      },
      {
        "icon": "assets/icons/ic_heart.png",
        "title": "Ophthalmology",
        "subtitle": "Eyes & Vision",
        "color": Colors.lightBlueAccent.shade100,
      },
      {
        "icon": "assets/icons/ic_heart.png",
        "title": "Pulmonology",
        "subtitle": "Lungs & Breathing",
        "color": Colors.greenAccent.shade100,
      },
      {
        "icon": "assets/icons/ic_heart.png",
        "title": "Dermatology",
        "subtitle": "Skin & Hair",
        "color": Colors.pinkAccent.shade100,
      },
      {
        "icon": "assets/icons/ic_heart.png",
        "title": "Gastroenterology",
        "subtitle": "Stomach & Digestion",
        "color": Colors.amberAccent.shade100,
      },
      {
        "icon": "assets/icons/ic_heart.png",
        "title": "Pediatrics",
        "subtitle": "Children’s Health",
        "color": Colors.indigoAccent.shade100,
      },
      {
        "icon": "assets/icons/ic_heart.png",
        "title": "General Medicine",
        "subtitle": "General Practice",
        "color": Colors.indigoAccent.shade100,
      },
    ];

    return PopScope(
      canPop: false, // prevent automatic pop
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // if already popped by system, do nothing

        final now = DateTime.now();
        final isSecondPress =
            lastPressedTime != null &&
            now.difference(lastPressedTime!) <= const Duration(seconds: 2);

        if (!isSecondPress) {
          lastPressedTime = now;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Press back again to exit"),
                backgroundColor: AppColors.primaryGreen,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          await _handleExit();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF7EB),
        bottomNavigationBar: const BottomNavBar(currentIndex: 0),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false, // remove back arrow
          title: const Text(
            "Select by Body System",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.account_circle,
                color: AppColors.primaryGreen,
                size: 28,
              ),
              onPressed: () {
                // TODO: Navigate to patient profile page
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 600),
                    pageBuilder:
                        (_, animation, __) => FadeTransition(
                          opacity: animation,
                          child: const PatientProfile(),
                        ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemCount: systems.length,
            itemBuilder: (context, index) {
              final item = systems[index];
              return GestureDetector(
                onTap: () {
                  // TODO: Navigate to doctor list
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 600),
                      pageBuilder:
                          (_, animation, __) => FadeTransition(
                            opacity: animation,
                            child: DoctorTileScreen(
                              specialization:
                                  item['title'], // pass specialization name
                            ),
                          ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        item['icon'],
                        width: 36,
                        height: 36,
                        color: AppColors.primaryGreen, // to match your theme
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['title'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        item['subtitle'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'Inter',
                        ),
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
}
