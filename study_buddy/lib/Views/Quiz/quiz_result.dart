import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'quiz_result_detail.dart'; // Create this screen
import 'package:get/get.dart';

class QuizResult extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  const QuizResult({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final int questionCount = Get.arguments['index'] + 1; // or just Get.arguments['count'] if you pass count directly
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Quiz Result',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 171, 71, 188),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.sp),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 0.85,
            children: List.generate(questionCount, (index) {
              return GestureDetector(
                onTap: () {
                  final result = results.length > index ? results[index] : {};
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizResultDetail(
                        questionNumber: index + 1,
                        question: result["question"] ?? "Question not available",
                        userAnswer: result["user_answer"] ?? "Not answered",
                        expectedAnswer: result["expected_answer"] ?? "No correct answer provided",
                        explanation: result["explanation"] ?? "No explanation provided",
                        feedback: result["feedback"] ?? "No feedback available",
                      ),
                    ),
                  );
                },
                child: _buildResultPreview(index + 1),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildResultPreview(int questionNumber) {
    return Container(
      padding: EdgeInsets.all(16.sp),
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
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Question $questionNumber",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "Tap to view full result...",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
