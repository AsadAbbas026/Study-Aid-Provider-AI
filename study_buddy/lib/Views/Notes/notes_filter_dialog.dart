import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:study_buddy/Controller/notes_controller.dart';

class NotesFilterDialog extends StatefulWidget {
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final Function(DateTime?) onStartDateChanged;
  final Function(DateTime?) onEndDateChanged;
  final ValueNotifier<String?> selectedNoteType; // Track selected note type

  const NotesFilterDialog({
    super.key,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.selectedNoteType, // Accept the notifier in the constructor
  });

  @override
  State<NotesFilterDialog> createState() {
    return _NotesFilterDialogState();
  }
}

class _NotesFilterDialogState extends State<NotesFilterDialog> {
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  final NotesController notesController = Get.put(NotesController());
  late String userId = notesController.userId;
  @override
  void initState() {
    super.initState();
    // Initialize controllers with the initial values
    startDateController = TextEditingController(
      text: widget.selectedStartDate == null
          ? "dd/MM/yyyy"
          : _formatDate(widget.selectedStartDate!),
    );
    endDateController = TextEditingController(
      text: widget.selectedEndDate == null
          ? "dd/MM/yyyy"
          : _formatDate(widget.selectedEndDate!),
    );
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey.shade300,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.all(16.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Get.back(),
                ),
              ),
              SizedBox(height: 8.h),
              Text("Tags"),
              SizedBox(height: 6.h),
              _buildStyledTextField("Enter Tags"),
              SizedBox(height: 12.h),
              Text("Title"),
              SizedBox(height: 6.h),
              _buildStyledTextField("Enter Title"),
              SizedBox(height: 12.h),
              Text("Start Date"),
              SizedBox(height: 6.h),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: widget.selectedStartDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    widget.onStartDateChanged(picked); // Update start date
                    startDateController.text =
                        _formatDate(picked); // Update controller text
                  }
                },
                child: AbsorbPointer(
                  child: _buildStyledTextField(
                    startDateController.text,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text("End Date"),
              SizedBox(height: 6.h),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: widget.selectedEndDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    widget.onEndDateChanged(picked); // Update end date
                    endDateController.text =
                        _formatDate(picked); // Update controller text
                  }
                },
                child: AbsorbPointer(
                  child: _buildStyledTextField(
                    endDateController.text,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text("Note Type"),
              ValueListenableBuilder<String?>(
                valueListenable: widget.selectedNoteType,
                builder: (context, selectedType, child) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Radio<String?>(
                            value: 'Manual',
                            groupValue: selectedType,
                            onChanged: (value) {
                              if (value != null) {
                                widget.selectedNoteType.value = value;
                              }
                            },
                          ),
                          Text("Manual"),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String?>(
                            value: 'Transcribed',
                            groupValue: selectedType,
                            onChanged: (value) {
                              if (value != null) {
                                widget.selectedNoteType.value = value;
                              }
                            },
                          ),
                          Text("Transcribed"),
                        ],
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 16.h),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    notesController.filterNotes(
                      userId: userId,
                      startDate: widget.selectedStartDate,
                      endDate: widget.selectedEndDate,
                      noteType: widget.selectedNoteType.value,
                    );
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  child: const Text(
                    "Apply",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledTextField(String hint) {
    return TextField(
      controller: TextEditingController(text: hint), // Set controller
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}
