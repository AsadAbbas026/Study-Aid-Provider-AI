import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:study_buddy/Views/Dashboard/dashboard_screen.dart';
import 'package:study_buddy/Utils/config.dart';

class LoginController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController rotationController;
  late Timer timer;

  // Observable variables for password visibility
  RxBool isPasswordVisible = false.obs;

  // Text editing controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Observable for error messages
  RxString emailError = ''.obs;
  RxString passwordError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    rotationController = AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 5), // Each full rotation takes 5 seconds
    );
    _startInfiniteRotation();
  }

  void _startInfiniteRotation() {
    rotationController.forward().then(
      (_) {
        timer = Timer(
          const Duration(seconds: 5),
          () {
            rotationController.reset();
            rotationController.forward();
            _startInfiniteRotation();
          },
        );
      },
    );
  }

  // Method to toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Validation for email and password fields
  bool validateFields() {
    bool isValid = true;

    // Check if the email is empty or invalid
    if (emailController.text.isEmpty) {
      emailError.value = 'This field is required';
      isValid = false;
    } else if (!isValidEmail(emailController.text)) {
      emailError.value = 'Invalid Email';
      isValid = false;
    } else {
      emailError.value = ''; // Clear error if valid email
    }

    // Check if the password is empty
    if (passwordController.text.isEmpty) {
      passwordError.value = 'This field is required';
      isValid = false;
    } else {
      passwordError.value = ''; // Clear error if password is not empty
    }

    return isValid;
  }

  Future<void> loginUser() async {
      final url = Uri.parse('$baseUrl/api/data/login');  // Replace with your Flask server URL
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        print(responseJson);
         Get.off(() => DashboardScreen(), arguments: {
            'userId': responseJson['uid'],
          },
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 0));
        // Navigate to the next screen
      } else {
        final error = json.decode(response.body)['message'];
        print(error);
        // Show error to user
      }
    }

  // Regular expression to validate email format
  bool isValidEmail(String email) {
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regExp = RegExp(emailPattern);

    return regExp.hasMatch(email);
  }

  @override
  void onClose() {
    rotationController.dispose();
    timer.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
