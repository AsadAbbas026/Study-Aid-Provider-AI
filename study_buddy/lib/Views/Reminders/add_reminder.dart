import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/Controller/reminder_controller.dart';
import 'reminder_model.dart'; // Import the Reminder model

class AddReminder extends StatefulWidget {
  const AddReminder({super.key});

  @override
  State<AddReminder> createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          spacing: 10.h,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add New Reminder',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(thickness: 1.sp),
            _buildTextField(
              label: 'Reminder Title',
              hintText: 'Enter title',
              controller: titleController,
            ),
            _buildTextField(
              label: 'Reminder Description',
              hintText: 'Enter Description',
              maxLines: 3,
              controller: descriptionController,
            ),
            _buildDatePicker(controller: dateController),
            _buildTimePicker(controller: timeController),
            Row(
              spacing: 10.w,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildElevatedButton(
                  label: 'Cancel',
                  width: 105.w,
                  height: 35.h,
                  borderRadius: 4.r,
                  color: Colors.red,
                  onPressed: Get.back,
                ),
                _buildElevatedButton(
                  label: 'Save',
                  width: 100.w,
                  height: 35.h,
                  borderRadius: 4.r,
                  color: Colors.blue,
                  onPressed: () {
                    final newReminder = Reminder(
                      title: titleController.text,
                      description: descriptionController.text,
                      date: dateController.text,
                      time: timeController.text,
                    );

                    // Add reminder to the list via the RemindersController
                    Get.find<RemindersController>().addReminder(newReminder);
                    Get.back(); // Close the dialog
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    int maxLines = 1,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 13.sp,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          ),
          style: TextStyle(fontSize: 14.sp),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Date",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: "dd/MM/yyyy",
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          ),
          style: TextStyle(fontSize: 14.sp),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: Get.context!,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTimePicker({
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Time",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: "hh:mm AM/PM",
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: const Icon(Icons.access_time, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          ),
          style: TextStyle(fontSize: 14.sp),
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: Get.context!,
              initialTime: TimeOfDay.now(),
            );
            if (pickedTime != null) {
              final now = DateTime.now();
              final formattedTime = DateFormat('hh:mm a').format(
                DateTime(now.year, now.month, now.day, pickedTime.hour,
                    pickedTime.minute),
              );
              controller.text = formattedTime;
            }
          },
        ),
      ],
    );
  }

  Widget _buildElevatedButton({
    required String label,
    required Color color,
    required double borderRadius,
    required VoidCallback onPressed,
    required double width,
    required double height,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
