import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/Controller/notes_controller.dart';
import 'package:study_buddy/Utils/custom_app_bar.dart';
import 'package:study_buddy/Utils/custom_side_menu.dart';
import 'package:study_buddy/Views/Notes/add_new_note.dart';
import 'package:study_buddy/Views/Notes/notes_details_screen.dart';
import 'package:study_buddy/Views/Notes/notes_filter_dialog.dart';
import 'package:study_buddy/Views/Notes/qr_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  ValueNotifier<String?> selectedNoteType = ValueNotifier<String?>(null);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  //TextEditingController _searchController = TextEditingController();
  final NotesController notesController = Get.find<NotesController>();
  late String userId = notesController.userId;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  // Add a flag to check if the app is newly opened
  bool isAppOpenedRecently = true; // Track if it's recently opened or not

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: CustomSideMenu(userId: userId),
        appBar: CustomAppBar(userId: userId,
          title: "Notes",
          scaffoldKey: _scaffoldKey,
        ),
        body: _buildBody(),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  Widget _buildFAB() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'qrBtn',
          backgroundColor: const Color.fromARGB(255, 217, 217, 217),
          onPressed: () {
            Get.dialog(QrScannerDialog(receiverUserId: userId,));
          },
          child: const Icon(Icons.qr_code_scanner, color: Colors.black),
        ),

        SizedBox(width: 16.w), // spacing between buttons

        // Existing "+" button
        FloatingActionButton(
          heroTag: 'addBtn',
          backgroundColor: const Color.fromARGB(255, 217, 217, 217),
          onPressed: () {
            Get.dialog(AddNoteDialog(), barrierDismissible: false);
          },
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 171, 71, 188),
            Color.fromARGB(255, 252, 228, 236),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Column(
        children: [
          _buildSearchBar(),
          SizedBox(height: 12.h),
          Expanded(child: _buildNotesList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (query) {
              // Perform the search when the query changes
              if (query.isNotEmpty) {
                notesController.searchNotes(query); // Call your controller's search function
              } else {
                notesController.fetchNotesFromBackend(); // Optional: Reset search if the query is empty
              }
            },
            decoration: InputDecoration(
              hintText: "Search notes here...",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(color: Colors.black, width: 1.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(color: Colors.blue, width: 2.w),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
            ),
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
        SizedBox(width: 8.w),
        IconButton(
          icon: Icon(Icons.filter_alt_outlined, color: Colors.black, size: 24.sp),
          onPressed: () {
            Get.dialog(
              NotesFilterDialog(
                selectedStartDate: selectedStartDate,
                selectedEndDate: selectedEndDate,
                onStartDateChanged: (date) =>
                    setState(() => selectedStartDate = date),
                onEndDateChanged: (date) =>
                    setState(() => selectedEndDate = date),
                selectedNoteType: selectedNoteType,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotesList() {
    return Obx(() {
      // Check if the notes are empty and if the app is newly opened
      if (notesController.notes.isEmpty && isAppOpenedRecently) {
        return Center(
          child: Text(
            "No Notes Yet! Tap the '+' button to add your first Note.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24.sp, color: Colors.black),
          ),
        );
      } else if (notesController.notes.isEmpty) {
        return Center(
          child: Text(
            "No notes found matching your search.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24.sp, color: Colors.black),
          ),
        );
      }

      return ListView.builder(
        itemCount: notesController.notes.length,
        itemBuilder: (context, index) {
          return _buildNoteItem(notesController.notes[index]);
        },
      );
    });
  }

  Widget _buildNoteItem(Map<String, dynamic> note) {
    DateTime createdAt;

    try {
      if (note['createdAt'] is DateTime) {
        createdAt = note['createdAt'];
      } else if (note['createdAt'] is String) {
        createdAt = _parseDate(note['createdAt']);
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      createdAt = DateTime.now();
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: GestureDetector(
        onTap: () {
          // Navigate to the notes details screen
          Get.to(() => NotesDetailsScreen(note: note));
          print("Selected Note: ${note['note_id']}");
        },
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((25.5).toInt()),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note['title'] ?? "Untitled",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Date: ${DateFormat('dd/MM/yyyy').format(createdAt)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      'Time: ${DateFormat('hh:mm a').format(createdAt)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      note['desc'] ?? "No description",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // In NotesScreen, when generating summaries
            PopupMenuButton<String>(
              icon: Icon(Icons.settings, color: Colors.black),
              onSelected: (value) async {
                print("Selected Note: ${note['note_id']}" "${note['title']} " "${note['desc']}");
                if (value == 'generate_summary') {
                  // Get the selected note and add it to the SummariesController
                  await notesController.createSummaries(note);
                } 
                else if (value == 'access quiz') {
                  // Navigate to the quiz screen
                  await notesController.createQuiz(note);
                }
                else if (value == 'generate_flashcards') {
                  await notesController.generateFlashcards(note['note_id'].toString());
                  // Navigate to the flashcards screen
                  notesController.showFlashcardFor(note['note_id'].toString());
                  // await notesController.createFlashcards(note);
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(value: 'generate_summary', child: Text('Generate Summaries')),
                PopupMenuDivider(),
                PopupMenuItem<String>(value: 'access quiz', child: Text('Generate Quiz')),
                PopupMenuDivider(),
                PopupMenuItem<String>(value: 'generate_flashcards', child: Text('Generate Flashcards')),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Helper function to parse the date from different formats
  DateTime _parseDate(String dateStr) {
    DateTime dateTime;

    try {
      // Try parsing with one format first
      dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateStr);
    } catch (e) {
      try {
        // If the first format fails, try another format
        dateTime = DateFormat('yyyy-MM-dd').parse(dateStr);
      } catch (e) {
        // If all parsing fails, return the current date and time
        dateTime = DateTime.now();
      }
    }

    return dateTime;
  }
}
