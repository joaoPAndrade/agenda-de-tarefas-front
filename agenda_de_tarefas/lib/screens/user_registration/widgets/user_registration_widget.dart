import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import '../../login_screen/login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../models/user.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home_tasks/home_tasks_page.dart';

class UserRegistrationWidget extends StatefulWidget {
  const UserRegistrationWidget({Key? key}) : super(key: key);

  @override
  UserRegistrationWidgetState createState() => UserRegistrationWidgetState();
}

class UserRegistrationWidgetState extends State<UserRegistrationWidget> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  bool _isObscured = true;
  final apiUrl = dotenv.env['API_URL'];

  void createUser() async {
    if (nameController.text.length < 10) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Insira um nome válido")));
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Insira um e-mail válido")));
      return;
    }

    final passwordRegex =
        RegExp(r'^(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$');
    if (!passwordRegex.hasMatch(passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "A senha deve conter pelo menos um número, um caractere especial e no mínimo 8 caracteres")));
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("As senhas não coincidem")));
      return;
    }
    const userPath = "user";
    final url = Uri.parse("$apiUrl$userPath");
    User newUser = User(
        name: nameController.text,
        email: emailController.text,
        senha: passwordController.text);
    try {
      final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode(newUser.toJson()));
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao registrar usuário")),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 370,
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8DDCE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: 'Digite seu nome',
                      suffixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      labelText: 'Digite seu email',
                      suffixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Crie uma senha',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    ),
                  ),
                  obscureText: _isObscured,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirme sua senha',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    ),
                  ),
                  obscureText: _isObscured,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: createUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC03A2B),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 70, vertical: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "Registrar",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 14),
                RichText(
                  text: TextSpan(
                    text: 'Já tem uma conta?',
                    style:
                        const TextStyle(color: Color(0x41415080), fontSize: 16),
                    children: [
                      TextSpan(
                        text: 'Faça login!',
                        style: const TextStyle(
                          color: Color(0xFFC03A2B),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
