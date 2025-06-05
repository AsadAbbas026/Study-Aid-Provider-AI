import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StudyScheduleDialog extends StatefulWidget {
  final TextEditingController labelController;
  final TextEditingController descriptionController;

  final void Function(String label, String desc, String dateTime) onSave;

  const StudyScheduleDialog({
    super.key,
    required this.labelController,
    required this.descriptionController,
    required this.onSave,
  });

  @override
  State<StudyScheduleDialog> createState() => _StudyScheduleDialogState();
}

class _StudyScheduleDialogState extends State<StudyScheduleDialog> {
  final TextEditingController dateTimeController = TextEditingController();

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6.r),
      borderSide: BorderSide(color: color, width: 1),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: _buildBorder(Colors.grey),
        focusedBorder: _buildBorder(Colors.blue),
        hoverColor: Colors.white,
      ),
    );
  }

  Widget _buildDateTimePickerField() {
    return TextField(
      controller: dateTimeController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Select Date & Time',
        filled: true,
        fillColor: Colors.white,
        enabledBorder: _buildBorder(Colors.grey),
        focusedBorder: _buildBorder(Colors.blue),
        hoverColor: Colors.white,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
            );

            if (pickedDate != null) {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );

              if (pickedTime != null) {
                final DateTime fullDateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );

                final formattedDateTime =
                    DateFormat('dd/MM/yyyy hh:mm a').format(fullDateTime);

                setState(() {
                  dateTimeController.text = formattedDateTime;
                });
              }
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Schedule'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField(
            labelText: 'Schedule Label',
            controller: widget.labelController,
          ),
          SizedBox(height: 10.h),
          _buildTextField(
            labelText: 'Schedule Description',
            controller: widget.descriptionController,
            maxLines: 3,
          ),
          SizedBox(height: 10.h),
          _buildDateTimePickerField(),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            widget.onSave(
              widget.labelController.text,
              widget.descriptionController.text,
              dateTimeController.text,
            );

            widget.labelController.clear();
            widget.descriptionController.clear();
            dateTimeController.clear();
            Get.back();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
