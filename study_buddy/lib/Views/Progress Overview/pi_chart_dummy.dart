import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:study_buddy/Utils/config.dart';

class QuizProgress {
  final String title;
  final int totalMarks;
  final int obtainedMarks;

  QuizProgress({
    required this.title,
    required this.totalMarks,
    required this.obtainedMarks,
  });

  double get successRate => (obtainedMarks / totalMarks) * 100;
  double get failureRate => 100 - successRate;
}

// Fetch quiz progress data from backend
Future<List<QuizProgress>> fetchQuizProgress(String userId) async {
  final response = await http.get(Uri.parse('$baseUrl/api/data/quiz_progress/$userId'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    List<QuizProgress> quizProgressList = data.map((quiz) {
      return QuizProgress(
        title: quiz['title'],
        totalMarks: quiz['totalMarks'],
        obtainedMarks: quiz['obtainedMarks'],
      );
    }).toList();

    return quizProgressList;
  } else {
    throw Exception('Failed to load quiz progress');
  }
}
