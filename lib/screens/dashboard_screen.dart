import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../widgets/couple_section_widget.dart';
import '../widgets/summary_card_widget.dart';
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

  void _showPlanifyModal(BuildContext context, TaskModel deseo) async {
    showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));
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
        initialTitle: "Meta: ${deseo.title}",
        // ASIGNACIÓN: Se le asigna a quien pidió el deseo para que lo cumpla
        preSelectedUserId: deseo.createdByUserId, 
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
        title: const Text("Nuestro Hogar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshAll(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            key: _refreshKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoupleSectionWidget(onRefreshNeeded: _refreshAll),
              const SizedBox(height: 25),
              const Text("DESEOS DE MI PAREJA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              _PartnerWishesSection(onPlanify: (deseo) => _showPlanifyModal(context, deseo)),
              const SizedBox(height: 30),
              
              // WIDGET DE OBJETIVOS AJUSTADO
              FutureBuilder<Map<String, dynamic>>(
                future: _taskService.getSummary(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
                  return _TaskSummaryCard(summary: snapshot.data ?? {});
                },
              ),

              const SizedBox(height: 30),
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
}

// --- WIDGET DE OBJETIVOS (TASK SUMMARY) ---
class _TaskSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;
  const _TaskSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final int total = summary['totalTasks'] ?? 0;
    final int completed = summary['completedTasks'] ?? 0;
    final int pending = total - completed;
    final int totalPoints = summary['totalPoints'] ?? 0;
    final int completedPoints = summary['completedPoints'] ?? 0;
    final int pendingPoints = totalPoints - completedPoints;
    double progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("MIS OBJETIVOS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(label: "Pendientes", value: "$pending / $total"),
              _StatItem(label: "Puntos faltantes", value: "$pendingPoints pts"),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade100,
            color: const Color(0xFFB85C6E),
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 10),
          Text("${(progress * 100).toInt()}% completado", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

// --- RESTO DE WIDGETS AUXILIARES ---

class _PartnerWishesSection extends StatelessWidget {
  final Function(TaskModel) onPlanify;
  const _PartnerWishesSection({required this.onPlanify});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TaskModel>>(
      future: TaskService().getPartnerRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final deseos = snapshot.data ?? [];
        if (deseos.isEmpty) return const Text("No hay deseos pendientes ✨", style: TextStyle(color: Colors.grey));
        return Column(
          children: deseos.map((deseo) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              title: Text(deseo.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(deseo.description ?? ""),
              trailing: ElevatedButton(
                onPressed: () => onPlanify(deseo),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB85C6E)),
                child: const Text("Planificar", style: TextStyle(color: Colors.white)),
              ),
            ),
          )).toList(),
        );
      },
    );
  }
}

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
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _CreateRequestForm extends StatefulWidget {
  final VoidCallback onCreated;
  const _CreateRequestForm({required this.onCreated});
  @override
  State<_CreateRequestForm> createState() => _CreateRequestFormState();
}

class _CreateRequestFormState extends State<_CreateRequestForm> {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("¿Qué deseas pedir?", style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: _controller, decoration: const InputDecoration(hintText: "Ej: Viaje a la playa")),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await TaskService().createGoalRequest(_controller.text, DateTime.now());
              widget.onCreated();
              Navigator.pop(context);
            },
            child: const Text("Enviar deseo"),
          )
        ],
      ),
    );
  }
}

class _CreateTaskForm extends StatefulWidget {
  final String myId, partnerId, partnerName;
  final String? initialTitle, preSelectedUserId;
  final VoidCallback onTaskCreated;
  const _CreateTaskForm({required this.myId, required this.partnerId, required this.partnerName, this.initialTitle, this.preSelectedUserId, required this.onTaskCreated});
  @override
  State<_CreateTaskForm> createState() => _CreateTaskFormState();
}

class _CreateTaskFormState extends State<_CreateTaskForm> {
  late TextEditingController _titleController;
  final _pointsController = TextEditingController(text: "10");

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Planificar Meta para mi Pareja", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Tarea")),
          TextField(controller: _pointsController, decoration: const InputDecoration(labelText: "Puntos"), keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await TaskService().createTask({
                "title": _titleController.text,
                "points": int.parse(_pointsController.text),
                "assignedToUserId": widget.preSelectedUserId,
              });
              widget.onTaskCreated();
              Navigator.pop(context);
            },
            child: const Text("Asignar Tarea"),
          )
        ],
      ),
    );
  }
}