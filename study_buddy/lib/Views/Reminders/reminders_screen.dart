import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:study_buddy/Controller/reminder_controller.dart';
import 'package:study_buddy/Utils/custom_app_bar.dart';
import 'package:study_buddy/Utils/custom_side_menu.dart';
import 'package:study_buddy/Views/Reminders/add_reminder.dart';
import 'package:study_buddy/Views/Reminders/reminder_model.dart';
// Reminder model import

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() {
    return _RemindersScreenState();
  }
}

class _RemindersScreenState extends State<RemindersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String userId;
  // Accessing the RemindersController
  final RemindersController remindersController =
      Get.put(RemindersController());
  

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    if (args != null && args['userId'] != null) {
      userId = args['userId'];
    } else {
      throw Exception("userId is required");
    }

    remindersController.getRemindersFromAPI(userId); // Now it's safe
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
          title: "Reminders",
          scaffoldKey: _scaffoldKey,
        ),
        body: _buildBody(),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  // Floating Action Button to open AddReminder dialog
  Widget _buildFAB() {
    return FloatingActionButton(
      backgroundColor: const Color.fromARGB(255, 217, 217, 217),
      onPressed: () {
        Get.dialog(
          AddReminder(),
          barrierDismissible: false,
        );
      },
      child: const Icon(Icons.add, color: Colors.black),
    );
  }

  // Body of the Reminders screen, listing reminders with ListView.builder
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Obx(
        () {
          // Using Obx to reactively update the UI when reminders change
          if (remindersController.reminders.isEmpty) {
            return Center(
              child: Text(
                'No Reminders Yet! Tap the ‘+’ button to add your first reminder.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: remindersController.reminders.length,
              itemBuilder: (context, index) {
                final reminder = remindersController.reminders[index];
                return _buildReminderItem(reminder);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildReminderItem(Reminder reminder) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((25.5).toInt()),
            blurRadius: 6.r,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Reminder info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  reminder.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 5,
                ),
                SizedBox(height: 8.h),
                Text(
                  "Date: ${reminder.date}",
                  style: TextStyle(fontSize: 14.sp),
                ),
                Text(
                  "Time: ${reminder.time}",
                  style: TextStyle(fontSize: 14.sp),
                ),
              ],
            ),
          ),

          // Right side: Settings popup menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.black),
            onSelected: (value) {
              if (value == 'delete') {
                remindersController.deleteReminder(reminder);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete Reminder'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
