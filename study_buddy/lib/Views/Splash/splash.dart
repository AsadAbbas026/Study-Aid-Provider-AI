import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:study_buddy/Routes/app_routes.dart'; // Import GetX for navigation

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double progress = 0.0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(
        seconds: 3,
      ), // Duration for the splash screen animation
      vsync: this,
    )..forward(); // Start the animation immediately

    // Define the fade and scale animations
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween(begin: 0.5, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Timer to update the progress every 250ms
    Timer.periodic(const Duration(milliseconds: 250), (timer) {
      setState(() {
        if (progress < 1.0) {
          progress +=
              0.1; // Increase progress every 250ms (total duration = 10 seconds)
        } else {
          timer.cancel(); // Stop the timer when progress reaches 1
          // Navigate to LoginScreen after 10 seconds
          Get.offNamed(AppRoutes.loginSignupScreen);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 171, 71, 188),
              Color.fromARGB(255, 252, 228, 236),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo with fade and zoom effect
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    'assets/images/applogo.png', // Replace with your logo path
                    width: 250.w,
                    height: 250.h,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Your Pocket Tutor",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20.h),
              // Linear Progress Indicator with Black Border and Green Inside
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // Black border color
                      width: 3.0.w, // Border width
                    ),
                    borderRadius: BorderRadius.circular(8.0.r),
                  ),
                  child: LinearProgressIndicator(
                    value: progress, // Progress value from 0.0 to 1.0
                    backgroundColor:
                        Colors.transparent, // Make background transparent
                    color: Colors.green, // Green completion bar color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
