import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:study_buddy/Controller/goal_controller.dart';

class MilestoneDetailScreen extends StatefulWidget {
  final int milestoneNumber;

  const MilestoneDetailScreen({super.key, required this.milestoneNumber});

  @override
  State<MilestoneDetailScreen> createState() => _MilestoneDetailScreenState();
}

class _MilestoneDetailScreenState extends State<MilestoneDetailScreen> {
  final GoalController goalController = Get.find<GoalController>();
  final TextEditingController descriptionController = TextEditingController();
  late final String goalTitle;
  late final String milestoneTitle;

  @override
void initState() {
  super.initState();
  final args = Get.arguments;
  goalTitle = args['goalTitle'];
  milestoneTitle = args['milestoneTitle'] ?? "Milestone ${widget.milestoneNumber}";
  
  if (!goalController.milestoneCompletion.containsKey(goalTitle)) {
    // Use addPostFrameCallback to defer the update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      goalController.milestoneCompletion[goalTitle] = List<bool>.filled(5, false);
      goalController.milestoneCompletion.refresh(); // Notify UI after widget build
    });
  }

  // Populate the description from passed arguments
  final passedDescription = args['description'];
  if (passedDescription != null && passedDescription is String) {
    descriptionController.text = passedDescription;
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          milestoneTitle ?? "Milestone ${widget.milestoneNumber}",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Description",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            TextField(
              controller: descriptionController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Enter milestone description...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Obx(() {
              if (!goalController.milestoneCompletion.containsKey(goalTitle)) {
                return Text("Milestone data not available");
              }

              final isChecked =
                  goalController.milestoneCompletion[goalTitle]?[widget.milestoneNumber - 1] ?? false;

              return Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      goalController.updateMilestone(
                        goalTitle,
                        widget.milestoneNumber - 1,
                        value!,
                      );
                    },
                  ),
                  Text("Mark as complete", style: TextStyle(fontSize: 14.sp)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
