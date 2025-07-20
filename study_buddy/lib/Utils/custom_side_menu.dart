import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_buddy/Controller/side_menu_controller.dart';
import 'package:study_buddy/Controller/user_profile_controller.dart';
import 'dart:convert'; // For base64Decode

class CustomSideMenu extends StatelessWidget {
  final String userId;
  const CustomSideMenu({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SideMenuController>();

    return SizedBox(
      width: 250.w,
      child: Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildUserProfile(),
              Divider(thickness: 5.h),
              _buildDrawerItem(controller, 0, Icons.dashboard, "Dashboard", () {
                controller.selectIndex(0);
                Get.back();
                Get.offNamed('/dashboardScreen', arguments: {
                  'userId': this.userId,
                });
              }),
              const Divider(),
              _buildDrawerItem(controller, 1, Icons.notifications, "Reminders",
                  () {
                controller.selectIndex(1);
                Get.back();
                Get.offNamed('/reminderScreen', arguments: {
                  'userId': this.userId,
                });
              }),
              const Divider(),
              _buildDrawerItem(controller, 2, Icons.note, "Notes", () {
                controller.selectIndex(2);
                Get.back();
                Get.offNamed('/notesScreen', arguments: {
                  'userId': this.userId,
                });
              }),
              const Divider(),
              _buildDrawerItem(controller, 3, Icons.quiz, "Quizzes", () {
                controller.selectIndex(3);
                Get.back();
                Get.offNamed('/quizScreen', arguments: {
                  'userId': this.userId,
                });
              }),
              const Divider(),
              _buildDrawerItem(controller, 4, Icons.menu_book, "Summaries", () {
                controller.selectIndex(4);
                Get.back();
                Get.offNamed('/summariesScreen', arguments: {
                  'userId': this.userId,
                });
              }),
              const Divider(),
              _buildDrawerItem(
                  controller, 5, Icons.calendar_month, "Study Schedules", () {
                controller.selectIndex(5);
                Get.back();
                Get.offNamed('/studySchedule', arguments: {
                  'userId': this.userId,
                });
              }),
              const Divider(),
              _buildDrawerItem(controller, 6, Icons.flag, "Goals", () {
                controller.selectIndex(6);
                Get.back();
                Get.offNamed('/goals', arguments: {
                  'userId': this.userId,
                });
              }),
              const Divider(),
              _buildDrawerItem(
                  controller, 7, Icons.bar_chart, "Progress Overview", () {
                controller.selectIndex(7);
                Get.back();
                Get.offNamed('/progressOverview', arguments: {
                  'userId': this.userId,
                });
              }),
              const Divider(),
              _buildDrawerItem(controller, 8, Icons.logout, "Logout", () {
                controller.selectIndex(0);
                Get.back();
                Get.offAllNamed('/loginScreen');
              }, isLogoutButton: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    final userProfileController = Get.find<UserProfileController>();
    return Column(
      children: [
        SizedBox(height: 10.h),
        userProfileController.profileImageBase64.isNotEmpty
            ? CircleAvatar(
                radius: 40.r,
                backgroundImage: MemoryImage(
                  base64Decode(Get.find<UserProfileController>().profileImageBase64.value),
                ),
              )
            : CircleAvatar(
                radius: 40.r,
                backgroundColor: Colors.grey.shade300,
                child: Icon(Icons.person, size: 40.sp, color: Colors.black54),
              ),
        SizedBox(height: 10.h),
        Text(
          userProfileController.fullName.value,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        Text(
          userProfileController.email.value,
          style: TextStyle(fontSize: 14.sp, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
    SideMenuController controller,
    int index,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogoutButton = false,
  }) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      return Container(
        color: isSelected
            ? const Color.fromARGB(255, 175, 89, 240)
                .withAlpha((0.4 * 255).toInt())
            : Colors.transparent,
        child: ListTile(
          leading:
              Icon(icon, color: isLogoutButton ? Colors.red : Colors.black),
          title: Text(
            title,
            style: GoogleFonts.inter(
              color: isLogoutButton ? Colors.red : Colors.black,
            ),
          ),
          onTap: onTap,
        ),
      );
    });
  }
}