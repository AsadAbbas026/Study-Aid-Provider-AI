import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/Controller/quiz_controller.dart';
import 'package:study_buddy/Utils/custom_app_bar.dart';
import 'package:study_buddy/Utils/custom_side_menu.dart';
import 'package:study_buddy/Views/Quiz/start_quiz.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final QuizController quizController;
  late String userId;
  @override
  void initState() {
    super.initState();
    quizController = Get.find<QuizController>(); // Get the controller instance
    final args = Get.arguments;
    if (args != null && args['userId'] != null) {
      userId = args['userId'];
    } else {
      throw Exception("user_id is required");
    }
    print("User ID: $userId");
    quizController.fetchQuizzesFromBackend();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: CustomSideMenu(userId: Get.arguments['userId']),
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: CustomAppBar(userId: Get.arguments['userId'],
          title: "Quizzes",
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
      padding: EdgeInsets.all(20.sp),
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
        if (quizController.quizzes.isEmpty) {
          return Center(
            child: Text(
              "No Quizzes yet generated! Tap the ‘Generate Quiz’ button in the Notes Section to add a new Quiz",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.sp, color: Colors.black),
            ),
          );
        }
        return ListView.builder(
          itemCount: quizController.quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizController.quizzes[index];
            return _buildQuizCard(quiz);
          },
        );
      }),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    final createdAt = quiz['createdAt'] != null
      ? DateTime.parse(quiz['createdAt'])
      : DateTime.now();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 8.r,
                offset: Offset(0.w, 4.h),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quiz['title'] ?? 'Untitled Quiz',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6.h),
              Text(
                'Created At: ${DateFormat('dd/MM/yyyy').format(createdAt)}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    onPressed: () {
                      print("Starting quiz with ID: ${quiz['id']} ${userId}");
                      Get.to(() => StartQuizScreen(
                          userId: userId,
                          quizId: quiz['id'], // Pass the quizId here
                          quizTitle: quiz['title'] ?? 'Untitled Quiz'), arguments: {'userId': userId});
                    },
                    child: Text('Start',
                        style: TextStyle(fontSize: 16.sp, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 0.h,
          right: -20.w,
          child: GestureDetector(
            onTap: () {
              quizController.deleteQuiz(quiz);
            },
            child: CircleAvatar(
              radius: 16.r,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 18.sp, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
