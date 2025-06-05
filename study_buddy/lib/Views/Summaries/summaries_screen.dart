// summaries_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/Controller/summaries_controller.dart'; // Import the new controller
import 'package:study_buddy/Utils/custom_app_bar.dart';
import 'package:study_buddy/Utils/custom_side_menu.dart';
import 'package:study_buddy/Views/Summaries/summary_details_screen.dart';

class SummariesScreen extends StatefulWidget {
  const SummariesScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SummariesScreenState();
  }
}

class _SummariesScreenState extends State<SummariesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SummariesController summariesController = Get.put(SummariesController()); // Use Get.put to initialize the controller
  late String userId;
  @override
  void initState() {
    super.initState();
    userId = Get.arguments['userId'];
    summariesController.fetchSummariesFromBackend(); // Fetch summaries when the screen is initialized
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: CustomSideMenu(userId: userId),
        appBar: CustomAppBar(
          userId: userId,
          title: "Summaries",
          scaffoldKey: _scaffoldKey,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Checking if summaries are available
            Obx(() {
              if (summariesController.summaries.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 50.h,
                    ), // Add vertical padding to ensure it's centered
                    child: Text(
                      'No Summaries Yet! Tap the ‘Generate Summaries’ button in the Notes Section to add your first Summary',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              }

              // If summaries are available, show them in a list
              return ListView.builder(
                shrinkWrap:
                    true, // Ensure the list doesn't take up excess space
                itemCount: summariesController.summaries.length,
                itemBuilder: (context, index) => _buildNoteSummaryItem(
                    summariesController.summaries[index], index),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSummaryItem(Map<String, dynamic> note, int index) {
    DateTime createdAt;

    try {
      if (note['createdAt'] is DateTime) {
        createdAt = note['createdAt'];
      } else if (note['createdAt'] is String) {
        createdAt = DateFormat('dd/MM/yyyy HH:mm').parse(note['createdAt']);
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      createdAt = DateTime.now();
    }

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Get.to(() => SummaryDetailsScreen(
                    note: note,
                    onDelete: () {
                      summariesController.deleteSummary(index);
                    },
                  ));
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4.r,
                    offset: Offset(0, 2.h),
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
                          note['title'] ?? "Untitled",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    note['description'] ?? "No description",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: ${DateFormat('dd/MM/yyyy').format(createdAt)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Time: ${DateFormat('hh:mm a').format(createdAt)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
