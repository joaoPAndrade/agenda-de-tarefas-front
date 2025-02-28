import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_auth/home_authentication_page.dart';
import './screens/home_tasks/home_tasks_page.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importe este
void main() async {
  try {
    await dotenv.load(fileName: ".env");
  } finally {
      await initializeDateFormatting('pt_BR', null); // Carrega dados de localização
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomeAuthenticationPage(),
    );
  }
}
