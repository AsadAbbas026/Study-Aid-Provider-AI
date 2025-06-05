import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:study_buddy/Utils/config.dart';

class GoalController extends GetxController {
  RxList<Map<String, String>> goals = <Map<String, String>>[].obs;
  RxMap<String, List<bool>> milestoneCompletion = <String, List<bool>>{}.obs;
  RxList<Map<String, dynamic>> milestones = <Map<String, dynamic>>[].obs;
  late String userId;

  @override
  void onInit() {
    super.onInit();
    userId = Get.arguments['userId'];
    print("User ID: $userId");
    loadAllMilestoneStates(); // Load all saved states when controller initializes
  }

  Future<void> saveMilestoneState(String goalTitle) async {
    final prefs = await SharedPreferences.getInstance();
    if (milestoneCompletion.containsKey(goalTitle)) {
      await prefs.setStringList(
        'milestone_$goalTitle',
        milestoneCompletion[goalTitle]!.map((e) => e.toString()).toList(),
      );
    }
  }

  Future<void> loadMilestoneState(String goalTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('milestone_$goalTitle');
    if (stored != null) {
      milestoneCompletion[goalTitle] = stored.map((e) => e == 'true').toList();
      milestoneCompletion.refresh();
    }
  }

  Future<void> loadAllMilestoneStates() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('milestone_'));
    
    for (var key in keys) {
      final goalTitle = key.replaceFirst('milestone_', '');
      final stored = prefs.getStringList(key);
      if (stored != null) {
        milestoneCompletion[goalTitle] = stored.map((e) => e == 'true').toList();
      }
    }
    milestoneCompletion.refresh();
  }

  Future<void> clearMilestoneState(String goalTitle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('milestone_$goalTitle');
    milestoneCompletion.remove(goalTitle);
    milestoneCompletion.refresh();
  }

  void addGoal(String title, String desc) async {
    print("addGoal called");
    final goalData = {
      'user_id': userId,
      'title': title,
      'description': desc,
    };

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/data/add_goal"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(goalData),
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final newGoalId = responseData['goal_id'].toString();

        goals.add({
          'id': newGoalId,
          'title': title,
          'description': desc,
        });
        
        await generateMilestones(newGoalId, userId);
        
        // Initialize completion state and load any existing state
        if (!milestoneCompletion.containsKey(title)) {
          milestoneCompletion[title] = List<bool>.filled(5, false);
          await loadMilestoneState(title); // Load saved state if exists
        }
        
        Get.snackbar("Success", "Goal added successfully");
      } else {
        Get.snackbar("Error", "Failed to add goal: ${response.body}");
      }
    } catch (e) {
      print("Exception in addGoal: $e");
      Get.snackbar("Error", "Exception: $e");
    }
  }

  void removeGoal(int index) async {
    final goal = goals[index];
    final title = goal['title'];
    if (title != null) {
      await clearMilestoneState(title);
    }
    await deleteGoal(goal['id'].toString());
    goals.removeAt(index);
  }

  void updateMilestone(String title, int milestoneIndex, bool isComplete) async {
    if (!milestoneCompletion.containsKey(title)) {
      milestoneCompletion[title] = List<bool>.filled(5, false);
    }
    
    milestoneCompletion[title]![milestoneIndex] = isComplete;
    await saveMilestoneState(title);
    milestoneCompletion.refresh();

    final milestones = milestoneCompletion[title]!;
    int completedCount = milestones.where((m) => m).length;
    int percentage = ((completedCount / milestones.length) * 100).round();

    await updateGoalPercentageOnServer(title, percentage);
  }

  double getProgress(String title) {
    if (!milestoneCompletion.containsKey(title)) {
      return 0.0;
    }
    final milestones = milestoneCompletion[title]!;
    final completed = milestones.where((done) => done).length;
    return completed / milestones.length;
  }

  Future<void> fetchMilestones(String goalId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/data/get_milestones"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"goal_id": goalId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        milestones.value = List<Map<String, dynamic>>.from(data['milestones']);
      } else {
        print("Failed to load milestones: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> generateMilestones(String goalId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/data/generate_milestone"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "goal_id": goalId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        milestones.value = List<Map<String, dynamic>>.from(data['milestones']);
        print("Milestones generated successfully.");
      } else {
        print("Failed to generate milestones: ${response.body}");
      }
    } catch (e) {
      print("Error generating milestones: $e");
    }
  }

  Future<void> fetchAllGoals() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/data/get_all_goals"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> fetchedGoals = data['goals'];
        goals.assignAll(fetchedGoals.map((goal) => {
          'id': goal['id'].toString(),
          'user_id': goal['user_id'].toString(),
          'title': (goal['title'] ?? '').toString(),
          'description': (goal['description'] ?? '').toString(),
        }).toList());
      } else {
        print("Failed to load goals: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
  
  Future<void> deleteGoal(String goalId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/api/data/delete_goal"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"goal_id": goalId, "user_id": userId}),
      );

      if (response.statusCode == 200) {
        print("Goal deleted successfully.");
      } else {
        print("Failed to delete goal: ${response.body}");
      }
    } catch (e) {
      print("Error deleting goal: $e");
    }
  }
  Future<void> updateGoalPercentageOnServer(String title, int percentage) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/data/update_goal_percentage'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'percentage': percentage}),
      );

      if (response.statusCode == 200) {
        print('Percentage updated successfully');
      } else {
        print('Failed to update percentage: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
