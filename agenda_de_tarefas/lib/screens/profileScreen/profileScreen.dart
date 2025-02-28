import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/navBar.dart';
import '../../components/sideBar.dart';
import '../user_registration/user_registration_page.dart';

class profileScreen extends StatefulWidget {
  const profileScreen({Key? key}) : super(key: key);

  @override
  _profileScreenState createState() => _profileScreenState();
}

class _profileScreenState extends State<profileScreen> {
  int id = 1;
  String name = '';
  String email = '';
  String password = '';
  String image = '';
  bool notificationsEnabled = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? emailLocal = prefs.getString('email');
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3333/user/email/$emailLocal'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        setState(() {
          _nameController.text = userData['user']['name'];
          _emailController.text = userData['user']['email'];
          _passwordController.text = userData['user']['senha'];
          id = userData['user']['id'];
          name = userData['user']['name'];
          email = userData['user']['email'];
          password = userData['user']['senha'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao buscar dados do usuário')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  void _saveChanges() async {
    bool? shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF8DDCE),
          title: const Text(
            'Confirmar atualização',
            style: TextStyle(color: Colors.black),
          ),
          content: const Text(
            'Você tem certeza que deseja atualizar o usuário?',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFC03A2B),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFFF8DDCE)),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFC03A2B),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Confirmar',
                style: TextStyle(color: Color(0xFFF8DDCE)),
              ),
            ),
          ],
        );
      },
    );

    if (shouldUpdate == true) {
      try {
        final response = await http.put(
          Uri.parse('http://localhost:3333/user/$id'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'name': name,
            'email': email,
            'senha': password,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil atualizado com sucesso!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao atualizar perfil')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  void changePassword(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          bool _isObscured = true;
          final TextEditingController oldPasswordController =
              TextEditingController();
          final TextEditingController newPasswordController =
              TextEditingController();
          final TextEditingController confirmPasswordController =
              TextEditingController();
          final _formKey = GlobalKey<FormState>();
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text("Alterar Senha"),
              backgroundColor: const Color(0xFFF8DDCE),
              contentPadding: const EdgeInsets.all(16.0),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: oldPasswordController,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        labelText: 'Digite sua antiga senha',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscured
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                        ),
                      ),
                    ),
                    TextField(
                      controller: newPasswordController,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        labelText: 'Digite sua nova senha',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscured
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                        ),
                      ),
                    ),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        labelText: 'Confirme sua senha',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscured
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFC03A2B),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Color(0xFFF8DDCE)),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFC03A2B),
                      ),
                      onPressed: () async {
                        if (!oldPasswordController.text.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "A senha antiga deve ser inserida")));
                          return;
                        }
                        final passwordRegex = RegExp(
                            r'^(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$');
                        if (!passwordRegex
                            .hasMatch(newPasswordController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  "A senha deve conter pelo menos um número, um caractere especial e no mínimo 8 caracteres")));
                          return;
                        }
                        if (newPasswordController.text !=
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("As senhas não coincidem")));
                          return;
                        }
                        bool isCorrect = await updatePassword(
                            oldPasswordController.text,
                            newPasswordController.text);
                        if (isCorrect) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(color: Color(0xFFF8DDCE)),
                      ),
                    ),
                  ],
                )
              ],
            );
          });
        });
  }

  Future<bool> updatePassword(String oldPass, String newPass) async {
    if (_passwordController.text != oldPass) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Senha incorreta")));
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse('http://localhost:3333/user/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': _nameController.text,
          'email': _emailController.text,
          'senha': newPass,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('senha atualizada com sucesso!')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar a senha')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
    return false;
  }

  void _deleteAccount() async {
    bool? shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF8DDCE),
          title: const Text(
            'Confirmar remoção',
            style: TextStyle(color: Colors.black),
          ),
          content: const Text(
            'Você tem certeza que deseja deletar o usuário?',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFC03A2B),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFFF8DDCE)),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFC03A2B),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Confirmar',
                style: TextStyle(color: Color(0xFFF8DDCE)),
              ),
            ),
          ],
        );
      },
    );
    if (shouldUpdate == true) {
      try {
        final response = await http.delete(
          Uri.parse('http://localhost:3333/user/$id'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'name': name,
            'email': email,
            'senha': password,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conta deletada com sucesso!')),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => UserRegistrationPage()),
            (Route<dynamic> route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao deletar conta')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  Future<String?> _selectImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        final bytes = result.files.single.bytes;

        if (bytes != null) {
          return "data:image/png;base64,${base64Encode(bytes)}";
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navBar(),
      drawer: Sidebar(),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage:
                      image.isNotEmpty ? NetworkImage(image) : null,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () async {
                        final newImage = await _selectImage();
                        if (newImage != null) {
                          setState(() {
                            image = newImage;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          Center(
            child: Container(
              width: 372,
              height: 352,
              decoration: BoxDecoration(
                color: const Color(0xFFF8DDCE),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      suffixIcon: Icon(Icons.person),
                    ),
                    onChanged: (value) {
                      setState(() {
                        name = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      suffixIcon: Icon(Icons.email),
                    ),
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Receber notificações'),
                    value: notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        notificationsEnabled = value;
                      });
                    },
                    activeColor: const Color(0xFFC03A2B),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Salvar alterações',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC03A2B),
                minimumSize: const Size(250, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: () {
                changePassword(context);
              },
              child: const Text('Alterar Senha',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC03A2B),
                minimumSize: const Size(250, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _deleteAccount,
            child: const Text('Deletar Conta',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC03A2B),
              minimumSize: const Size(250, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
