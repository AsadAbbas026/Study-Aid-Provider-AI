import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GoalNotesScreen extends StatelessWidget {
  final String goalTitle;

  const GoalNotesScreen({super.key, required this.goalTitle});

  @override
  Widget build(BuildContext context) {
    final TextEditingController notesController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(goalTitle),
        backgroundColor: const Color(0xFFAB3AB7),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Notes",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            Expanded(
              child: TextField(
                controller: notesController,
                maxLines: 50,
                decoration: InputDecoration(
                  hintText: "Generated notes will appear here...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding: EdgeInsets.all(12.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
