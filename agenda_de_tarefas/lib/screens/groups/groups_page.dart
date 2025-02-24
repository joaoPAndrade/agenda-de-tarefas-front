import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../components/navBar.dart';
import '../../components/sideBar.dart';
import '../groups_details/groups_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupsPage extends StatefulWidget {
  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class CreateGroupDialog extends StatefulWidget {
  final Function(String, String, String) onCreate;

  CreateGroupDialog({required this.onCreate});

  @override
  _CreateGroupDialogState createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _groupNameController = TextEditingController();
  final _groupDescriptionController = TextEditingController();
  String? emailLocal;

  Future<void> loadLocalEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        emailLocal = prefs.getString('email');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadLocalEmail();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF8DDCE),
      title: const Text("Criar Novo Grupo"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(labelText: "Nome do Grupo"),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _groupDescriptionController,
            maxLines: 5,
            maxLength: 100,
            decoration: InputDecoration(
              labelText: "Descrição",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cancelar",
            style: TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if( !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(_groupNameController.text)  || !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(_groupDescriptionController.text)){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Erro: Nome do grupo não pode conter espaços ou caracteres especiais.",
                  ),
                ),
              );
              return;
            }
            if (_groupNameController.text.isNotEmpty && emailLocal != null) {
              widget.onCreate(
                _groupNameController.text,
                _groupDescriptionController.text,
                emailLocal!,
              );
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC03A2B)),
          child: const Text("Criar", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _GroupsPageState extends State<GroupsPage> {
  List<Group> groups = [];
  late String? emailLocal;
  bool isLoading = false;

  Future<void> loadLocalEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        emailLocal = prefs.getString('email');
      });
    }
    if (emailLocal != null) {
      fetchGroups(emailLocal);
    }
  }

  @override
  void initState() {
    super.initState();
    loadLocalEmail();
  }

  Future<void> fetchGroups(String? email) async {
    setState(() => isLoading = true);
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3333/user/groups/$email'));
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final List<dynamic> groupList = responseBody['groups'];
        setState(() {
          groups = groupList.map((data) => Group.fromJson(data)).toList();
        });
      } else {
        throw Exception('Erro ao carregar grupos.');
      }
    } catch (e) {
      print("Erro: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> createGroup(
      String name, String description, String email) async {
    print(name);
    print(description);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3333/group'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(
            {"name": name, "description": description, "ownerEmail": email}),
      );
      if (response.statusCode == 201) {
        fetchGroups(emailLocal);
      } else {
        throw Exception('Erro ao criar grupo');
      }
    } catch (e) {
      print("Erro: $e");
    }
  }

  Future<void> editGroup(Group group, String newName) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3333/groups/${group.name}'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"name": newName}),
      );
      if (response.statusCode == 200) {
        setState(() => group.name = newName);
      } else {
        throw Exception('Erro ao editar grupo.');
      }
    } catch (e) {
      print("Erro: $e");
    }
  }

  Future<void> deleteGroup(int index) async {
    try {
      final group = groups[index];
      final response = await http
          .delete(Uri.parse('://localhost:3333/groups/${group.name}'));
      if (response.statusCode == 200) {
        setState(() => groups.removeAt(index));
      } else {
        throw Exception('Erro ao excluir grupo.');
      }
    } catch (e) {
      print("Erro: $e");
    }
  }

  void navigateToGroupDetails(Group group) async {
    // Navega para a página de detalhes e aguarda o retorno
    bool shouldReload = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupsDetailsPage(
          id: group.id,
          name: group.name,
          description: group.description,
          owner: group.ownerEmail,
        ),
      ),
    );
    print("Voltei aqui");
    if (shouldReload) {
      setState(() {
        fetchGroups(emailLocal);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const navBar(),
      drawer: const Sidebar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return Card(
                  child: ListTile(
                    title: Text(group.name),
                    subtitle: Text(
                        "Seu cargo: ${group.ownerEmail == emailLocal ? "Dono" : "Membro"}"),
                    leading: const Icon(Icons.group, color: Color(0xFFC03A2B)),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => navigateToGroupDetails(group),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC03A2B),
        onPressed: () {
          if (emailLocal != null) {
            showDialog(
              context: context,
              builder: (context) => CreateGroupDialog(onCreate: createGroup),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      "Erro: Email não encontrado. Por favor, tente novamente.")),
            );
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class Group {
  int id;
  String name;
  String description;
  String ownerEmail;

  Group(
      {required this.id,
      required this.name,
      required this.description,
      required this.ownerEmail});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        ownerEmail: json['ownerEmail']);
  }
}

class Member {
  String name;
  String email;

  Member({required this.name, required this.email});

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      name: json['name'],
      email: json['email'],
    );
  }
}
