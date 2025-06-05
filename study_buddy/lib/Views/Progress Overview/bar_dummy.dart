import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:study_buddy/Utils/config.dart';

class DailyGoal {
  final String? date;
  final double? goalPercentage;
  final String? title;
  final String? goalId;

  DailyGoal({
    required this.date,
    required this.goalPercentage,
    this.title,
    this.goalId,
  });

  factory DailyGoal.fromJson(Map<String, dynamic> json) {
    return DailyGoal(
      date: json['date'],
      goalPercentage: (json['goalPercentage'] as num).toDouble(),
      title: json['title'],
      goalId: json['goalId']?.toString(),
    );
  }
}

// Fetch daily goal progress from backend
Future<List<DailyGoal>> fetchDailyGoalProgress(String userId) async {
  final response = await http.get(Uri.parse('$baseUrl/api/data/goal_progress/$userId'));
  print("API Response: ${response.statusCode}, Body: ${response.body}");

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    List<DailyGoal> goals = data.map((goal) => DailyGoal.fromJson(goal)).toList();
    return goals;
  } else {
    throw Exception('Failed to load daily goal progress');
  }
}
