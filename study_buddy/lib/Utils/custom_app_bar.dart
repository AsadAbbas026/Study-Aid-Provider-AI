import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_buddy/Views/Settings/general_settings_screen.dart';
import 'package:study_buddy/Views/Settings/profile_settings_screen.dart';
import 'package:study_buddy/Controller/user_profile_controller.dart';
import 'dart:convert'; // For base64Decode

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String userId;
  const CustomAppBar({
    super.key,
    required this.title,
    this.scaffoldKey,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final userProfileController = Get.find<UserProfileController>();

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          scaffoldKey?.currentState?.openDrawer();
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {},
        ),
        Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: GestureDetector(
            onTap: () {},
            child: PopupMenuButton<int>(
              color: Colors.white,
              icon: Obx(() {
                // Check if Base64 image is available
                if (userProfileController.profileImageBase64.value.isNotEmpty) {
                  return CircleAvatar(
                    radius: 18.sp,
                    backgroundImage: MemoryImage(
                      base64Decode(userProfileController.profileImageBase64.value),
                    ),
                  );
                } else {
                  return CircleAvatar(
                    radius: 18.sp,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(
                      Icons.person,
                      size: 20.sp,
                      color: Colors.black54,
                    ),
                  );
                }
              }),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.black54),
                      SizedBox(width: 10.w),
                      Text("Personal Settings"),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.black54),
                      SizedBox(width: 10.w),
                      Text("General Settings")
                    ],
                  ),
                )
              ],
              onSelected: (value) {
                if (value == 1) {
                  Get.to(() => 
                      UserProfileScreen(userId: userId,), arguments: {"userId": userId}); // Navigate to Profile screen
                }
                if (value == 2) {
                  Get.to(() =>
                      GeneralSettingsScreen()); // Navigate to Settings screen
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
