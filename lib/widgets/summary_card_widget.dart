import 'package:flutter/material.dart';
import '../services/task_service.dart';

class SummaryCardWidget extends StatelessWidget {
  const SummaryCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskService _taskService = TaskService();

    return FutureBuilder<Map<String, dynamic>>(
      future: _taskService.getCoupleStatus(),
      builder: (context, snapshot) {
        // 1. Estado de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        }

        final data = snapshot.data;
        final me = data?['me'];
        final partner = data?['partner'];

        // 2. Lógica de Negocio: ¿Hay pareja?
        final bool hasPartner = partner != null;
        
        // Sumamos los puntos solo si hay pareja, de lo contrario es 0 o solo los míos
        final int myPoints = me?['points'] ?? 0;
        final int partnerPoints = partner?['points'] ?? 0;
        final int totalPoints = myPoints + partnerPoints;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: hasPartner 
                ? [const Color(0xFFC82344), const Color(0xFFDE8D9D)] // Color vivo si hay pareja
                : [Colors.grey[400]!, Colors.grey[500]!], // Gris si está solo
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: (hasPartner ? const Color(0xFFC82344) : Colors.grey)
                    .withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: hasPartner 
            ? _buildPointsView(totalPoints) 
            : _buildEmptyView(),
        );
      },
    );
  }

  // Vista cuando SÍ hay pareja
  Widget _buildPointsView(int points) {
    return Column(
      children: [
        const Text(
          "Puntos del Equipo", 
          style: TextStyle(color: Colors.white70, fontSize: 16)
        ),
        const SizedBox(height: 5),
        Text(
          "$points", 
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 48, 
            fontWeight: FontWeight.bold,
            letterSpacing: -1
          )
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.stars, color: Colors.white70, size: 18),
            SizedBox(width: 8),
            Text(
              "¡Sigan trabajando juntos!", 
              style: TextStyle(color: Colors.white70, fontSize: 13)
            ),
          ],
        )
      ],
    );
  }

  // Vista cuando NO hay pareja
  Widget _buildEmptyView() {
    return Column(
      children: [
        const Icon(Icons.favorite_border, color: Colors.white70, size: 40),
        const SizedBox(height: 15),
        const Text(
          "¡Comienza tu aventura!", 
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 8),
        const Text(
          "Vincula a tu pareja para empezar a sumar puntos juntos.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30)
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}