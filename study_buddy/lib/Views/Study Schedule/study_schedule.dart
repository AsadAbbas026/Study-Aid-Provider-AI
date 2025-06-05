import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:study_buddy/Controller/schedule_controller.dart';
import 'package:study_buddy/Utils/custom_app_bar.dart';
import 'package:study_buddy/Utils/custom_side_menu.dart';
import 'package:study_buddy/Views/Study Schedule/study_schedule_dialog.dart';

class StudySchedule extends StatefulWidget {
  const StudySchedule({super.key});

  @override
  State<StudySchedule> createState() {
    return _StudyScheduleState();
  }
}

class _StudyScheduleState extends State<StudySchedule> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Using Get.find to access the controller
  final ScheduleController _controller = Get.find<ScheduleController>();
  
  @override
  void initState() {
    super.initState();
    // Fetch schedules when the screen is initialized
    _controller.fetchSchedules();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showScheduleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StudyScheduleDialog(
          labelController: _labelController,
          descriptionController: _descriptionController,
          onSave: _controller.addSchedules,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: CustomSideMenu(userId: Get.arguments['userId']),
        key: _scaffoldKey,
        appBar: CustomAppBar(
          userId: Get.arguments['userId'],
          title: "Study Schedules",
          scaffoldKey: _scaffoldKey,
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: _showScheduleDialog,
          backgroundColor: const Color.fromARGB(255, 234, 198, 237),
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
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
      child: Obx(
        () {
          return _controller.schedules.isEmpty
              ? Center(
                  child: Text(
                    "No study schedules yet. Use the '+' button to add one.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: Colors.black,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _controller.schedules.length,
                  itemBuilder: (context, index) {
                    final schedules = _controller.schedules[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(12.sp),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha((0.3 * 255).toInt()),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  schedules['label'] ?? '',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                  maxLines: null,
                                  softWrap: true,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _controller.deleteSchedule(schedules, index);
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            schedules['desc'] ?? '',
                            style: TextStyle(fontSize: 14.sp),
                            maxLines: 3,
                            softWrap: true,
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              SizedBox(width: 5.w),
                              Text(
                                schedules['dateTime'] ?? '',
                                style: TextStyle(fontSize: 13.sp),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
