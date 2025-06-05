import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:study_buddy/Controller/loginSignup_controller.dart';
import 'package:study_buddy/widgets/custom_buttons.dart';

class LoginSignupScreen extends StatelessWidget {
  final LoginsignupController controller = Get.find<LoginsignupController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 171, 71, 188),
              Color.fromARGB(255, 252, 228, 236),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // App Logo
            Image.asset(
              "assets/images/applogo.png",
              width: 200.w,
              height: 200.h,
              key: Key('appLogo'), // Key added for testing
            ),
            const Text(
              "Your Pocket Tutor",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              key: Key('appTagline'), // Key added for testing
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google Sign-In Button
                CustomButton (
                  imagePath: "assets/images/google.jpeg",
                  text: "Continue With Google",
                  onPressed: controller.signInWithGoogle,
                  key: Key('googleSignInButton'), // Key added for testing
                ),
                const SizedBox(width: 20),
                // Facebook Sign-In Button
                CustomButton(
                  imagePath: "assets/images/facebook.png",
                  text: "Continue With Facebook",
                  onPressed: controller.signInWithFacebook,
                  key: Key('facebookSignInButton'), // Key added for testing
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Sign Up Button
            ElevatedButton(
              onPressed: controller.signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                child: Text("Sign up", style: TextStyle(color: Colors.white)),
              ),
              key: Key('signupButton'), // Key added for testing
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("You Already have an Account? "),
                GestureDetector(
                  onTap: controller.login,
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.blue),
                    key: Key('loginLink'), // Key added for testing
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Terms of Service and Privacy Policy
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text("Terms of Service | Privacy Policy"),
            ),
          ],
        ),
      ),
    );
  }
}
