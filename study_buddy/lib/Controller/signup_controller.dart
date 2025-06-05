import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:study_buddy/Views/OTP/otp_screen.dart';
import 'package:study_buddy/Utils/config.dart';

class SignUpController extends GetxController {
  // Observables for visibility toggles and agreement checkbox
  RxBool isPasswordVisible = false.obs;
  RxBool isConfirmPasswordVisible = false.obs;
  RxBool isAgreed = false.obs;

  // Text editing controllers for input fields
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  Future<void> signup() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final url = Uri.parse('$baseUrl/api/data/signup'); // Replace with your backend URL

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': fullNameController.text.trim(),
        'password': password,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      print(fullNameController.text);
      print(passwordController.text);
      print(emailController.text);
      // Success: Navigate to OTP Screen
      Get.to(
        () => OTPScreen(), arguments: {'email': email},
        transition: Transition.rightToLeftWithFade,
        duration: const Duration(milliseconds: 0),
      );
    } else {
      // Show error message
      final errorMessage = json.decode(response.body)['message'] ?? 'Signup failed';
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
  // Toggles password visibility for the password field
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Toggles password visibility for the confirm password field
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Toggles agreement checkbox
  void toggleAgreement(bool value) {
    isAgreed.value = value;
  }

  // Checks if the password and confirm password fields match
  bool isPasswordMatching() {
    return passwordController.text == confirmPasswordController.text;
  }

  // Validates if an email address is in the correct format
  bool isValidEmail(String email) {
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(emailPattern).hasMatch(email);
  }

  // Checks if a required field is empty
  bool isRequiredFieldEmpty(String value) {
    return value.isEmpty;
  }

  // Dispose controllers when the controller is closed
  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
