import 'package:flutter/material.dart';

/// Placeholder screen for the Goals module (Phase 2+).
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: const Center(child: Text('Goals')),
    );
  }
}
