import 'package:flutter/material.dart';
import '../services/task_service.dart';

class CoupleSectionWidget extends StatefulWidget {
  final VoidCallback onRefreshNeeded;
  const CoupleSectionWidget({super.key, required this.onRefreshNeeded});

  @override
  State<CoupleSectionWidget> createState() => _CoupleSectionWidgetState();
}

class _CoupleSectionWidgetState extends State<CoupleSectionWidget> {
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _taskService.getCoupleStatus(),
      builder: (context, snapshot) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const ContainerPlaceholder();
  }
  
  if (!snapshot.hasData || snapshot.data == null) {
    return const Center(child: Text("Error al cargar estado"));
  }

  final data = snapshot.data!;
  final me = data['me'];
  final partner = data['partner'];

  // CAMBIO AQUÍ: Determinamos si tiene pareja si 'partner' no es nulo
  final bool hasPartner = partner != null; 

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Datos del usuario actual
        _userAvatar("Tú (${me['name']})", me['initial'], Colors.pinkAccent, me['points']),
        
        const Icon(Icons.favorite, color: Color(0xFFB85C6E), size: 30),
        
        // Datos de la pareja o botón de vincular
        hasPartner 
          ? _userAvatar(partner['name'], partner['initial'], Colors.blueAccent, partner['points'])
          : _buildAddPartnerButton(context),
      ],
    ),
  );
},
    );
  }

  Widget _userAvatar(String label, String inicial, Color color, int pts) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28, 
          backgroundColor: color.withOpacity(0.1),
          child: Text(inicial, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20))
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Text("$pts pts", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      ],
    );
  }

  Widget _buildAddPartnerButton(BuildContext context) {
    return InkWell(
      onTap: () => _showLinkingModal(context),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 28, 
            backgroundColor: Color(0xFFF5F5F5),
            child: Icon(Icons.person_add_alt_1, color: Color(0xFFB85C6E))
          ),
          SizedBox(height: 5),
          Text("Vincular", style: TextStyle(color: Color(0xFFB85C6E), fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- MÉTODOS DE VINCULACIÓN ---

  void _showLinkingModal(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20, left: 25, right: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("Vincular Pareja", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Genera un código para compartir o ingresa el que te enviaron.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),

            OutlinedButton.icon(
              onPressed: () async {
                String? code = await _taskService.generatePairingCode(); 
                if (code != null && mounted) {
                  Navigator.pop(context);
                  _showCodeDialog(code);
                }
              },
              icon: const Icon(Icons.auto_fix_high),
              label: const Text("Generar mi código"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Color(0xFFB85C6E)),
                foregroundColor: const Color(0xFFB85C6E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),

            const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text("O")),

            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: "Pega el código de tu pareja",
                prefixIcon: const Icon(Icons.vpn_key_outlined, color: Color(0xFFB85C6E)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () async {
                if (codeController.text.trim().isEmpty) return;

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                bool success = await _taskService.linkWithPartner(codeController.text.trim());
                
                if (mounted) Navigator.pop(context); // Quitar loading

                if (success && mounted) {
                  Navigator.pop(context); // Cerrar bottom sheet
                  widget.onRefreshNeeded();
                  _showSuccessDialog(context);
                } else {
                  if (mounted) {
                    Navigator.pop(context); // Quitar loading
                    _showErrorDialog(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFFB85C6E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Vincular pareja"),
            ),
          ],
        ),
      ),
    );
  }

  void _showCodeDialog(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tu código de vinculación"),
        content: Text(code),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¡Vinculación exitosa!"),
        content: const Text("Tu pareja ha sido vinculada correctamente."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error al vincular"),
        content: const Text("El código ingresado no es válido o ya fue usado."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
        ],
      ),
    );
  }
}

// Esta clase DEBE ir al final del archivo, después de la última llave } de la clase anterior
class ContainerPlaceholder extends StatelessWidget {
  const ContainerPlaceholder({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(25)
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}