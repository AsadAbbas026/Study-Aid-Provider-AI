import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:study_buddy/Utils/config.dart';


class QuizController extends GetxController {
  // Observable list to store quizzes
  late String userId;
  var quizzes = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    userId = Get.arguments['userId'];
  }
  
  // Add a new quiz to the list
  void addQuiz(Map<String, dynamic> quiz) {
    print('Adding quiz: $quiz');
    quizzes.add(quiz); // Adds the quiz to the list
  }

  // Delete a quiz from the list
  void deleteQuiz(Map<String, dynamic> quiz) {
    print('Deleting quiz: $quiz');
    deleteQuizFromBackend(userId, quiz['id']);
    quizzes.remove(quiz); // Removes the quiz from the list
  }
  // Fetch quizzes from the backend (not implemented yet)
  Future<void> fetchQuizzesFromBackend() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/data/get_quizzes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}), // Replace with actual user ID
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        quizzes.value = List<Map<String, dynamic>>.from(data['quizzes']);
      } else {
        print('Failed to fetch quizzes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching quizzes: $e');
    }
  }
  Future<void> generateQuizzes(String notesId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/data/generate_quiz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'notes_id': notesId, 'user_id': userId}),
      );
      if (response.statusCode == 200) {
        print('Quiz Generated successfully');
      } else {
        print('Failed to generate quiz: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating quiz: $e');
    }
  }

Future<Map<String, dynamic>> submit_quiz(int quizId, List<Map<String, dynamic>> answers) async {
  try {
    final body = {
      'user_id': userId,
      'quiz_id': quizId,
      'answers': answers,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/data/submit_quiz'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('RESPONSE BODY: ${response.body}');
      final responseData = jsonDecode(response.body);

      if (responseData.containsKey('feedbacks')) {
        List<Map<String, dynamic>> feedbacks = List<Map<String, dynamic>>.from(
          responseData['feedbacks'].map((feedback) {
            return {
              'question': feedback['question_text'] ?? 'No question',
              'user_answer': feedback['user_answer'] ?? 'No answer',
              'expected_answer': feedback['correct_answer'] ?? 'No expected answer',
              'explanation': feedback['explanation'] ?? 'No explanation available',
              'feedback': feedback['feedback'] ?? 'No feedback available',
              'question_id': feedback['question_id']?.toString() ?? 'No ID',
            };
          }),
        );

        if (feedbacks.isEmpty) {
          print('No feedbacks available.');
        }

        for (var feedback in feedbacks) {
          print('Question: ${feedback['question']}');
          print('User Answer: ${feedback['user_answer']}');
          print('Explanation: ${feedback['explanation']}');
        }

        return {
          'feedbacks': feedbacks,
        };
      } else {
        return {'error': 'No results available'};
      }
    } else {
      return {
        'error': 'Failed to submit quiz. Status code: ${response.statusCode}'
      };
    }
  } catch (e) {
    print('Error submitting quiz: $e');
    return {
      'error': 'An error occurred. Please check your connection.'
    };
  }
}


  Future<void> deleteQuizFromBackend(String userId, int quizId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/data/delete_quiz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'quiz_id': quizId}),
      );

      if (response.statusCode == 200) {
        print('Quiz deleted successfully from backend');
      } else {
        print('Failed to delete quiz: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting quiz: $e');
    }
  }
}
