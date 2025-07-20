import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'scan_notes.dart';
import 'package:study_buddy/Controller/notes_controller.dart';
import 'package:study_buddy/Views/Notes/flashcards_screen.dart';

class NotesDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> note;

  const NotesDetailsScreen({super.key, required this.note});

  @override
  State<NotesDetailsScreen> createState() => _NotesDetailsScreenState();
}

class _NotesDetailsScreenState extends State<NotesDetailsScreen> {
  final TextEditingController _descController = TextEditingController();
  final NotesController notesController = Get.find();
  bool _isEditing = false;
  bool _showFlashcardButton = false;

  @override
  void initState() {
    super.initState();
    _descController.text = widget.note['desc'] ?? '';
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 171, 71, 188),
        title: Text(
          widget.note['title'] ?? "Untitled",
          style: TextStyle(fontSize: 20.sp, color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'delete') {
                notesController.handleDelete(widget.note['note_id']);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete Note'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () async {
              final noteId = widget.note['note_id'];
              final firebaseKey = await notesController.shareNoteToRTDB(noteId);
              if (firebaseKey != null) {
                final qrData = firebaseKey;
                Get.dialog(
                  QRScreen(qrData: qrData),
                  barrierDismissible: true,
                );
              } else {
                Get.snackbar("Error", "Failed to share the note.");
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),

            // Note Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 252, 228, 236),
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and buttons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.note['title'] ?? "Untitled",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (!_isEditing)
                        SizedBox(
                          width: 48.w,
                          child: Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: "Edit Note",
                                onPressed: () => setState(() {
                                  _isEditing = true;
                                }),
                              ),
                              Obx(() {
                                bool isVisible = notesController.flashcardVisibility[widget.note['note_id'].toString()] ?? false;
                                return isVisible
                                    ? IconButton(
                                        icon: const Icon(Icons.sticky_note_2, color: Colors.blue),
                                        tooltip: "View Flashcards",
                                        onPressed: () {
                                          showFlashcardsOverlay(context, widget.note['note_id'].toString());
                                        },
                                      )
                                    : const SizedBox(); // returns an empty widget if not visible
                              }),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // Note Content
                  _isEditing
                      ? TextField(
                          controller: _descController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: "Edit your note...",
                            border: OutlineInputBorder(),
                          ),
                        )
                      : Text(
                          widget.note['desc'] ?? "No description available",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black,
                          ),
                        ),
                ],
              ),
            ),

            // Save Button
            if (_isEditing)
              Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: ElevatedButton(
                  onPressed: () {
                    notesController.handleUpdate(widget.note, _descController.text);
                    setState(() {
                      widget.note['desc'] = _descController.text;
                      _isEditing = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 171, 71, 188),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: const Text("Save"),
                ),
              ),
          ],
        ),
      ),
    );
  }
  void showFlashcardsOverlay(BuildContext context, String noteId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.grey[200],
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.65,
        child: FlashcardOverlay(noteId: noteId),
      ),
    );
  }
}
