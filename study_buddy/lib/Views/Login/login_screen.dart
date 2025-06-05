import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:study_buddy/Controller/login_controller.dart';
import 'package:study_buddy/Views/SignUp/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final LoginController controller = Get.put(LoginController());

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
            child: Column(
              spacing: 10.h,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(controller),
                _buildLoginHeader(),
                _buildEmailField(
                  key: const Key('emailField'),
                  label: 'Email',
                  hint: 'Enter your email',
                ),
                _buildPasswordField(
                  key: const Key('passwordField'),
                  label: 'Password',
                  hint: 'Enter your password',
                ),
                _buildForgotPassword(),
                _buildLoginButton(),
                _buildSocialButton(
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata,
                  onPressed: () {},
                ),
                _buildSocialButton(
                  label: 'Continue with Facebook',
                  icon: Icons.facebook,
                  onPressed: () {},
                ),
                _buildSignUpButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(LoginController controller) {
    return AnimatedBuilder(
      animation: controller.rotationController,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.rotationY(
            controller.rotationController.value * 2 * 3.14159,
          ),
          alignment: Alignment.center,
          child: child,
        );
      },
      child: Image.asset(
        'assets/images/applogo.png',
        width: 150.w,
        height: 125.h,
      ),
    );
  }

  Widget _buildLoginHeader() {
    return Text(
      'Login Account',
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildEmailField({required String label, required String hint, required Key key}) {
    return Column(
      spacing: 2.5.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller.emailController,
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  filled: true,
                  fillColor: Colors.white.withAlpha(230),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              // Display error if emailError is not empty
              if (controller.emailError.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    controller.emailError.value,
                    style: TextStyle(color: Colors.red, fontSize: 12.sp),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPasswordField({required String label, required String hint, required Key key}) {
    return Column(
      spacing: 2.5.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller.passwordController,
                obscureText: !controller.isPasswordVisible.value,
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white.withAlpha(230),
                ),
              ),
              // Display error if passwordError is not empty
              if (controller.passwordError.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    controller.passwordError.value,
                    style: TextStyle(color: Colors.red, fontSize: 12.sp),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () {},
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color.fromARGB(255, 170, 213, 248),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: const Key('loginButton'),
        onPressed: () {
          if (controller.validateFields()) {
            controller.loginUser();
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: const Color.fromARGB(1, 138, 77, 233),
        ),
        child: Text(
          'Login',
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.blue,
          size: 24.sp,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.black,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: () {
            Get.off(
              () => SignUpScreen(),
              transition: Transition.leftToRightWithFade,
              duration: const Duration(milliseconds: 0),
            );
          },
          child: Text(
            'Sign Up',
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
