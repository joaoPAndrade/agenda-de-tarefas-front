import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../components/sideBar.dart';
import '../../components/navBar.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GroupsDetailsPage extends StatefulWidget {
  final int id;
  final String name;
  final String description;
  final String owner;
  const GroupsDetailsPage(
      {Key? key,
      required this.id,
      required this.name,
      required this.description,
      required this.owner})
      : super(key: key);

  @override
  _GroupsDetailsStatus createState() => _GroupsDetailsStatus();
}

class Users {
  final int id;
  final String name;
  final String email;

  Users({required this.id, required this.name, required this.email});

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class Participants {
  final String name;
  final String email;

  Participants({required this.name, required this.email});
}

class Tasks {
  final String name;
  final String date;
  final String priority;

  Tasks({
    required this.name,
    required this.date,
    required this.priority,
  });
}

class _GroupsDetailsStatus extends State<GroupsDetailsPage> {
  List<Participants> members = [];
  late List<Tasks> tasks;
  bool isOwner = false;
  int membersQuantity = 0;
  late Participants participant;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final String baseUrl = 'http://localhost:3333';
  late String? emailLocal;

  Future<void> fetchGroups() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/group'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
      } else {
        print('Erro ao buscar grupos: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar grupos: $e');
    }
  }

  Future<void> fetchParticipants(int groupId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/group/participants/$groupId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<Participants> fetchedMembers = [];
        for (var participant in data['participants']) {
          if(participant['email'] != emailLocal){
            fetchedMembers.add(Participants(
              name: participant['name'],
              email: participant['email'],
            ));
          }
        }
        setState(() {
          members = fetchedMembers;
        });
      } else {
        print('Erro ao buscar participantes: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar participantes: $e');
    }
  }

  Future<void> addMember(int groupId) async {
    final nameController = TextEditingController();
    String? userName;
    String? email;
    bool isUserValid = false;
    List<Users> suggestedUsers = [];
    Future<void> fetchUserByEmail(String email, Function updateState) async {
      try {
        final response =
            await http.get(Uri.parse('$baseUrl/user/email/$email'));

        if (response.statusCode == 200) {
          final user = json.decode(response.body);
          updateState(() {
            userName = user['user']['name'];
            isUserValid = true;
          });
        } else {
          updateState(() {
            userName = null;
            isUserValid = false;
          });
        }
      } catch (e) {
        print('Erro ao buscar usuário: $e');
        updateState(() {
          userName = null;
          isUserValid = false;
        });
      }
    }

    Future<void> fetchSuggestedUsers(String name, Function updateState) async {
      int groupId = widget.id;
      try {
        final response =
            await http.get(Uri.parse('$baseUrl/users/search/$groupId/?name=$name'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['user'].isNotEmpty) {
            updateState(() {
              suggestedUsers = List<Users>.from(
                  data['user'].map((user) => Users.fromJson(user)));
            });
          }
        } else {
          updateState(() {
            suggestedUsers = [];
          });
        }
      } catch (e) {
        print('Erro ao buscar sugestões: $e');
        updateState(() {
          suggestedUsers = [];
        });
      }
    }

    void showAddMemberDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return AlertDialog(
                backgroundColor: const Color(0xFFF8DDCE),
                title: const Text(
                  'Adicionar Novo Membro',
                  style: TextStyle(color: Colors.black),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Usuário',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (name) {
                        if (!isUserValid) {
                          setState(() => isUserValid = false);
                        }
                        isUserValid = false;
                        if (name.isNotEmpty && name.length % 3 == 0) {
                          fetchSuggestedUsers(name, setState);
                        }
                        if (suggestedUsers.isNotEmpty &&
                            nameController.text == suggestedUsers[0].name &&
                            suggestedUsers.length == 1) {
                          email = suggestedUsers[0].email;
                          setState(() => isUserValid = true);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    if (suggestedUsers.isNotEmpty)
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: suggestedUsers
                              .map((user) => ListTile(
                                    title: Text(user.name),
                                    onTap: () {
                                      nameController.text = user.name;
                                      email = user.email;
                                      setState(() => isUserValid = true);
                                    },
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFC03A2B),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Color(0xFFF8DDCE)),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          isUserValid ? const Color(0xFFC03A2B) : Colors.grey,
                    ),
                    onPressed: isUserValid
                        ? () async {
                            try {
                              final response = await http.post(
                                Uri.parse(
                                    '$baseUrl/group/participants/$groupId'),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({'userEmail': email}),
                              );
                              if (response.statusCode == 200 ||
                                  response.statusCode == 201) {
                                fetchParticipants(widget.id);
                              } else {
                                print(
                                    'Erro ao adicionar membro: ${response.statusCode}');
                              }
                              Navigator.of(context).pop();
                            } catch (e) {
                              print('Erro ao adicionar membro: $e');
                            }
                          }
                        : null,
                    child: const Text(
                      'Confirmar',
                      style: TextStyle(color: Color(0xFFF8DDCE)),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    showAddMemberDialog();
  }

  Future<bool> removeMember(int groupId, String userEmail) async {
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
            'Você tem certeza que deseja remover o usuário?',
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
          Uri.parse('http://localhost:3333/group/participants/$groupId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userEmail': userEmail}),
        );

        if (response.statusCode == 200) {
          fetchParticipants(widget.id);
          return true;
        } else {
          print('Erro ao remover membro: ${response.body}');
        }
      } catch (e) {
        print('Erro ao remover membro: $e');
      }
    }
    return false;
  }

  void deleteGroup(int groupId) async {
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
            'Você tem certeza que deseja deletar o grupo?',
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
        final response =
            await http.delete(Uri.parse('$baseUrl/group/$groupId'));
        if (response.statusCode == 200) {
          Navigator.pop(context, true);
        } else {
          print('Erro ao deletar grupo: ${response.statusCode}');
        }
      } catch (e) {
        print('Erro ao deletar grupo: $e');
      }
    }
  }

  void editGroup(int groupId, String name, String description) async {
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
            'Você tem certeza que deseja atualizar o grupo?',
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
          Uri.parse('$baseUrl/group/$groupId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'description': description,
          }),
        );
        if (response.statusCode == 200) {
          print('Grupo atualizado com sucesso');
        } else {
          print('Erro ao atualizar grupo: ${response.statusCode}');
        }
      } catch (e) {
        print('Erro ao atualizar grupo: $e');
      }
    } else {
      print('Atualização do grupo cancelada.');
    }
  }

  Future<void> loadLocalEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      emailLocal = prefs.getString('email');
    });
    if (emailLocal == widget.owner) {
      isOwner = true;
    }
  }

  Future<void> fetchUserByEmail(String email) async {
    final String baseUrl = 'http://localhost:3333';
    final url = Uri.parse('$baseUrl/user/email/$email');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print(response.statusCode);
        final user = jsonDecode(response.body);
        setState(() {
          _ownerController.text = user['user']['name'];
        });
        return;
      } else {
        print('Erro ao buscar usuário: ${response.statusCode}');
        return;
      }
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchGroups();
    fetchParticipants(widget.id);
    loadLocalEmail();
    _nameController.text = widget.name;
    _descriptionController.text = widget.description;
    fetchUserByEmail(widget.owner);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const navBar(),
      drawer: const Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nome do Grupo",
                    ),
                    readOnly: !isOwner,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Descrição",
                    ),
                    readOnly: !isOwner,
                    maxLines: null,
                    maxLength: 100,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ownerController,
                    decoration: const InputDecoration(
                      labelText: "Dono do Grupo",
                    ),
                    readOnly: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            isOwner
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          editGroup(widget.id, _nameController.text,
                              _descriptionController.text);
                        },
                        icon: const Icon(Icons.edit),
                        tooltip: 'Atualizar',
                        iconSize: 30,
                        color: const Color(0xFFC03A2B),
                      ),
                      IconButton(
                        onPressed: () {
                          deleteGroup(widget.id);
                        },
                        icon: const Icon(Icons.delete),
                        tooltip: 'Deletar',
                        iconSize: 30,
                        color: const Color(0xFFC03A2B),
                      ),
                    ],
                  )
                : const SizedBox(height: 16),
            const Text(
              "Participantes",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 26),
            Container(
              width: double.infinity,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: members.length,
                itemBuilder: (context, index) {
                  participant = members[index];
                  return Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8DDCE),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        participant.email == widget.owner?
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.black,
                        ):
                        const Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                        Text(
                          participant.name,
                          style: const TextStyle(color: Colors.black),
                        ),
                        isOwner
                            ? IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  if (emailLocal != null) {
                                    removeMember(widget.id, participant.email);
                                  } else {
                                    print("Email não está disponível.");
                                  }
                                },
                                tooltip: 'Remover Membro',
                                color: const Color(0xFFC03A2B),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton(
              onPressed: () {
                addMember(widget.id);
              },
              backgroundColor: const Color(0xFFC03A2B),
              child: const Icon(
                Icons.person_add_alt_1_sharp,
                color: Color(0xFFF8DDCE),
                size: 30,
              ),
            )
          : FloatingActionButton(
              onPressed: () async {
                String email = emailLocal ?? "";
                bool success = await removeMember(widget.id, email);
                if (success) {
                  Navigator.pop(context, true);
                }
              },
              backgroundColor: const Color(0xFFC03A2B),
              child: const Icon(
                Icons.output,
                color: Color(0xFFF8DDCE),
                size: 30,
              ),
            ),
    );
  }
}
