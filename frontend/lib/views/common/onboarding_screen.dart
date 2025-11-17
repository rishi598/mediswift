// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mediswiftmobile/core/constants/colors.dart';
// import '../auth/patient_login.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int _currentIndex = 0;

//   final List<_OnboardPageData> _pages = [
//     _OnboardPageData(
//       title: 'Book Appointments Easily',
//       description:
//           'Find specialists instantly and schedule visits with just a few taps.',
//       image: 'assets/images/onboard_appointments.png',
//     ),
//     _OnboardPageData(
//       title: 'Consult Doctors Online',
//       description:
//           'Chat or video-call with certified doctors anytime, anywhere.',
//       image: 'assets/images/onboard_consult.png',
//     ),
//     _OnboardPageData(
//       title: 'Get 24/7 Emergency Support',
//       description:
//           'Reach medical professionals instantly for urgent care needs.',
//       image: 'assets/images/onboard_support.png',
//     ),
//   ];

//   void _finishOnboarding() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isOnboarded', true);
//     if (!mounted) return;
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const PatientLogin()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: PageView.builder(
//                 controller: _pageController,
//                 itemCount: _pages.length,
//                 onPageChanged: (index) => setState(() => _currentIndex = index),
//                 itemBuilder: (_, index) {
//                   final page = _pages[index];
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Image.asset(page.image, height: 280),
//                         const SizedBox(height: 40),
//                         Text(
//                           page.title,
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                             fontFamily: 'Poppins',
//                             fontSize: 24,
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.primaryGreen,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           page.description,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontFamily: 'Inter',
//                             fontSize: 14,
//                             color: Colors.grey.shade700,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//             _buildIndicator(),
//             const SizedBox(height: 32),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//               child: ElevatedButton(
//                 onPressed: _finishOnboarding,
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 54),
//                   backgroundColor: AppColors.primaryGreen,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   _currentIndex == _pages.length - 1 ? 'Get Started' : 'Next',
//                   style: const TextStyle(
//                     fontFamily: 'Poppins',
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextButton(
//               onPressed: _finishOnboarding,
//               child: const Text(
//                 'Skip',
//                 style: TextStyle(
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w500,
//                   fontFamily: 'Inter',
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildIndicator() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(_pages.length, (index) {
//         bool active = index == _currentIndex;
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           margin: const EdgeInsets.symmetric(horizontal: 4),
//           height: 8,
//           width: active ? 20 : 8,
//           decoration: BoxDecoration(
//             color: active ? AppColors.primaryGreen : Colors.grey.shade300,
//             borderRadius: BorderRadius.circular(8),
//           ),
//         );
//       }),
//     );
//   }
// }

// class _OnboardPageData {
//   final String title;
//   final String description;
//   final String image;
//   _OnboardPageData({
//     required this.title,
//     required this.description,
//     required this.image,
//   });
// }
