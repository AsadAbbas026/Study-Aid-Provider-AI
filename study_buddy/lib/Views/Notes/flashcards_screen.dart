import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:study_buddy/Controller/notes_controller.dart';

class FlashcardOverlay extends StatelessWidget {
  final String noteId;
  FlashcardOverlay({required this.noteId});

  final List<Color> cardColors = [
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.teal.shade100,
    Colors.pink.shade100,
  ];

  @override
  Widget build(BuildContext context) {
    final NotesController controller = Get.find();

    return Obx(() {
      final flashcards = controller.flashcardList;

      if (flashcards.isEmpty) {
        return Center(child: Text("No flashcards available for this note."));
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: PageView.builder(
          itemCount: flashcards.length,
          controller: PageController(viewportFraction: 0.85),
          itemBuilder: (context, index) {
            final card = flashcards[index];
            final color = cardColors[index % cardColors.length];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card['heading'] ?? '',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          card['note'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
