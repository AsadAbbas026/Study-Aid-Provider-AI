import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:study_buddy/Utils/config.dart';
import 'package:study_buddy/Controller/summaries_controller.dart';
import 'package:study_buddy/Controller/quiz_controller.dart';
  
class NotesController extends GetxController {
  var notes = <Map<String, dynamic>>[].obs; // Observable list of notes
  var allNotes = <Map<String, dynamic>>[].obs; // Store all notes for resetting the search
  late String userId;
  RxMap<String, bool> flashcardVisibility = <String, bool>{}.obs;
  var flashcardList = <Map<String, String>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    userId = Get.arguments['userId'];
    fetchNotesFromBackend();
  }

  void addManualNote(Map<String, dynamic> note) async {
    final noteToSend = {
      'time': DateTime.now().millisecondsSinceEpoch,
      'title': note['title'],
      'desc': note['desc'],
      'createdAt': getCurrentDateTime(),
      'type': 'Manual',
      'user_id': userId,
    };

    final savedNote = await sendNoteToBackend(noteToSend);

    if (savedNote != null) {
      notes.add(savedNote); // ✅ make sure this is the updated note with note_id
      update();
      print("Saved note locally with ID: ${savedNote['note_id']}");
    } else {
      print("Note not added – backend error");
    }
  }

  Future<void> updateNote(Map<String, dynamic> updatedNote) async {
    try {
      final url = Uri.parse('$baseUrl/api/data/update_note');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedNote),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Update local state
        final index = notes.indexWhere((n) => n['id'] == updatedNote['id']);
        if (index != -1) {
          notes[index] = {...notes[index], 'content': updatedNote['content']};
          update();
        }
        fetchNotesFromBackend();
      } else {
        Get.snackbar(
          'Update Failed',
          'Error: ${response.statusCode} - ${response.body}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withAlpha((255 * 0.8).toInt()),
        );
      }
    } catch (e) {
      print('Error updating note: $e');
      Get.snackbar(
        'Update Failed',
        'Network error: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withAlpha((255 * 0.8).toInt()),
      );
    }
  }

  void deleteNote(int noteId) async {
    // Fix here: use 'note_id' instead of 'id'
    notes.removeWhere((note) => note['note_id'] == noteId);
    update();

    final url = Uri.parse('$baseUrl/api/data/delete_note');

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': noteId, 'user_id': userId}), // Backend expects 'id', so this is fine
      );

      if (response.statusCode == 200) {
        print("Note deleted successfully");
      } else {
        print("Failed to delete note: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Error while deleting note: $e");
    }
  }

  void handleUpdate(Map<String, dynamic> note, String updatedDesc) async {
    final updatedNote = {
      'id': note['id'] ?? note['note_id'], // Handle both cases
      'user_id': userId,
      'title': note['title'],
      'content': updatedDesc,
      // Remove createdAt and type as Flask doesn't use them
    };
    await updateNote(updatedNote);
    print("Update process completed.");
    Get.snackbar(
      'Note Updated',
      'Changes saved successfully',
      snackPosition: SnackPosition.TOP,
      backgroundColor:
          const Color.fromRGBO(0, 150, 136, 1).withAlpha((255 * 0.8).toInt()),
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }

  void handleDelete(int? noteId) {
    if (noteId != null) {
      deleteNote(noteId);
      Get.back(); // Navigate back
      Get.snackbar(
        'Success',
        'Note deleted successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromARGB(255, 76, 175, 80)
            .withAlpha((255 * 0.8).toInt()),
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } else {
      Get.snackbar(
        'Error',
        'Note ID is null. Cannot delete!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromARGB(255, 244, 67, 54)
            .withAlpha((255 * 0.8).toInt()),
        colorText: Get.theme.colorScheme.onPrimary,
      );
    }
  }

  String formatDateForApi(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}"
          "-${date.month.toString().padLeft(2, '0')}"
          "-${date.day.toString().padLeft(2, '0')}";
  }

  String getCurrentDateTime() {
    final now = DateTime.now();
    return DateFormat('dd/MM/yyyy HH:mm').format(now);
  }

  void showFlashcardFor(String noteId) {
    flashcardVisibility[noteId] = true;
  }

  Future<Map<String, dynamic>?> sendNoteToBackend(Map<String, dynamic> note) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/data/add_note'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(note),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Add the note_id to the original note map
        note['note_id'] = responseData['note_id'];

        print("Note sent successfully with ID: ${note['note_id']}");
        return note; // Return the complete note with ID now included
      } else {
        print("Failed to send note. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending note: $e");
    }

    return null;
  }

  void fetchNotesFromBackend() async {
    final url = Uri.parse('$baseUrl/api/data/get_notes');
    print(userId);
    try {
      final response = await http.post(url, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> fetchedNotes = jsonData['notes'];

        notes.value = fetchedNotes.cast<Map<String, dynamic>>(); // ✅ Corrected this line
        update();
      } else {
        print('Failed to load notes. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading notes: $e');
    }
  }

  void searchNotes(String query) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/data/search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'query': query}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['notes'];
        notes.value = data.cast<Map<String, dynamic>>(); // ✅ Corrected this line
        update();
      } else {
        Get.snackbar(
          'Search Failed',
          'Server error: ${response.statusCode}',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Search Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> filterNotes({required String userId, required DateTime? startDate, required DateTime? endDate, String? noteType}) async {
    final url = Uri.parse("$baseUrl/api/data/filter");

    final body = {
      'user_id': userId,
      'start_date': formatDateForApi(startDate!),
      'end_date': formatDateForApi(endDate!),
      if (noteType != null && noteType.isNotEmpty) 'note_type': noteType,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final notes = decoded['notes']; // List of notes
      // update UI or GetX observable list
    } else {
      print("Failed to filter notes: ${response.body}");
    }
  }

  Future<void> createSummaries(Map<String, dynamic> note) async {
    final summariesController = Get.find<SummariesController>();

    String noteId = note['note_id'].toString();
    String noteTitle = note['title'] ?? "Untitled";
    String noteDesc = note['desc'] ?? note['content'] ?? "No description";

    // Fetch the summary from backend
    String summaryText = await summariesController.fetchSummaryText(userId, noteId);

    // Check if valid
    if (summaryText.isEmpty || summaryText.contains('Failed')) {
      Get.snackbar("Error", "Summary generation failed.");
      return;
    }

    // Update reactive summary text for UI to pick up
    summariesController.summaryTexts[noteId] = summaryText;


    // Build the summary map (matching your UI screen expectations)
    Map<String, dynamic> summaryMap = {
      'id': noteId,
      'title': noteTitle,
      'desc': noteDesc,
      'summary': summaryText,
      'created_at': DateTime.now().toIso8601String(),
    };

    // Add to controller list
    summariesController.addSummary(summaryMap);

    // Navigate to summary screen
    Get.toNamed('/summariesScreen', arguments: {'summary_data': summaryMap, 'userId': userId});
  }

  Future<void> createQuiz(Map<String, dynamic> note) async {
    var quizText = ''.obs; // Initialize the quiz text observable
    final quizController = Get.find<QuizController>();

    String noteId = note['note_id'].toString();
    String noteTitle = note['title'] ?? "Untitled";
    String noteDesc = note['desc'] ?? note['content'] ?? "No description";

    // Prepare the request payload
    Map<String, dynamic> requestPayload = {
      'user_id': userId,
      'notes_id': noteId,
    };

    try {
      var response = await http.post(
        Uri.parse('$baseUrl/api/data/generate_quiz'),  // Update with your actual URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestPayload),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        Map<String, dynamic> quizData = data['quiz'];

        // Check if valid
        if (quizData.isEmpty) {
          Get.snackbar("Error", "Quiz generation failed.");
          return;
        }

        // Update reactive quiz text for UI to pick up
        //quizController.quizText.value = quizText;

        // Build the quiz map (matching your UI screen expectations)
        Map<String, dynamic> quizMap = {
          'id': quizData['id'],
          'title': quizData['title'],
          'desc': quizData['desc'],
          'created_at': quizData['created_at'],
          'questions': quizData['questions'], // <-- pass the actual quiz questions
        };

        // Add to controller list
        quizController.addQuiz(quizMap);

        // Navigate to quiz screen
        Get.toNamed('/quizScreen', arguments: {"quizMap": quizMap, "userId": userId});
      } else {
        // Handle error from backend
        Get.snackbar("Error", "Failed to generate quiz. Please try again.");
      }
    } catch (e) {
      // Handle any errors
      Get.snackbar("Error", "An error occurred: $e");
    }
  }
  Future<void> generateFlashcards(String noteId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/data/generate_flashcard'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'note_id': noteId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> flashcards = data['flashcards'];

        // ✅ Explicit casting
        final parsedFlashcards = flashcards
            .map<Map<String, String>>((item) => {
                  'heading': item['heading'].toString(),
                  'note': item['note'].toString(),
                })
            .toList();

        flashcardList.assignAll(parsedFlashcards);
      } else {
        Get.snackbar("Error", "Failed to generate flashcards");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }

  Future<String?> shareNoteToRTDB(int noteId) async {
    const String url = '$baseUrl/api/data/share_note_to_rtdb';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "note_id": noteId,
          "sender_user_id": userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['firebase_key']; // You can use this to generate QR
      } else {
        debugPrint("Share failed: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Error sharing note: $e");
      return null;
    }
  }

  Future<bool> importSharedNote(String firebaseKey, String receiverUserId) async {
    const String url = '$baseUrl/api/data/import_shared_note';
    print("Firebase Key: $firebaseKey");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "firebase_key": firebaseKey,
          "receiver_user_id": receiverUserId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode != 200) {
        debugPrint("Note imported successfully.");
        fetchNotesFromBackend(); // Refresh the notes from backend
        return true;
      } else {
        debugPrint("Import failed: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error importing note: $e");
      return false;
    }
  }
}
