import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onToggle;

  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final VoidCallback? onSave;

  const TaskCard({super.key, required this.task, this.onToggle, this.onLongPress, this.onTap, this.onSave});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: task.isCompleted
                  ? const CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(0xFF2DC78A),
                      child: Icon(Icons.check, color: Colors.white, size: 14),
                    )
                  : Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (task.fileUrl != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.attach_file, size: 12, color: Color(0xFF2DC78A)),
                          SizedBox(width: 4),
                          Text("Archivo adjunto", style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                task.isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: task.isSaved ? const Color(0xFF2DC78A) : const Color(0xFF9E9E9E),
                size: 20,
              ),
              onPressed: onSave,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.time,
                style: const TextStyle(
                  color: Color(0xFFFF9800),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
