import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:study_buddy/Controller/notes_controller.dart';

class QrScannerDialog extends StatelessWidget {
  final String receiverUserId;

  const QrScannerDialog({super.key, required this.receiverUserId});

  @override
  Widget build(BuildContext context) {
    // Get the NotesController instance
    final notesController = Get.find<NotesController>();
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scan QR Code',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 171, 71, 188),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            Divider(color: Colors.grey[300]),
            SizedBox(
              height: 300.h,
              child: MobileScanner(
                controller: MobileScannerController(
                  formats: [BarcodeFormat.qrCode],
                ),
                onDetect: (capture) async {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final firebaseKey = barcodes.first.rawValue;

                    if (firebaseKey != null && firebaseKey.isNotEmpty) {
                      Get.back(); // Close scanner dialog

                      // Call the import function here
                      final success = await notesController.importSharedNote(firebaseKey, receiverUserId);

                      if (success) {
                        Get.snackbar(
                          'Success',
                          'Note imported successfully!',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );
                      } else {
                        Get.snackbar(
                          'Error',
                          'Failed to import note.',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );
                      }
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

