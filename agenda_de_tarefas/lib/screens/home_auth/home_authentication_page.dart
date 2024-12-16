import 'package:flutter/material.dart';
import '../user_registration/user_registration_page.dart';
import '../login_screen/login_page.dart';
import 'dart:math'; // Import necessário para a função mock
import 'package:shared_preferences/shared_preferences.dart';
import '../home_tasks/home_tasks_page.dart';
class HomeAuthenticationPage extends StatefulWidget {
  const HomeAuthenticationPage({Key? key}) : super(key: key);

  @override
  _HomeAuthenticationPageState createState() => _HomeAuthenticationPageState();
}

class _HomeAuthenticationPageState extends State<HomeAuthenticationPage> {
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    checkUserAuthentication();
  }

  void checkUserAuthentication() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeTasksPage()),
    );
  } 

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF577A59),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                'lib/assets/tomate_calendario.png',
                height: 300,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(50.0),
            decoration: const BoxDecoration(
              color: Color(0xFFF8DDCE),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF577A59),
                      padding: const EdgeInsets.symmetric(
                          vertical: 25, horizontal: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      side:
                          const BorderSide(color: Color(0xFF577A59), width: 2)),
                  child: const Text(
                    "Entrar",
                    style: TextStyle(
                        color: Color(0xFFF8DDCE),
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserRegistrationPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8DDCE),
                      padding: const EdgeInsets.symmetric(
                          vertical: 25, horizontal: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      side:
                          const BorderSide(color: Color(0xFF577A59), width: 2)),
                  child: const Text(
                    "Registrar-se",
                    style: TextStyle(
                        color: Color(0xFF577A59),
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
