import 'package:ahorra_app/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';

class AhorraApp extends StatelessWidget {
  const AhorraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ahorra',
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
