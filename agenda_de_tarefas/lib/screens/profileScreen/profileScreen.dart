import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class profileScreen extends StatefulWidget {
  const profileScreen({Key? key}) : super(key: key);

  @override
  _profileScreenState createState() => _profileScreenState();
}

class _profileScreenState extends State<profileScreen> {
  int id = 0;
  String name = '';
  String email = '';
  String password = '';
  String image = '';
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); 
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('LINK-DO-BACK-GET'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);

        setState(() {
          id = userData['id'];
          name = userData['name'];
          email = userData['email'];
          image = userData['image'];
          password = userData['password']; 
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar dados do usuário')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  void _saveChanges() async {
    try {
      final response = await http.post(
        Uri.parse('LINK-DO-BACK-UPDATE'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar perfil')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  void _deleteAccount() async {
    try {
      final response = await http.delete(
        Uri.parse('LINK-DO-BACK-DELETE'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conta deletada com sucesso!')),
        );
        // Aqui você pode redirecionar para uma tela de login ou inicial
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao deletar conta')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Meu perfil',
          style: TextStyle(fontSize: 36),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: [
          Center(
            child: CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(
                  'LINK-DA-IMAGEM-DO-USUARIO'),
            ),
          ),
          SizedBox(height: 60),
          Center(
            child: Container(
              width: 372,
              height: 442,
              decoration: BoxDecoration(
                color: Color(0xFFF8DDCE),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: InputDecoration(labelText: 'Nome'),
                    onChanged: (value) {
                      setState(() {
                        name = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: email,
                    decoration: InputDecoration(labelText: 'Email'),
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: password,
                    decoration: InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
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
          SizedBox(height: 16),

          Container(
          margin: EdgeInsets.only(bottom: 20),
          child: ElevatedButton(
          
            onPressed: _saveChanges,
            child: Text('Salvar alterações', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(

              backgroundColor: Color(0xFFC03A2B),
              minimumSize: Size(250, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              
            ),
          ),

          ),
          ElevatedButton(
            onPressed: _deleteAccount,
            child: Text('Deletar Conta', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFC03A2B),
              minimumSize: Size(250, 60),
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
