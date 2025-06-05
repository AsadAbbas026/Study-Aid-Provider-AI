import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:study_buddy/Controller/opt_controller.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller instance
    final OTPController controller = Get.put(OTPController());

    return SafeArea(
      child: Scaffold(
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
                // App Logo
                Image.asset(
                  'assets/images/applogo.png', // Replace with your logo path
                  width: 250.w,
                  height: 250.h,
                ),
                const SizedBox(height: 20),
                // "Enter OTP" text
                const Text(
                  "Enter OTP",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
                // OTP Text Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _otpTextField(
                      controller: controller.controller1,
                      focusNode: controller.focusNode1,
                      nextFocusNode: controller.focusNode2,
                    ),
                    const SizedBox(width: 10),
                    _otpTextField(
                      controller: controller.controller2,
                      focusNode: controller.focusNode2,
                      nextFocusNode: controller.focusNode3,
                    ),
                    const SizedBox(width: 10),
                    _otpTextField(
                      controller: controller.controller3,
                      focusNode: controller.focusNode3,
                      nextFocusNode: controller.focusNode4,
                    ),
                    const SizedBox(width: 10),
                    _otpTextField(
                      controller: controller.controller4,
                      focusNode: controller.focusNode4,
                      nextFocusNode:
                          controller.focusNode1, // No next focus here
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Submit Button
                ElevatedButton(
                    onPressed: () {
                    final email = Get.arguments['email'].toString(); // Retrieve email from arguments
                    print("Email from arguments: $email");
                    controller.validateOTP(
                      email,
                      controller.controller1,
                      controller.controller2,
                      controller.controller3,
                      controller.controller4,
                    );
                    },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor: const Color.fromARGB(1, 138, 77, 233),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget for OTP TextField
  Widget _otpTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required FocusNode nextFocusNode,
  }) {
    return Container(
      color: Colors.white,
      width: 60.w,
      height: 60.h,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.phone,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        onChanged: (value) => Get.find<OTPController>()
            .onChanged(value, focusNode, nextFocusNode),
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0.r),
            borderSide: const BorderSide(color: Colors.black, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0.r),
            borderSide: const BorderSide(color: Colors.green, width: 2.0),
          ),
        ),
      ),
    );
  }
}
