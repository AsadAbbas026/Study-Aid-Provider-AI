import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/Controller/summaries_controller.dart'; // ✅ Make sure this is imported

class SummaryDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback onDelete;

  SummaryDetailsScreen({
    super.key,
    required this.note,
    required this.onDelete,
  });

  final SummariesController summariesController = Get.put(SummariesController()); // ✅ Inject controller
  
  @override
  Widget build(BuildContext context) {
    DateTime createdAt;
    print(note);
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "Summary Details",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 171, 71, 188),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Summary"),
                    content: const Text("Are you sure you want to delete this summary?"),
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () => Get.back(),
                      ),
                      TextButton(
                        child: const Text("Delete", style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          onDelete();
                          Get.back();
                          Get.back();
                        },
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
        body: Column(
          children: [
            // Upper container
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.sp),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.sp),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 252, 228, 236),
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
                      Text(
                        note['title'] ?? "Untitled",
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        note['description'] ?? "No description",
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Date: ${DateFormat('dd/MM/yyyy').format(createdAt)}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                      Text(
                        'Time: ${DateFormat('hh:mm a').format(createdAt)}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Lower container
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.sp),
                child: Container(
                  width: double.infinity,
                  height: 300.h,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 243, 243, 243),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Text(
                      note['summary_text'] ?? "Summary not available.",
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
