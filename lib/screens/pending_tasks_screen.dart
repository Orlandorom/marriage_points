import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/task_service.dart';

class PendingTasksScreen extends StatelessWidget {
  const PendingTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F8),
      appBar: AppBar(
        title: const Text("Mis Pendientes", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: TaskService().getPendingTasks(), // Deberás crear este método en el service
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final tasks = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _TaskActionCard(task: task);
            },
          );
        },
      ),
    );
  }
}

class _TaskActionCard extends StatelessWidget {
  final dynamic task;
  const _TaskActionCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(task.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(10)),
                child: Text("${task.points} pts", style: const TextStyle(color: Color.fromARGB(255, 236, 2, 76), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(task.description ?? "Sin descripción", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _requestReview(context, task.id),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 0, 51),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("Solicitar Revisión"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _completeTask(context, task.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Terminada"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _requestReview(BuildContext context, String id) {
    // Aquí llamarás a un nuevo endpoint: Tasks/request-review/{id}
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Revisión solicitada a tu pareja 🔔")));
  }

  void _completeTask(BuildContext context, String id) {
    // Aquí llamarás a Tasks/complete/{id}
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Tarea marcada como terminada!")));
  }
}