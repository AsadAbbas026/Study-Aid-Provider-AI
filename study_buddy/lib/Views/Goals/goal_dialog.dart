import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:study_buddy/Controller/goal_controller.dart';

class GoalDialog extends StatelessWidget {
  final String goalId;
  GoalDialog({super.key, required this.goalId});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final GoalController goalController = Get.find<GoalController>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add New Goal",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            _buildTextField(label: "Goal Title", controller: titleController),
            SizedBox(height: 10.h),
            _buildTextField(
                label: "Goal Description",
                controller: descController,
                maxLines: 3),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r)),
                  ),
                  onPressed: () => Get.back(),
                  child: Text("Cancel",
                      style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                ),
                SizedBox(width: 10.w),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r)),
                  ),
                  onPressed: () async{
                    if (titleController.text.isNotEmpty &&
                        descController.text.isNotEmpty) {
                      goalController.addGoal(
                          titleController.text, descController.text);
                      Get.back();
                    }
                  },
                  child: Text("Save",
                      style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          ),
          style: TextStyle(fontSize: 14.sp),
        ),
      ],
    );
  }
}
