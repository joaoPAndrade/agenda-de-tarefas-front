import 'package:flutter/material.dart';
import '../components/navBar.dart'; // Importando a NavBar

class AgendaTarefasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: navBar(),
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
