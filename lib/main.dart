import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
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
        primarySwatch: Colors.pink, // Un color acorde a la temática
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}