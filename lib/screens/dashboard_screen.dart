import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../widgets/couple_section_widget.dart';
import '../widgets/summary_card_widget.dart';
import '../services/task_service.dart';
import '../widgets/task_summary_card.dart';
import 'pending_tasks_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Key _refreshKey = UniqueKey();
  final TaskService _taskService = TaskService();

  void _refreshAll() {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  // --- LÓGICA DE NAVEGACIÓN Y MODALES ---

  void _showCreateTaskModal(BuildContext context, {String? targetUserId, String? initialTitle}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final statusData = await _taskService.getCoupleStatus();
    if (!mounted) return;
    Navigator.pop(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateTaskForm(
        myId: statusData['me']?['id'] ?? '',
        partnerId: statusData['partner']?['id'] ?? '',
        partnerName: statusData['partner']?['name'] ?? "Pareja",
        initialTitle: initialTitle,
        preSelectedUserId: targetUserId,
        onTaskCreated: _refreshAll,
      ),
    );
  }

  void _showCreateRequestModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateRequestForm(onCreated: _refreshAll),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F8),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 173, 30, 59),
        elevation: 0,
        title: const Text("Nuestro Hogar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              // 1. Identidad de pareja
              CoupleSectionWidget(onRefreshNeeded: _refreshAll),
              const SizedBox(height: 25),

              // 2. LO QUE MI PAREJA SUEÑA (Deseos/Requests)
              const Text("LO QUE MI PAREJA SUEÑA", 
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              const SizedBox(height: 10),
              _PartnerWishesSection(
                onPlanify: (wishTitle, partnerId) => _showCreateTaskModal(
                  context, 
                  targetUserId: partnerId, 
                  initialTitle: "Meta: $wishTitle"
                ),
              ),
              
              const SizedBox(height: 30),

              // 3. Progreso y Puntos
              const SummaryCardWidget(), 
              const SizedBox(height: 20),
              
              FutureBuilder<Map<String, dynamic>>(
                future: _taskService.getSummary(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return TaskSummaryCard(
                    summary: snapshot.data ?? {},
                    onCreatePressed: () => _showCreateTaskModal(context),
                  );
                },
              ),
              
              const SizedBox(height: 30),

              // 4. Botones de Acción
              Row(
                children: [
                  Expanded(
                    child: _MenuButton(
                      title: "Mis Tareas",
                      subtitle: "Pendientes",
                      icon: Icons.assignment_outlined,
                      color: const Color(0xFF1A1A1D),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingTasksScreen())),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _MenuButton(
                      title: "Pedir Algo",
                      subtitle: "Crear deseo",
                      icon: Icons.card_giftcard_rounded,
                      color: const Color(0xFFB85C6E),
                      onTap: () => _showCreateRequestModal(context),
                    ),
                  ),
                ],
              ),
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
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/'), child: const Text("Sí")),
        ],
      ),
    );
  }
}

// --- SECCIÓN DE DESEOS (Partner Requests) ---

class _PartnerWishesSection extends StatelessWidget {
  final Function(String, String) onPlanify;
  const _PartnerWishesSection({required this.onPlanify});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: TaskService().getPartnerRequests(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: const Text("Sin deseos pendientes de tu pareja ✨", style: TextStyle(color: Colors.grey)),
          );
        }

        return SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final wish = snapshot.data![index];
              return Container(
                width: 260,
                margin: const EdgeInsets.only(right: 15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1A1A1D), Color(0xFF3C3C3F)]),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(wish.title.toString().replaceAll("PEDIDO: ", ""), 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => onPlanify(wish.title, wish.createdByUserId.toString()),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                      child: const Text("ASIGNAR TAREAS", style: TextStyle(fontSize: 11)),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// --- WIDGETS DE SOPORTE ---

class _MenuButton extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(25)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// --- FORMULARIO DE DESEOS ---
class _CreateRequestForm extends StatefulWidget {
  final VoidCallback onCreated;
  const _CreateRequestForm({required this.onCreated});

  @override
  State<_CreateRequestForm> createState() => _CreateRequestFormState();
}

class _CreateRequestFormState extends State<_CreateRequestForm> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 25, left: 25, right: 25),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("¿Qué deseas pedir?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          TextField(controller: _controller, decoration: const InputDecoration(hintText: "Ej: Cena romántica")),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : () async {
              setState(() => _loading = true);
              final ok = await TaskService().createGoalRequest(_controller.text, DateTime.now());
              if (ok) { widget.onCreated(); Navigator.pop(context); }
              setState(() => _loading = false);
            },
            child: _loading ? const CircularProgressIndicator() : const Text("ENVIAR DESEO"),
          )
        ],
      ),
    );
  }
}

// --- FORMULARIO DE TAREAS (Adaptado para validación de deseos) ---
class _CreateTaskForm extends StatefulWidget {
  final String myId, partnerId, partnerName;
  final String? initialTitle, preSelectedUserId;
  final VoidCallback onTaskCreated;

  const _CreateTaskForm({
    required this.myId, required this.partnerId, required this.partnerName, 
    this.initialTitle, this.preSelectedUserId, required this.onTaskCreated
  });

  @override
  State<_CreateTaskForm> createState() => _CreateTaskFormState();
}

class _CreateTaskFormState extends State<_CreateTaskForm> {
  late TextEditingController _titleController;
  final _pointsController = TextEditingController(text: "10");
  String? _assignedToId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _assignedToId = widget.preSelectedUserId ?? widget.partnerId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 25, left: 25, right: 25),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.initialTitle != null ? "Planificar Meta" : "Nueva Tarea", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Tarea específica")),
          TextField(controller: _pointsController, decoration: const InputDecoration(labelText: "Puntos"), keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await TaskService().createTask({
                "title": _titleController.text,
                "points": int.tryParse(_pointsController.text) ?? 0,
                "assignedToUserId": _assignedToId,
              });
              widget.onTaskCreated();
              Navigator.pop(context);
            },
            child: const Text("ASIGNAR TAREA"),
          )
        ],
      ),
    );
  }
}