import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:study_buddy/Controller/notes_controller.dart';

class AddNoteDialog extends StatelessWidget {
  final NotesController notesController = Get.find<NotesController>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  AddNoteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add New Note',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              label: 'Course Title',
              controller: titleController,
            ),
            _buildTextField(
              label: 'Content',
              controller: contentController,
              maxLines: 3,
            ),
            _buildElevatedButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int? maxLines = 1,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText ?? 'Enter $label',
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 13.sp,
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: Colors.black, width: 1.w),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: Colors.blue, width: 1.w),
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
          ),
          style: TextStyle(fontSize: 14.sp),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildElevatedButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(width: 8.w),
        ElevatedButton(
          onPressed: () {
            final note = {
              'title': titleController.text,
              'desc': contentController.text,
              'createdAt':
                  notesController.getCurrentDateTime(), // Add creation date
            };
            notesController.addManualNote(note);
            Get.back();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          child: Text(
            'Save',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
