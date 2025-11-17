import 'package:flutter/material.dart';
import 'package:get/get.dart';
// optional if you want to use your colors
// import 'package:mediswiftmobile/views/auth/patient_login.dart';
import 'package:mediswiftmobile/views/common/SplashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // theme: ThemeData(fontFamily: AppFonts.nunito),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
