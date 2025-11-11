import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    // Navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      checkLoginStatus();
    });
  }

  void checkLoginStatus() {
    final box = GetStorage();
    final isLoggedIn = box.read('isLoggedIn') ?? false;
    final loginTime = box.read('loginTime');

    if (isLoggedIn && loginTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final oneHour = 60 * 60 * 1000; // in milliseconds

      if (now - loginTime < oneHour) {
        // Session still valid
        Get.offAllNamed('/');
        return;
      } else {
        // Session expired, log the user out
        box.write('isLoggedIn', false);
        box.remove('loginTime');
        Get.offAllNamed('/login');
      }
    } else {
      // Not logged in or no session
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3EA),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text(
                'welcome'.tr,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/logo.jpg',
                width: 100,
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
