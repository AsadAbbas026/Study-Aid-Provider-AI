import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:study_buddy/Controller/goal_controller.dart';
import 'package:study_buddy/Utils/custom_app_bar.dart';
import 'package:study_buddy/Utils/custom_side_menu.dart';
import 'package:study_buddy/Views/Goals/goal_detail_screen.dart';
import 'package:study_buddy/Views/Goals/goal_dialog.dart';

class Goals extends StatefulWidget {
  const Goals({super.key});

  @override
  State<Goals> createState() => _GoalsState();
}

class _GoalsState extends State<Goals> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GoalController _goalController = Get.put(GoalController());
  int goalIdCounter = 0;
  @override
  void initState() {
    super.initState();
    _goalController.fetchAllGoals(); // Fetch goals when the screen is initialized
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: CustomSideMenu(userId: Get.arguments['userId']),
        appBar: CustomAppBar(
          userId: Get.arguments['userId'],
          title: "Goals",
          scaffoldKey: _scaffoldKey,
        ),
        body: _buildBody(),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      backgroundColor: const Color.fromARGB(255, 217, 217, 217),
      onPressed: () {
        Get.dialog(
          GoalDialog(goalId: goalIdCounter.toString()),
          barrierDismissible: false,
        );
      },
      child: const Icon(Icons.add, color: Colors.black),
    );
  }

  Widget _buildBody() {
    return Container(
      width: double.infinity,
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
      child: Obx(() {
        if (_goalController.goals.isEmpty) {
          return Center(
            child: Text(
              "No goals yet. Tap '+' to add one.",
              style: TextStyle(fontSize: 16.sp),
            ),
          );
        }
        return ListView.builder(
          itemCount: _goalController.goals.length,
          itemBuilder: (context, index) {
            final goal = _goalController.goals[index];
            final title = goal['title'] ?? '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Get.to(() => GoalDetailScreen(goalId: goal['id'].toString(), goalTitle: title));
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 6.h),
                    padding: EdgeInsets.all(12.sp),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(80),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                Get.defaultDialog(
                                  contentPadding: EdgeInsets.all(18.sp),
                                  title: "Delete Goal",
                                  middleText:
                                      "Are you sure you want to delete this goal?",
                                  textConfirm: "Yes",
                                  textCancel: "No",
                                  confirmTextColor: Colors.white,
                                  onConfirm: () {
                                    _goalController.removeGoal(index);
                                    Get.back();
                                  },
                                  onCancel: () {},
                                  buttonColor: Colors.red,
                                );
                              },
                            ),
                          ],
                        ),
                        Text(
                          goal['desc'] ?? '',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        SizedBox(height: 6.h),
                        Obx(() {
                          final progress = _goalController.getProgress(title);
                          return LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.deepPurple),
                            minHeight: 6.h,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
