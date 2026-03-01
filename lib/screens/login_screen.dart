import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Obtenemos dimensiones para hacer el diseño fluido
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Fondo neutro claro
      body: SingleChildScrollView(
        // El SingleChildScrollView asegura que el diseño suba cuando aparezca el teclado
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // 1. Fondo Superior Curvo
              Container(
                height: size.height * 0.45,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                ),
              ),

              // 2. Imagen Central (Assets)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: size.height * 0.05),
                    child: Image.asset(
                      'images/login_image.png', // Verifica esta ruta en pubspec.yaml
                      height: size.height * 0.28,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.favorite, size: 80, color: Color(0xFFB85C6E)),
                    ),
                  ),
                ),
              ),

              // 3. Tarjeta de Login (Responsive)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 450 : double.infinity,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 25),
                      
                      _buildTextField(
                        controller: _emailController,
                        label: "Email",
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 15),
                      
                      _buildTextField(
                        controller: _passwordController,
                        label: "Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text("Forgot Password?", 
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Botón "Entrar" - Texto Blanco y Responsive
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB85C6E), // Color Cereza
                            foregroundColor: Colors.white, // TEXTO EN BLANCO
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading 
                            ? const SizedBox(
                                height: 20, 
                                width: 20, 
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                              )
                            : const Text("Entrar", 
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      
                      const SizedBox(height: 25),
                      const Center(child: Text("Or login with", style: TextStyle(color: Colors.grey, fontSize: 12))),
                      const SizedBox(height: 15),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialIcon(Icons.g_mobiledata),
                          const SizedBox(width: 25),
                          _socialIcon(Icons.apple),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: "¿No tienen cuenta? ",
                              style: TextStyle(color: Colors.grey),
                              children: [
                                TextSpan(
                                  text: "Sign Up",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB85C6E)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildTextField({
    required TextEditingController controller, 
    required String label, 
    required IconData icon, 
    bool isPassword = false
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFFB85C6E), size: 22),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFB85C6E), width: 1.5),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Icon(icon, size: 28, color: Colors.black87),
    );
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor completa los campos"))
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await AuthService().login(
        _emailController.text.trim(), 
        _passwordController.text
      );
      
      if (success && mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const DashboardScreen())
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Credenciales incorrectas"))
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}