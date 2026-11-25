import 'package:flutter/material.dart';

/// Placeholder screen for the Expenses module (Phase 2+).
class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: const Center(child: Text('Expenses')),
    );
  }
}
