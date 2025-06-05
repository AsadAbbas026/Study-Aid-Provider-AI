import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:study_buddy/Utils/config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:study_buddy/Views/Reminders/reminder_model.dart';
import 'package:study_buddy/Controller/reminder_controller.dart';

class DashboardController extends GetxController {
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  late String userId;
  var isRecording = false.obs;
  var isTranscribing = false.obs;
  var buttonText = "Start Recording".obs;
  var buttonIcon = Icons.mic.obs;
  var transcriptionText = ''.obs;
  var translated_Text = ''.obs;
  late TextEditingController textEditingController;
  late RemindersController reminderController; // This was not initialized, causing the error
  late Reminder globalReminder;

  String? filePath;
  RxString selectedAudioFileName = ''.obs;

  // Constructor now safely initializes userId
  DashboardController({required String? userId}) : userId = userId ?? 'default_user_id';

  @override
  void onInit() {
    super.onInit();
    // Ensure reminderController is initialized here
    // Ensure userId is set from Get.arguments
    userId = Get.arguments['userId'] ?? 'default_user_id'; // Fixed issue where 'user_id' might not be in Get.arguments
    print("User ID: $userId");
    textEditingController = TextEditingController();

    // Auto sync text field with transcription
    transcriptionText.listen((value) {
      textEditingController.text = value;
    });

    // Ensure permissions are requested
    _requestPermissions();
  }

  /// Upload audio to `/upload_audio` endpoint
  Future<void> uploadAudio(File audioFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/data/upload_audio'));
      request.files.add(await http.MultipartFile.fromPath('file', audioFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        print("✅ Audio uploaded successfully");
      } else {
        print("❌ Upload failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error uploading audio: $e");
    }
  }

  Future<void> transcribeAudio() async {
    try {
      var response = await http.post(Uri.parse('$baseUrl/api/data/transcribe'));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        translated_Text.value = jsonResponse['translated_text'];
        transcriptionText.value = jsonResponse['transcription'];
        print("✅ Transcription: ${jsonResponse['transcription']}");

        await sendTextToServer(transcriptionText.value);
        print("✅ Text sent to server successfully");

        // Ensure reminderController is initialized before calling fetchRemindersFromAPI
        
        if (transcriptionText.value.isNotEmpty &&
            (transcriptionText.value.toLowerCase().contains('reminder') ||
            transcriptionText.value.toLowerCase().contains('assignment') ||
            transcriptionText.value.toLowerCase().contains('quiz'))
        ) {
          // Call API and get updated cleaned transcription
          final updatedTranscription = await reminderController.fetchRemindersFromAPI(
            transcriptionText.value,
            userId,
          );

          // If cleaned transcription was returned, update transcriptionText
          if (updatedTranscription != null) {
            transcriptionText.value = updatedTranscription;
            print('🧹 Updated transcription: ${transcriptionText.value}');
          }
        }

        await createTranscribedNote();
        print("✅ Note created successfully");
      } else {
        print("❌ Transcription failed: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error in transcription: $e");
    }
  }

  Future<void> sendTextToServer(String text) async {
    final url = Uri.parse('$baseUrl/api/data/transcription');

    // Ensure that Get.arguments contains 'user_id'
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text, 'user_id': userId}),
      );

      if (response.statusCode == 200) {
        print('Success: ${response.body}');
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception during POST: $e');
    }
  }

  Future<void> createTranscribedNote() async {
    try {
      final url = Uri.parse('$baseUrl/api/data/create_transcribed_note');
      // final response = await http.post(url,headers: {'Content-Type': 'application/json'},body: '{}');
      
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Note created successfully");
      } else {
        print("❌ Note creation failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error creating note: $e");
    }
  }

  Future<void> sendAudioFiletoServer(String filePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/data/get_audio'));
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();

      if (response.statusCode == 200) {
        print("✅ Audio uploaded successfully");
      } else {
        print("❌ Upload failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error uploading audio: $e");
    }
  }

  Future<void> _requestPermissions() async {
    var status = await [
      Permission.microphone,
      Permission.storage,
    ].request();

    if (await Permission.manageExternalStorage.isDenied) {
      var storageStatus = await Permission.manageExternalStorage.request();
      if (storageStatus.isDenied || storageStatus.isPermanentlyDenied) {
        Get.snackbar("Permission Required", "Please enable storage permissions from settings.");
        await openAppSettings();
      }
    }
  }

  /// Toggle between recording and transcription states
  Future<void> toggleRecording() async {
    if (!isRecording.value && !isTranscribing.value) {
      // Step 1: Start Recording
      await startRecording();

    } else if (isRecording.value) {
      // Step 2: Stop Recording and Upload
      await stopRecording();

    } else if (isTranscribing.value) {
      // Step 3: Start Transcribing
      await transcribeAudio();

      // Reset button for next round
      buttonText.value = "Start Recording";
      buttonIcon.value = Icons.mic;
      isTranscribing.value = false;
    }
  }

  /// Start audio recording and save to Study Buddy directory
  Future<void> startRecording() async {
    bool hasPermission = await _audioRecorder.hasPermission();
    bool hasManagePermission = await Permission.manageExternalStorage.isGranted;

    if (hasPermission && hasManagePermission) {
      String dirPath = '/storage/emulated/0/Study Buddy/Recordings';
      Directory directory = Directory(dirPath);

      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      if (directory.existsSync()) {
        filePath = '$dirPath/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
        await _audioRecorder.start(const RecordConfig(), path: filePath!);

        buttonText.value = "Stop Recording";
        buttonIcon.value = Icons.stop;
        isRecording.value = true;
        Get.snackbar("Recording Started", "Recording in progress...");
      } else {
        Get.snackbar("Directory Error", "Failed to create directory at: $dirPath");
      }
    } else {
      Get.snackbar("Permission Denied", "Please enable all required permissions.");
    }
  }

  /// Stop recording, upload audio, and prepare for transcription
  Future<void> stopRecording() async {
    await _audioRecorder.stop();
    isRecording.value = false;
    isTranscribing.value = true;

    if (filePath != null) {
      await uploadAudio(File(filePath!));  // Call /upload_audio
    } else {
      Get.snackbar("Error", "No file recorded!");
    }

    buttonText.value = "Start Transcribing";
    buttonIcon.value = Icons.text_fields;
    Get.snackbar("Recording Saved", "File saved at: $filePath");
  }

  /// Called when "Start Transcribing" is tapped
  Future<void> handleTranscriptionTap() async {
    if (isTranscribing.value) {
      await transcribeAudio();  // Call /transcribe
    }
  }

  Future<void> pickWavFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav', 'm4a', 'mp3'],
    );

    if (result != null && result.files.single.path != null) {
      selectedAudioFileName.value = result.files.single.name;
      await sendAudioFiletoServer(result.files.single.path!);
      buttonText.value = "Start Transcribing";
      buttonIcon.value = Icons.text_fields;
      isTranscribing.value = true;
      if (buttonText.value == "Start Transcribing" && isTranscribing.value) {
        await transcribeAudio();
        selectedAudioFileName.value = '';
        buttonText.value = "Start Recording";
        buttonIcon.value = Icons.mic;
        isTranscribing.value = false;
      }
    } else {
      selectedAudioFileName.value = '';
    }
  }

  @override
  void onClose() {
    _audioRecorder.dispose();
    super.onClose();
  }
}
