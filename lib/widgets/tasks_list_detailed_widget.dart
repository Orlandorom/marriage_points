import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/task_service.dart';

class TasksListDetailedWidget extends StatelessWidget {
  const TasksListDetailedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: TaskService().getPendingTasks(), // Asegúrate de tener este método
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _buildTaskItem(task);
          },
        );
      },
    );
  }

  Widget _buildTaskItem(dynamic task) {
    // Formateo seguro de fecha
    String dateLabel = "Sin fecha";
    if (task['dueDate'] != null) {
      dateLabel = DateFormat('dd MMM', 'es').format(DateTime.parse(task['dueDate']));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 23, 23, 23),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFFBF7F8), shape: BoxShape.circle),
            child: const Icon(Icons.star, color: Color(0xFFB85C6E), size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task['title'] ?? 'Tarea', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text("$dateLabel • ${task['points']} puntos", 
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          // Botón para completar (Check)
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
            onPressed: () {
              // Aquí llamaremos al endpoint de completar tarea pronto
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text("¡No hay tareas pendientes! 🙌", style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}