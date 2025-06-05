import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:study_buddy/Controller/notes_controller.dart';
class QRScreen extends StatelessWidget {
  final String qrData;

  const QRScreen({super.key, required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.sp),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 171, 71, 188), // Purple
              Color.fromARGB(255, 252, 228, 236), // Light pink
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Share Note',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            Divider(color: Colors.white.withOpacity(0.3)), // Lighter divider
            SizedBox(height: 10.h),
            // QR Code - Added a white container for better visibility
            Container(
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 180.sp, // Slightly reduced to fit container
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}