import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/couple_section_widget.dart';
import '../widgets/summary_card_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Key _refreshKey = UniqueKey();

  void _refreshAll() {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F8),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 173, 30, 59),
        elevation: 0,
        title: const Text("Nuestro Hogar", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshAll(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            key: _refreshKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoupleSectionWidget(onRefreshNeeded: _refreshAll),
              const SizedBox(height: 25),
              
              // Aquí llamamos a las "Vistas Parciales" que implementaremos luego
              const SummaryCardWidget(), 
              const SizedBox(height: 30),
              const Text("Tareas Pendientes", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
              const SizedBox(height: 15),
              const _PlaceholderCard(title: "Lista de Tareas"),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Cerrar sesión?"),
        content: const Text("¿Estás seguro de que quieres salir?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            }, 
            child: const Text("Sí, salir", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}

// Widget temporal para que no dé error mientras creas los demás archivos
class _PlaceholderCard extends StatelessWidget {
  final String title;
  const _PlaceholderCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(title, style: const TextStyle(color: Colors.grey)),
    );
  }
}