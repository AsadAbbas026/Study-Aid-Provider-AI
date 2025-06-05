import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_buddy/Controller/dashboard_controller.dart';
import 'package:study_buddy/Utils/custom_app_bar.dart';
import 'package:study_buddy/Utils/custom_side_menu.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    final userId = Get.arguments['userId'];

    // Only create the controller here when actually navigating to DashboardScreen
    final DashboardController controller = Get.put(DashboardController(userId: userId));

    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        drawer: CustomSideMenu(userId: Get.arguments['userId']),
        appBar: CustomAppBar(userId: Get.arguments['userId'], title: "Dashboard", scaffoldKey: scaffoldKey),
        body: _buildBody(controller),
      ),
    );
  }

  Widget _buildBody(DashboardController controller) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(16.sp),
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
          children: [
            Row(
              children: [
                Text(
                  'Welcome back!',
                  key: const Key('dashboardWelcomeText'),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 25.h),
            _buildTranscriptionBox(controller),
            SizedBox(height: 115.h),
            Obx(() => _buildElevatedButton(
                  text: controller.buttonText.value,
                  icon: controller.buttonIcon.value,
                  onPressed: controller.toggleRecording,
                )),
            SizedBox(height: 15.h),
            SizedBox(
              width: 200.w,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  backgroundColor: Colors.purple.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                onPressed: () {
                  controller.pickWavFile();
                },
                child: Text("Select Audio File",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    )),
              ),
            ),
            SizedBox(height: 10.h),
            Obx(() {
              if (controller.selectedAudioFileName.isNotEmpty) {
                return Text(
                  "✅ Selected: ${controller.selectedAudioFileName.value}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                );
              } else {
                return const SizedBox();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTranscriptionBox(DashboardController controller) {
    return Row(
      children: [
        Container(
          width: 325.w,
          height: 280.h,
          padding: EdgeInsets.all(8.sp),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            width: 325.w,
            height: 350.h,
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Obx(() => TextField(
                  maxLines: null,
                  controller: controller.textEditingController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: controller.transcriptionText.value.isEmpty
                        ? "Transcription will appear here..."
                        : null,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ))),
          ),
      ],
    );
  }

  Widget _buildElevatedButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 200.w,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: Colors.purple.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 12.h),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              icon,
              color: Colors.white,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
