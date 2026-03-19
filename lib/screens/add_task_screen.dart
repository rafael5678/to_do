import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../models/task_model.dart';
import '../services/supabase_service.dart';
import '../widgets/category_chip.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _selectedCategory;
  final List<String> _categories = [
    "Healthy",
    "Design",
    "Job",
    "Education",
    "Sport",
    "More",
  ];
  final List<PlatformFile> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.taskToEdit?.title ?? "",
    );
    _descriptionController = TextEditingController(
      text: widget.taskToEdit?.description ?? "",
    );
    _selectedDate = widget.taskToEdit?.date ?? DateTime.now();
    _selectedCategory = widget.taskToEdit?.category ?? "Healthy";
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.taskToEdit == null ? "Adding Task" : "Editing Task",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Task Title",
                hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                filled: true,
                fillColor: const Color(0xFFF4FBF8),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF2DC78A),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Description",
                hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                filled: true,
                fillColor: const Color(0xFFF4FBF8),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: const Padding(
                  padding: EdgeInsets.only(top: 14, right: 12),
                  child: Text(
                    "(Not Required)",
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF2DC78A),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Select Date
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF2DC78A),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4FBF8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFF2DC78A),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Additional Files
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  withData: true,
                );
                if (result != null) {
                  setState(() {
                    _selectedFiles.addAll(result.files);
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4FBF8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFF2DC78A),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedFiles.isEmpty
                                ? "Additional Files"
                                : "Attached: ${_selectedFiles.length} file(s)",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF9E9E9E),
                        ),
                      ],
                    ),
                    if (_selectedFiles.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          children: _selectedFiles
                              .map(
                                (f) => Chip(
                                  label: Text(
                                    f.name,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  onDeleted: () =>
                                      setState(() => _selectedFiles.remove(f)),
                                  deleteIcon: const Icon(Icons.close, size: 12),
                                  backgroundColor: Colors.white,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Choose Category
            const Text(
              "Choose Category",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories.map((category) {
                return CategoryChip(
                  label: category,
                  isSelected: _selectedCategory == category,
                  onTap: () => setState(() => _selectedCategory = category),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            // Confirm Adding
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _submitTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DC78A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  widget.taskToEdit == null ? "Confirm Adding" : "Update Task",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor ingresa un título para la tarea"),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final timeStr = DateFormat('h a').format(now);

    Task? newTask;
    try {
      String? fileUrl;
      if (_selectedFiles.isNotEmpty) {
        final file = _selectedFiles.first;
        fileUrl = await _supabaseService.uploadFile(
          "${DateTime.now().millisecondsSinceEpoch}_${file.name}",
          file.bytes,
        );
      }

      newTask = Task(
        id: widget.taskToEdit?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        category: _selectedCategory,
        time: timeStr,
        isCompleted: widget.taskToEdit?.isCompleted ?? false,
        fileUrl: fileUrl ?? widget.taskToEdit?.fileUrl,
      );

      if (widget.taskToEdit == null) {
        await _supabaseService.addTask(newTask);
      } else {
        await _supabaseService.updateTask(newTask);
      }

      if (mounted) {
        Navigator.pop(context, newTask); // Return the task object to add it locally
      }
    } catch (e) {
      debugPrint('Supabase failed, but task will be added locally: $e');
      if (mounted && newTask != null) {
        Navigator.pop(context, newTask); // Still return the task even if Supabase fails
      }
    }
  }
}
