import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:study_buddy/Controller/signup_controller.dart';
import 'package:study_buddy/Views/Login/login_screen.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});
  final SignUpController controller = Get.put(SignUpController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(24.sp),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 171, 71, 188),
                Color.fromARGB(255, 252, 228, 236),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                spacing: 5.h,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogo(),
                  _buildSignUpHeader(),
                  _buildFullNameField(),
                  _buildEmailField(),
                  _buildPasswordField(),
                  _buildConfirmPasswordField(),
                  _buildTermsAndConditionsCheckbox(),
                  _buildSignUpButton(),
                  _buildLogInTextButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/applogo.png',
      width: 150.w,
      height: 125.h,
    );
  }

  Widget _buildSignUpHeader() {
    return Text(
      'Create New Account',
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildFullNameField() {
    return Column(
      spacing: 5.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextFormField(
          controller: controller.fullNameController,
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            filled: true,
            fillColor: Colors.white.withAlpha(230),
          ),
          validator: (value) {
            if (controller.isRequiredFieldEmpty(value ?? '')) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      spacing: 5.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextFormField(
          controller: controller.emailController,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            filled: true,
            fillColor: Colors.white.withAlpha(230),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (controller.isRequiredFieldEmpty(value ?? '')) {
              return 'This field is required';
            }
            if (!controller.isValidEmail(value ?? '')) {
              return 'Invalid email format';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      spacing: 5.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Password',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Obx(() {
          return TextFormField(
            controller: controller.passwordController,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.black,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: Colors.white.withAlpha(230),
            ),
            obscureText: !controller.isPasswordVisible.value,
            validator: (value) {
              if (controller.isRequiredFieldEmpty(value ?? '')) {
                return 'This field is required';
              }
              return null;
            },
          );
        }),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      spacing: 5.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Password',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Obx(() {
          return TextFormField(
            controller: controller.confirmPasswordController,
            decoration: InputDecoration(
              hintText: 'Confirm your password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isConfirmPasswordVisible.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.black,
                ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: Colors.white.withAlpha(230),
            ),
            obscureText: !controller.isConfirmPasswordVisible.value,
            validator: (value) {
              if (controller.isRequiredFieldEmpty(value ?? '')) {
                return 'This field is required';
              }
              if (value != controller.passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          );
        }),
      ],
    );
  }

  Widget _buildTermsAndConditionsCheckbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Obx(() {
          return Checkbox(
            value: controller.isAgreed.value,
            onChanged: (bool? value) {
              controller.toggleAgreement(value ?? false);
            },
          );
        }),
        Text(
          "I agree to",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            "Terms & Conditions",
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color.fromARGB(255, 170, 213, 248),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          controller.signup();
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: const Color.fromARGB(1, 138, 77, 233),
        ),
        child: Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLogInTextButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: () {
            Get.off(
              () => LoginScreen(),
              transition: Transition.rightToLeftWithFade,
              duration: const Duration(milliseconds: 0),
            );
          },
          child: Text(
            'Log In',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color.fromARGB(255, 170, 213, 248),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
