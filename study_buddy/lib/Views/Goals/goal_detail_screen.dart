import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:study_buddy/Views/Goals/milestone_details_screen.dart';
import 'package:study_buddy/Controller/goal_controller.dart';

class GoalDetailScreen extends StatelessWidget {
  final String goalId;
  final String goalTitle;

  const GoalDetailScreen({super.key, required this.goalId, required this.goalTitle});

  @override
  Widget build(BuildContext context) {
    final GoalController goalController = Get.find<GoalController>();
    
    // Fetch milestones when widget builds
    goalController.fetchMilestones(goalId);

    return Scaffold(
      appBar: AppBar(
        title: Text(goalTitle, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Obx(() {
        final milestones = goalController.milestones;

        return ListView.builder(
          padding: EdgeInsets.all(16.sp),
          itemCount: milestones.length,
          itemBuilder: (context, index) {
            final milestone = milestones[index];
            return ListTile(
              title: Text(milestone['title'] ?? "Milestone ${index + 1}"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Get.to(
                  () => MilestoneDetailScreen(milestoneNumber: index + 1),
                  arguments: {
                    'goalTitle': goalTitle,
                    'milestoneTitle': milestone['title'],
                    'description': milestone['description']
                  },
                );
              },
            );
          },
        );
      }),
    );
  }
}
