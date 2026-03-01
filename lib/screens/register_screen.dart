import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isRegistering = false;

  // Datos para los Dropdowns (se llenan desde el API)
  List<String> _religions = [];
  List<String> _levels = [];
  List<String> _locations = [];
  bool _isLoadingData = true;

  // Controllers
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Valores seleccionados
  String? _selectedReligion;
  String? _selectedLevel;
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
    final data = await _authService.getRegistrationData();
    
    // Verificamos que los datos no vengan nulos antes de asignar
    if (data.isNotEmpty) {
      setState(() {
        // Usamos exactamente los nombres que devuelve tu JSON
        _religions = List<String>.from(data['religiousBeliefs'] ?? []);
        _levels = List<String>.from(data['relationshipLevels'] ?? []);
        _locations = List<String>.from(data['locations'] ?? []);
        _isLoadingData = false; // Una variable para saber que ya terminamos
      });
    }
  } catch (e) {
    print("Error cargando listas: $e");
  }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFB85C6E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Título
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text("Crear Cuenta", 
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
            ),
            
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInput(_firstNameCtrl, "Nombre", Icons.person_outline),
                    _buildInput(_lastNameCtrl, "Apellido", Icons.person_outline),
                    _buildInput(_emailCtrl, "Email", Icons.email_outlined),
                    _buildInput(_passCtrl, "Password", Icons.lock_outline, isPass: true),
                    _buildInput(_phoneCtrl, "Teléfono", Icons.phone_android_outlined),
                    
                    const SizedBox(height: 10),
                    
                    // Dropdowns responsivos
                    _buildDropdown("Creencia Religiosa", _religions, _selectedReligion, 
                      (val) => setState(() => _selectedReligion = val)),
                    _buildDropdown("Nivel de Relación", _levels, _selectedLevel, 
                      (val) => setState(() => _selectedLevel = val)),
                    _buildDropdown("Ubicación", _locations, _selectedLocation, 
                      (val) => setState(() => _selectedLocation = val)),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isRegistering ? null : _submitRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB85C6E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: _isRegistering 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Finalizar Registro", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares de UI (Similares a los que ya tienes en el Login)
  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool isPass = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        obscureText: isPass,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFFB85C6E)),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
        validator: (v) => v!.isEmpty ? "Obligatorio" : null,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? val, Function(String?) onChange) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: DropdownButtonFormField<String>(
      value: val,
      // IMPORTANTE: Si la lista está vacía, mostramos un ítem temporal de "Cargando..."
      items: items.isEmpty 
        ? [const DropdownMenuItem(value: null, child: Text("Cargando opciones..."))]
        : items.map((e) => DropdownMenuItem(
            value: e, 
            child: Text(e)
          )).toList(),
      onChanged: items.isEmpty ? null : onChange, // Deshabilitar si no hay datos
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.list_alt, color: Color(0xFFB85C6E)),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      validator: (v) => v == null ? "Selecciona una opción" : null,
    ),
  );
}

  void _submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isRegistering = true);
      
      final data = {
        "email": _emailCtrl.text,
        "password": _passCtrl.text,
        "firstName": _firstNameCtrl.text,
        "lastName": _lastNameCtrl.text,
        "language": "es",
        "religiousBelief": _selectedReligion,
        "relationshipLevel": _selectedLevel,
        "phone": _phoneCtrl.text,
        "location": _selectedLocation
      };

      bool success = await _authService.register(data);
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Ya puedes iniciar sesión!")));
      }
      setState(() => _isRegistering = false);
    }
  }
}