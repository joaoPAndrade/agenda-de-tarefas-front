import 'package:flutter/material.dart';
import '../screens/groups/groups_page.dart';
import '../screens/login_screen/login_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agenda_de_tarefas/screens/home_tasks/home_tasks_page.dart';
import 'package:http/http.dart' as http;
import '../screens/categories/categories_page.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  Future<void> logout(BuildContext context) async {
    try {
      // Remover as informações do SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('email');
      await prefs.remove('token');

      // Fazer a requisição de logout para o backend
      final response = await http.post(
        Uri.parse('http://localhost:3333/logout'),
        headers: {
          'Authorization':
              'Bearer ${prefs.getString('token')}',
        },
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception('Erro no logout: ${responseBody['error']}');
      }
    } catch (e) {
      print('Erro no logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFC03A2B),
      width: 200,
      child: ListView(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Navigator.pop(context);
              },
              color: const Color.fromARGB(255, 255, 255, 255),
              iconSize: 40,
            ),
          ),
            ListTile(
            leading: const Icon(
              Icons.list,
              color: Colors.white,
            ),
            title: const Text(
              "Tarefas",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeTasksPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.group,
              color: Colors.white,
            ),
            title: const Text(
              "Grupos",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GroupsPage()),
              );
            },
          ),
          

          ListTile(
            leading: const Icon(
              Icons.category,
              color: Colors.white,
            ),
            title: const Text(
              "Categorias",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CategoryPage()),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(top: 450),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                Text(
                  "Log out",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            onTap: () {
              logout(context);
            },
          )
        ],
      ),
    );
  }
}
