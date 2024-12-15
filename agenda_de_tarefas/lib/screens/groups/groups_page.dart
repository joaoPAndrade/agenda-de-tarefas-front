import 'package:flutter/material.dart';
class GroupsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Agenda de Tarefas',
          style: TextStyle(
            fontSize: 50, 
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
