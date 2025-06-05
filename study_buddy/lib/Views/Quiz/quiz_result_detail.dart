import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuizResultDetail extends StatelessWidget {
  final int questionNumber;
  final String question;
  final String userAnswer;
  final String expectedAnswer;
  final String explanation;
  final String feedback;

  const QuizResultDetail({
    super.key,
    required this.questionNumber,
    required this.question,
    required this.userAnswer,
    required this.expectedAnswer,
    required this.explanation,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question $questionNumber',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 171, 71, 188),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection("Question:", question),
            _buildSection("User Answer:", userAnswer),
            _buildSection("Expected Answer:", expectedAnswer),
            _buildSection("Explanation:", explanation),
            _buildSection("Feedback:", feedback),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
