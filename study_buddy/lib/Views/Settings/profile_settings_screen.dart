import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:study_buddy/Controller/user_profile_controller.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final UserProfileController controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = Get.find<UserProfileController>();
    controller.getUserProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Obx(() => Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(24.sp),
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
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildAppBar(),
                      _buildProfileHeader(),
                      _buildFullNameField(),
                      _buildEmailField(),
                      controller.isPasswordEditing.value
                          ? _buildPasswordFields()
                          : _buildPasswordPreview(),
                      _buildPhoneField(),
                      _buildUniversityField(),
                      _buildUpdateButton(),
                      _buildCancelButton(),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        const Spacer(),
        Text(
          'Your Profile',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        GestureDetector(
          onTap: controller.pickImage,
          child: Obx(() {
            if (controller.profileImageBase64.value.isNotEmpty) {
              return CircleAvatar(
                radius: 50.r,
                backgroundImage: MemoryImage(
                  base64Decode(controller.profileImageBase64.value),
                ),
              );
            } else {
              return CircleAvatar(
                radius: 50.r,
                backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
              );
            }
          }),
        ),
        SizedBox(height: 10.h),
        TextButton(
          onPressed: controller.pickImage,
          child: Text(
            "Change Photo",
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildFullNameField() {
    return _buildLabeledField(
      label: 'Full Name',
      child: TextFormField(
        controller: controller.fullNameController,
        decoration: _inputDecoration('Enter your full name', Icons.person),
        validator: (value) => value!.isEmpty ? 'Full name cannot be empty' : null,
      ),
    );
  }

  Widget _buildEmailField() {
    return _buildLabeledField(
      label: 'Email',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Obx(
              () => Text(
                controller.email.value,
                style: TextStyle(fontSize: 16.sp),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordPreview() {
    return _buildLabeledField(
      label: 'Password',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('********', style: TextStyle(fontSize: 16.sp)),
          IconButton(icon: const Icon(Icons.edit), onPressed: controller.togglePasswordEdit),
        ],
      ),
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        _buildLabeledField(
          label: 'Old Password',
          child: TextFormField(
            controller: controller.oldPasswordController,
            obscureText: true,
            decoration: _inputDecoration('Enter old password', Icons.lock),
          ),
        ),
        _buildLabeledField(
          label: 'New Password',
          child: TextFormField(
            controller: controller.newPasswordController,
            obscureText: true,
            decoration: _inputDecoration('Enter new password', Icons.lock_outline),
          ),
        ),
        _buildLabeledField(
          label: 'Confirm Password',
          child: TextFormField(
            controller: controller.confirmPasswordController,
            obscureText: true,
            decoration: _inputDecoration('Confirm password', Icons.lock_outline),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return _buildLabeledField(
      label: 'Phone Number',
      child: TextFormField(
        controller: controller.phoneController,
        keyboardType: TextInputType.phone,
        decoration: _inputDecoration('Enter your phone number', Icons.phone),
        validator: (value) => value!.length < 10 ? 'Invalid phone number' : null,
      ),
    );
  }

  Widget _buildUniversityField() {
    return _buildLabeledField(
      label: 'Institute/University',
      child: TextFormField(
        controller: controller.universityController,
        decoration: _inputDecoration('Enter university name', Icons.school),
        validator: (value) => value!.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              controller.updateProfile();
            }
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            backgroundColor: const Color.fromARGB(255, 138, 77, 233),
          ),
          child: Text('Update Profile', style: TextStyle(fontSize: 18.sp, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: controller.cancelChanges,
      child: Text('Cancel Changes', style: TextStyle(fontSize: 14.sp, color: Colors.red)),
    );
  }

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      prefixIcon: Icon(icon),
      counterText: '',
    );
  }
}
