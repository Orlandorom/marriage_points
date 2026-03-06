import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;
  final VoidCallback onCreatePressed;

  const TaskSummaryCard({
    super.key, 
    required this.summary, 
    required this.onCreatePressed
  });

  @override
  Widget build(BuildContext context) {
    // Cálculos de progreso seguros
    int completed = summary['completedTasks'] ?? 0;
    int pending = summary['pendingTasks'] ?? 0;
    int total = completed + pending;
    double progress = total > 0 ? completed / total : 0.0;
    
    // Formateo de fecha seguro (sin depender del idioma español para evitar errores)
    String dateText = "Sin fecha";
    if (summary['maxDueDate'] != null) {
      try {
        DateTime parsedDate = DateTime.parse(summary['maxDueDate']);
        dateText = DateFormat('dd/MM/yyyy').format(parsedDate);
      } catch (e) {
        // Si falla, cortamos el string de la fecha
        dateText = summary['maxDueDate'].toString().substring(0, 10);
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 230, 227, 227), // Fondo oscuro
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("OBJETIVOS DE PAREJA", 
                style: TextStyle(color: Color.fromARGB(255, 173, 30, 59), fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
              _buildBadge("EN CURSO"),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text("$completed", 
                style: const TextStyle(color: Color.fromARGB(255, 173, 30, 59), fontSize: 48, fontWeight: FontWeight.bold)),
              Text(" / $total", 
                style: const TextStyle(color: Color.fromARGB(255, 15, 15, 15), fontSize: 24)),
            ],
          ),
          const Text("tareas completadas", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 14)),
          const SizedBox(height: 25),
          const Divider(color: Color.fromARGB(26, 0, 0, 0)),
          const SizedBox(height: 15),
          _buildRowInfo(Icons.calendar_today, "PRÓXIMO VENCE", dateText),
          const SizedBox(height: 10),
          _buildRowInfo(Icons.stars, "PUNTOS PENDIENTES", "${summary['pendingPoints'] ?? 0} pts"),
          const SizedBox(height: 25),
          
          // Barra de progreso con el corazón
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(color: const Color.fromARGB(26, 0, 0, 0), borderRadius: BorderRadius.circular(10)),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.pink, Colors.redAccent]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Positioned(
                left: (MediaQuery.of(context).size.width - 88) * progress - 12,
                child: const Icon(Icons.favorite, color: Colors.pinkAccent, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: onCreatePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Color.fromARGB(255, 247, 246, 246),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("CREAR NUEVA TAREA", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.pinkAccent.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(color: Colors.pinkAccent, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRowInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color.fromARGB(255, 173, 30, 59), size: 16),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 11)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Color.fromARGB(255, 176, 7, 7), fontWeight: FontWeight.bold)),
      ],
    );
  }
}