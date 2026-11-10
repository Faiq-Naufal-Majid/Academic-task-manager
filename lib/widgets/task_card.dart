import 'package:flutter/material.dart';
import '../models/academic_task.dart';

/// Widget kartu presentasi untuk menampilkan item tugas kuliah.
///
/// Menyediakan interaksi checklist selesai, badge prioritas berwarna,
/// tampilan tanggal deadline, dan tombol hapus tugas.
class TaskCard extends StatelessWidget {
  final AcademicTask task;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleStatus,
    required this.onDelete,
  });

  Color _getPriorityColor() {
    switch (task.priority.toLowerCase()) {
      case 'tinggi':
        return Colors.red.shade600;
      case 'sedang':
        return Colors.orange.shade700;
      case 'rendah':
      default:
        return Colors.blue.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: task.isCompleted ? 0.5 : 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: task.isCompleted ? Colors.grey.shade300 : priorityColor.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox interaktif
            IconButton(
              icon: Icon(
                task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: task.isCompleted ? Colors.teal : Colors.grey,
                size: 26,
              ),
              onPressed: onToggleStatus,
              tooltip: task.isCompleted ? 'Tandai belum selesai' : 'Tandai selesai',
            ),
            const SizedBox(width: 4),
            // Konten Tugas
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? Colors.grey : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      // Badge Mata Kuliah
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.indigo.shade200),
                        ),
                        child: Text(
                          task.course,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                      ),
                      // Badge Deadline
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            task.deadline,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                      // Badge Prioritas
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          task.priority,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: priorityColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tombol Hapus
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              tooltip: 'Hapus tugas',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
