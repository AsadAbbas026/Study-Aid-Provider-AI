import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:study_buddy/Utils/config.dart';

class UserProfileController extends GetxController {
  // Persistent observable values
  final RxString fullName = 'Username'.obs;
  final RxString email = 'user@example.com'.obs;
  final RxString profileImageBase64 = ''.obs;
  final RxString phone = ''.obs;
  final RxString university = ''.obs;

  // Disposable controllers (for forms only)
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _universityController;
  late final TextEditingController _oldPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  final passwordPreviewController = TextEditingController(text: "********");

  // Track controller disposal status
  bool _controllersDisposed = false;

  // Public getters for controllers
  TextEditingController get fullNameController => _fullNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get universityController => _universityController;
  TextEditingController get oldPasswordController => _oldPasswordController;
  TextEditingController get newPasswordController => _newPasswordController;
  TextEditingController get confirmPasswordController => _confirmPasswordController;

  // Other state
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxBool isPasswordEditing = false.obs;
  late String userId;

  @override
  void onInit() {
    super.onInit();
    userId = Get.arguments['userId'] ?? '';
    
    // Initialize controllers
    _fullNameController = TextEditingController(text: fullName.value);
    _emailController = TextEditingController(text: email.value);
    _phoneController = TextEditingController(text: phone.value);
    _universityController = TextEditingController(text: university.value);
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // Load profile data
    getUserProfile(userId);
  }

  void pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      profileImage.value = File(picked.path);
    }
  }

  void togglePasswordEdit() {
    isPasswordEditing.value = !isPasswordEditing.value;
  }

  void cancelChanges() {
    getUserProfile(userId);
    isPasswordEditing.value = false;
    profileImage.value = null;
    Get.snackbar("Cancelled", "Changes were discarded");
  }

  Future<void> getUserProfile(String uid) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/api/data/get_profile/$uid"));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final profile = data['profile'];
          
          // Update persistent values
          fullName.value = profile['fullName'] ?? '';
          email.value = profile['email'] ?? '';
          phone.value = profile['phone'] ?? '';
          university.value = profile['university'] ?? '';
          profileImageBase64.value = profile['profile_image_base64'] ?? '';
          
          // Update controllers only if they haven't been disposed
          if (!_controllersDisposed) {
            _fullNameController.text = fullName.value;
            _emailController.text = email.value;
            _phoneController.text = phone.value;
            _universityController.text = university.value;
          }
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load profile");
    }
  }

  Future<void> updateProfile() async {
    if (Get.isRegistered<UserProfileController>() == false) return;
    if (isPasswordEditing.value &&
        newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    try {
      final Map<String, dynamic> body = {
        "name": fullNameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "university": universityController.text,
      };

      if (isPasswordEditing.value) {
        body["old_password"] = oldPasswordController.text;
        body["new_password"] = newPasswordController.text;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/data/update_account/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          Get.snackbar("Success", "Profile updated successfully");
          isPasswordEditing.value = false;

          // Upload image only if selected
          if (profileImage.value != null) {
            await uploadProfileImage(profileImage.value!);
          }

          profileImage.value = null;
        } else {
          Get.snackbar("Error", jsonResponse['message'] ?? "Update failed");
        }
      } else {
        Get.snackbar("Error", "Update failed with code: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    }
  }

  Future<void> uploadProfileImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      print("Base64 Image: $base64Image");
      final response = await http.post(
        Uri.parse('$baseUrl/api/data/upload_profile_picture/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image_data': base64Image}),
      );

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['success'] == true) {
        Get.snackbar("Success", "Profile image updated");
      } else {
        Get.snackbar("Error", result['message'] ?? "Image upload failed");
      }
    } catch (e) {
      Get.snackbar("Error", "Image upload error: $e");
    }
  }

  @override
  void onClose() {
    // Update persistent values one last time before disposal
    
    // Dispose all controllers
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    universityController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    passwordPreviewController.dispose();
    
    super.onClose();
  }

}
