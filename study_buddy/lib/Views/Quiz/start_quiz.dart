import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:study_buddy/Views/Quiz/quiz_result.dart';
import 'quiz_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:study_buddy/Utils/config.dart';
import 'package:study_buddy/Views/Quiz/QuestionModel.dart';
import 'package:study_buddy/Controller/quiz_controller.dart';

class StartQuizScreen extends StatefulWidget {
  final String quizTitle;
  final int quizId;
  final String userId;
  const StartQuizScreen({super.key, required this.quizId, required this.quizTitle, required this.userId});

  @override
  State<StartQuizScreen> createState() => _StartQuizScreenState();
}

class _StartQuizScreenState extends State<StartQuizScreen> with TickerProviderStateMixin {
  late String userId;
  bool _started = false;
  late final AnimationController _animationController;
  late final Animation<Offset> _welcomeOffset;
  late final Animation<Offset> _timerOffset;

  Duration _elapsed = Duration(minutes: 15);
  Timer? _timer;

  int _currentQuestionIndex = 0; // Track the current question
  String _selectedOption = '';
  var _questions = <QuizQuestion>[].obs;
  Map<int, String> _userAnswers = {};
  final TextEditingController _question3Controller = TextEditingController();
  final QuizController _quizController = Get.put(QuizController());

  @override
  void initState() {
    super.initState();
    userId = Get.arguments['userId'];
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _welcomeOffset = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -2))
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _timerOffset = Tween<Offset>(begin: Offset.zero, end: Offset(0, -2))
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  void _startQuiz() async {
    setState(() {
      _started = true;
      _elapsed = Duration(minutes: 15);
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/data/get_quiz_questions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'quiz_id': widget.quizId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _questions.value = List<QuizQuestion>.from(data['questions'].map((q) => QuizQuestion(
          id: q['id'],
          question: q['question'],
          type: q['type'],
          options: q['options'] != null ? List<String>.from(q['options']) : null,
          answer: q['answer']
        )));

      } else {
        print('[ERROR] Failed to fetch quiz questions: ${response.statusCode}');
      }
    } catch (e) {
      print('[ERROR] Exception in fetching quiz questions: $e');
    }

    _animationController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          if (_elapsed.inSeconds > 0) {
            _elapsed -= const Duration(seconds: 1);
          } else {
            _timer?.cancel();
            // Time's up: Handle quiz auto-submit or navigate
            print("Time's up!");
          }
        });
      });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = '';
        _question3Controller.clear(); // Reset the text field
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    _question3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.quizTitle,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFFAB3AB7),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => SlideTransition(
                    position: _welcomeOffset,
                    child: Opacity(
                      opacity: 1 - _animationController.value,
                      child: child,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Welcome to ${widget.quizTitle}. You will be asked a series of questions; Press 'Start' to begin.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => SlideTransition(
                    position: _timerOffset,
                    child: child,
                  ),
                  child: Center(
                    child: Text(
                      _formatDuration(_elapsed),
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (!_started)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        onPressed: () {
                          String userId = Get.arguments['userId'];
                          if (userId != null) {
                            Get.to(() => const QuizScreen(), arguments: {'userId': userId});
                          } else {
                            throw Exception("User ID is missing");
                          }
                        },
                        child: Text(
                          'Cancel',
                          style:
                              TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 20.w),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        onPressed: _startQuiz,
                        child: Text(
                          'Start',
                          style:
                              TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                if (_started) ...[
                  // Display current question dynamically based on the type
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(16.sp),
                    child: Column(
                      spacing: 10.h,
                      children: [
                        Center(
                          child: Text(
                            "Question ${_currentQuestionIndex + 1}",
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          _questions[_currentQuestionIndex].question,
                          style: TextStyle(fontSize: 15.sp),
                        ),
                        if (_questions[_currentQuestionIndex].type == "true_false") ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ChoiceChip(
                                label: Text('True'),
                                selected: _selectedOption == 'True',
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedOption = selected ? 'True' : '';
                                    _userAnswers[_questions[_currentQuestionIndex].id] = _selectedOption;
                                  });
                                },
                              ),
                              SizedBox(width: 20.w),
                              ChoiceChip(
                                label: Text('False'),
                                selected: _selectedOption == 'False',
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedOption = selected ? 'False' : '';
                                    _userAnswers[_questions[_currentQuestionIndex].id] = _selectedOption;
                                  });
                                },
                              ),
                            ],
                          ),
                        ] else if (_questions[_currentQuestionIndex].type == "multiple_choice") ...[
                          Column(
                            children: _questions[_currentQuestionIndex].options!.map((option) {
                              return RadioListTile<String>(
                                title: Text(option),
                                value: option,
                                groupValue: _selectedOption,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOption = value!;
                                    _userAnswers[_questions[_currentQuestionIndex].id] = _selectedOption;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ] else if (_questions[_currentQuestionIndex].type == "self_explanatory") ...[
                          TextField(
                            controller: _question3Controller,
                            maxLines: 5,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Enter your answer here...",
                            ),
                             onChanged: (value) {
                              _userAnswers[_questions[_currentQuestionIndex].id] = value;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _previousQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        child: Text(
                          "Previous",
                          style:
                              TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _currentQuestionIndex == _questions.length - 1
                            ? () async {
                              final resultData = await _quizController.submit_quiz(
                                widget.quizId,
                                _userAnswers.entries.map((entry) {
                                  return {
                                    'question_id': entry.key.toString(), // Convert the int to String here
                                    'answer_text': entry.value,
                                  };
                                }).toList(),
                              );

                              print('Response Data: ${resultData}');

                              // Check if the resultData is a Map and contains the 'feedbacks' key
                              if (resultData is Map<String, dynamic>) {
                                if (resultData.containsKey('feedbacks')) {
                                  // Ensure feedbacks are handled properly as a List of Maps
                                  if (resultData['feedbacks'] != null && resultData['feedbacks'].isNotEmpty) {
                                    final feedbacks = List<Map<String, dynamic>>.from(resultData['feedbacks']);
                                    Get.to(() => QuizResult(results: feedbacks), arguments: {"index": _currentQuestionIndex});
                                  } else {
                                    Get.snackbar('Error', 'No feedbacks found in response');
                                  }
                                } else {
                                  // Handle error if no feedbacks exist
                                  Get.snackbar('Error', resultData['error'] ?? 'Something went wrong');
                                }
                              } else {
                                // Handle error if resultData is not of expected type
                                print("Unexpected data format");
                                Get.snackbar('Error', 'Unexpected data format received');
                              }
                            }

                            : _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        child: Text(
                          _currentQuestionIndex == _questions.length - 1
                              ? "Submit"
                              : "Next",
                          style: TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
