import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart'; // Mantener esto

void main() async {
  // 1. Esto es obligatorio cuando usas async en el main
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Cargamos los datos de idioma (español en este caso)
  // Sin esto, DateFormat('...', 'es') genera el error que ves
  await initializeDateFormatting('es', null);

  runApp(const MarriagePointsApp());
}

class MarriagePointsApp extends StatelessWidget {
  const MarriagePointsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marriage Points',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Un rosa/fucsia que combine con tu diseño de 173, 30, 59
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 173, 30, 59),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}