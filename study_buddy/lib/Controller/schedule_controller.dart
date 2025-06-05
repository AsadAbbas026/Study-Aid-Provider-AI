import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:study_buddy/Utils/config.dart';

class ScheduleController extends GetxController {
  final RxList<Map<String, dynamic>> schedules = <Map<String, dynamic>>[].obs;
  late String userId;

  @override
  void onInit() {
    super.onInit();
    userId = Get.arguments['userId'];
  }

  void addSchedules(String label, String desc, String dateTime) async {
    final ScheduleData = {
      'user_id': userId,
      'title': label,
      'description': desc,
      'date_time': dateTime,
    };

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/data/add_schedule"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ScheduleData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newScheduleId = responseData['schedule_id']; // Ensure backend returns this

        schedules.add({
          'id': newScheduleId.toString(),
          'label': label,
          'desc': desc,
          'dateTime': dateTime,
          'user_id': userId,
        });

        Get.snackbar("Success", "Study schedule added successfully");
      } else {
        Get.snackbar("Error", "Failed to add schedule: ${response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
    }
  }

  void deleteSchedule(Map<String, dynamic> schedule, int index) {
    print('Deleting schedule: $schedule');

    final scheduleId = schedule['id'];

    if (scheduleId == null) {
      print("Missing schedule ID or user ID. Cannot delete.");
      Get.snackbar("Error", "Invalid schedule ID or user.");
      return;
    }

    deleteScheduleFromBackend(scheduleId.toString(), userId.toString()).then((_) {
      schedules.removeAt(index); // Remove only after successful deletion
      Get.snackbar("Deleted", "Schedule removed successfully");
    });
  }

  Future<void> fetchSchedules() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/data/get_schedules"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> fetchedSchedules = data['schedule_list'];

        schedules.assignAll(fetchedSchedules.map((schedule) => {
          'id': schedule['id'].toString(),
          'label': (schedule['title'] ?? '').toString(),
          'desc': (schedule['description'] ?? '').toString(),
          'dateTime': "${schedule['date'] ?? ''} ${schedule['time'] ?? ''}",
          'user_id': userId.toString(),
        }).toList());
      } else {
        Get.snackbar("Error", "Failed to fetch schedules");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
    }
  }

  Future<void> deleteScheduleFromBackend(String scheduleId, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/data/delete_schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'schedule_id': scheduleId,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        print('Schedule deleted successfully from backend');
      } else {
        print('Failed to delete schedule: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting schedule: $e');
    }
  }
}
