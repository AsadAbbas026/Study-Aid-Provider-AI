import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:study_buddy/Views/Login/login_screen.dart';
import 'package:study_buddy/Utils/config.dart';

class OTPController extends GetxController {
  // Controllers for OTP fields
  final TextEditingController controller1 = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  final TextEditingController controller3 = TextEditingController();
  final TextEditingController controller4 = TextEditingController();

  // Focus nodes
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  final FocusNode focusNode3 = FocusNode();
  final FocusNode focusNode4 = FocusNode();

  @override
  void onClose() {
    // Dispose the focus nodes to avoid memory leaks
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();
    super.onClose();
  }

  // Function to move to the next focus node when a digit is entered
  void onChanged(String value, FocusNode currentFocus, FocusNode nextFocus) {
    if (value.length == 1) {
      FocusScope.of(Get.context!).requestFocus(nextFocus);
    }
  }

  // Validate the OTP fields when Submit is pressed
  void validateOTP(String email, TextEditingController controller1, TextEditingController controller2, TextEditingController controller3, TextEditingController controller4) async {
    // Combine OTP digits from the controllers
    String otp = controller1.text + controller2.text + controller3.text + controller4.text;
    print("Controller1: ${controller1.text}");
    print("Controller2: ${controller2.text}");
    print("Controller3: ${controller3.text}");
    print("Controller4: ${controller4.text}");

    if (otp.length == 4 && otp.contains(RegExp(r'^\d{4}$'))) {
      try {
        int otpInt = int.parse(otp);

        // Print OTP and email for debugging purposes
        print("OTP: ${otpInt}, Email: ${email}");

        // Backend API URL
        final url = Uri.parse('$baseUrl/api/data/verify_otp'); // Replace with your Flask backend IP and route

        // Sending OTP and email to backend
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': email,
            'otp': otpInt,  // Send OTP as an integer
          }),
        );

        // Check backend response
        if (response.statusCode == 200) {
          // Success: OTP validated
          print("OTP Verified! Signup Complete.");
          Get.to(
            () => LoginScreen(),
            transition: Transition.rightToLeftWithFade,
            duration: const Duration(milliseconds: 0),
          );
          // Navigate to the next screen or process further
        } else {
          // Error: Display message from backend
          final message = json.decode(response.body)['message'];
          print("Error: $message");
        }
      } catch (e) {
        print("Error validating OTP: $e");
      }
    } else {
      // Show an error if OTP is incomplete
      print("Please enter a valid 4-digit OTP.");
    }
  }
}
