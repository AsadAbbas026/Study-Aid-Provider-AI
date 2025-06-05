import 'package:get/get.dart';
import 'package:study_buddy/Views/Reminders/reminder_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:study_buddy/Utils/config.dart';
import 'dart:async'; // Add this
import 'package:intl/intl.dart'; // For parsing date & time
import 'package:flutter/material.dart'; // For snackbar

class RemindersController extends GetxController {
  var reminders = <Reminder>[].obs;
  final List<Timer> _timers = []; // To keep track of timers
  late String userId;
  @override
  void onInit() {
    super.onInit();
    userId = Get.arguments['userId'];
  }

  void addReminder(Reminder reminder) async{
    reminders.add(reminder);
    await uploadReminderToAPI(reminder);
    _scheduleReminderNotification(reminder);
  }

  void deleteReminder(Reminder reminder) {
    reminders.remove(reminder);
    _cancelReminder(reminder);
  }

  /// Updated to return the cleaned transcription
  Future<String?> fetchRemindersFromAPI(String transcriptionValue, String userId) async {
    final String apiUrl = '$baseUrl/api/data/create_reminder';

    try {
      final url = Uri.parse(apiUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "transcription_data": transcriptionValue,
          "user_id": userId,
        }),
      );

      print('📡 API called at $apiUrl');
      print('📨 Payload: transcription=$transcriptionValue, userID=$userId');
      print('🔄 Response Status: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Update reminders list
        if (data['reminders'] != null && data['reminders'] is List) {
          final List<dynamic> reminderList = data['reminders'];
          reminders.clear();
          for (var item in reminderList) {
            reminders.add(Reminder(
              title: item['title'] ?? 'No Title',
              description: item['description'] ?? '',
              date: item['date'] ?? '',
              time: item['time'] ?? '',
            ));
          }
          Get.snackbar('Success', 'Reminders loaded successfully');
        } else {
          Get.snackbar('Warning', 'No reminders found');
        }

        // ✅ Return the updated cleaned transcription
        if (data['cleaned_transcription'] != null) {
          return data['cleaned_transcription'];
        } else {
          print('⚠️ No cleaned transcription found in response.');
          return null;
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch reminders');
        return null;
      }
    } catch (e) {
      print('🔥 Exception occurred: $e');
      Get.snackbar('Error', 'An error occurred while fetching reminders');
      return null;
    }
  }
  Future<void> getRemindersFromAPI(String userId) async {
    final String apiUrl = '$baseUrl/api/data/get_reminders?user_id=$userId';

    try {
      final url = Uri.parse(apiUrl);
      final response = await http.get(url);

      print('📡 GET Reminders API: $apiUrl');
      print('🔄 Response Status: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['reminders'] != null && data['reminders'] is List) {
          final List<dynamic> reminderList = data['reminders'];
          reminders.clear();

          for (var item in reminderList) {
            reminders.add(Reminder(
              title: item['title'] ?? 'No Title',
              description: item['description'] ?? '',
              date: item['date'] ?? '',
              time: item['time'] ?? '',
            ));
          }

          print('✅ ${reminders.length} reminders fetched and added');
          Get.snackbar('Success', 'Reminders refreshed successfully');
        } else {
          print('⚠️ No reminders found');
          Get.snackbar('Info', 'No reminders found for this user');
        }
      } else {
        print('❌ Server error: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to fetch reminders');
      }
    } catch (e) {
      print('🔥 Exception occurred: $e');
      Get.snackbar('Error', 'Error fetching reminders');
    }
  }
  Future<void> uploadReminderToAPI(Reminder reminder) async {
    final String apiUrl = '$baseUrl/api/data/save_reminder';

    try {
      final url = Uri.parse(apiUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": userId, // Assuming you added userId inside Reminder model
          "title": reminder.title,
          "description": reminder.description,
          "date": reminder.date,
          "time": reminder.time,
        }),
      );

      print('📤 Sent reminder: ${reminder.title}');
      print('🔄 Response Status: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode != 200) {
        Get.snackbar('Error', 'Failed to upload reminder: ${reminder.title}');
      } else {
        Get.snackbar('Success', 'Reminder uploaded: ${reminder.title}');
      }
    } catch (e) {
      print('🔥 Exception occurred: $e');
      Get.snackbar('Error', 'An error occurred while uploading reminder: ${reminder.title}');
    }
  }

  void _scheduleReminderNotification(Reminder reminder) {
    try {
      DateTime reminderDateTime = DateFormat('dd/MM/yyyy hh:mm a').parse(
        "${reminder.date} ${reminder.time}",
      );

      DateTime now = DateTime.now();

      if (reminderDateTime.isBefore(now)) {
        // Reminder time has already passed
        return;
      }

      // Start checking every 5 minute
      Timer periodicTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
        DateTime currentTime = DateTime.now();
        Duration timeUntilReminder = reminderDateTime.difference(currentTime);

        if (timeUntilReminder.inMinutes <= 60 && timeUntilReminder.inMinutes > 0) {
          // If the event is within 1 hour, show the alert again and again
          Get.snackbar(
            "Reminder Alert 🚨",
            "Your reminder for '${reminder.title}' is due in ${timeUntilReminder.inMinutes} minutes!",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.yellow,
            colorText: Colors.black,
            duration: const Duration(seconds: 5),
          );
        } else if (timeUntilReminder.inMinutes <= 0) {
          // Time has reached or passed, stop the timer
          timer.cancel();
          Get.snackbar(
            "⏰ Reminder Time!",
            "It's time for '${reminder.title}' now!",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        }
      });

      _timers.add(periodicTimer);
    } catch (e) {
      print("Failed to schedule repeated reminder: $e");
    }
  }


  void _cancelReminder(Reminder reminder) {
    // Currently simple: cancel all timers and reschedule
    for (var timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    for (var remainingReminder in reminders) {
      _scheduleReminderNotification(remainingReminder);
    }
  }

  @override
  void onClose() {
    for (var timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    super.onClose();
  }
}


