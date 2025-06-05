import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:study_buddy/Utils/config.dart';

class SummariesController extends GetxController {
  var summaries = <Map<String, dynamic>>[].obs;
  var summaryTexts = <String, String>{}.obs; // key: noteId, value: summary text
  late String userId;

  @override
  void onInit() {
    super.onInit();
    userId = Get.arguments['userId'];
  }
  Future<String> fetchSummaryText(String userId, String noteId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/data/generate_summary'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'note_id': noteId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawSummary = data['summary'];

        String summaryContent = '';
        if (rawSummary is String) summaryContent = rawSummary;
        else if (rawSummary is Map || rawSummary is List) summaryContent = rawSummary.toString();
        else summaryContent = 'Invalid format';

        summaryTexts[noteId] = summaryContent;
        return summaryContent; // ✅ this line is new
      } else {
        summaryTexts[noteId] = 'Failed to fetch summary';
        return 'Failed to fetch summary'; // ✅
      }
    } catch (e) {
      print('Error fetching summary: $e');
      summaryTexts[noteId] = 'Exception occurred';
      return 'Exception occurred'; // ✅
    }
  }

  Future<void> fetchSummariesFromBackend() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/data/get_summaries'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}), // Replace with actual user ID
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        summaries.value = List<Map<String, dynamic>>.from(data['summaries']);
      } else {
        print('Failed to fetch summaries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching summaries: $e');
    }
  }
  
  Future<void> deleteSummaryFromBackend(String summaryId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/data/delete_summary'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'summary_id': summaryId, 'user_id': userId}),
      );
      if (response.statusCode == 200) {
        print('Summary deleted successfully');
      } else {
        print('Failed to delete summary: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting summary: $e');
    }
  }

  void addSummary(Map<String, dynamic> summary) {
    summaries.add(summary);
    update();
  }

  void deleteSummary(int index) {
    final summaryId = summaries[index]['id'].toString(); // Get ID first
    summaries.removeAt(index); // Then remove
    deleteSummaryFromBackend(summaryId); // Pass string-safe ID
    update();
  }

}
