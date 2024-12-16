import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../components/navBar.dart';

class GroupsPage extends StatefulWidget {
  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class CreateGroupDialog extends StatefulWidget {
  final Function(String) onCreate;

  CreateGroupDialog({required this.onCreate});

  @override
  _CreateGroupDialogState createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _groupNameController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Criar Novo Grupo"),
      content: TextField(
        controller: _groupNameController,
        decoration: InputDecoration(labelText: "Nome do Grupo"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_groupNameController.text.isNotEmpty) {
              widget.onCreate(_groupNameController.text);
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC03A2B)),
          child: Text("Criar", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _GroupsPageState extends State<GroupsPage> {
  List<Group> groups = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  // Future<void> fetchGroups() async {
  //   setState(() => isLoading = true);
  //   try {
  //     final response = await http.get(Uri.parse('https://localhost:3333/groups'));
  //     if (response.statusCode == 200) {
  //       final List<dynamic> groupList = json.decode(response.body);
  //       setState(() {
  //         groups = groupList.map((data) => Group.fromJson(data)).toList();
  //       });
  //     } else {
  //       throw Exception('Erro ao carregar grupos.');
  //     }
  //   } catch (e) {
  //     print("Erro: $e");
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }
    Future<void> fetchGroups() async {
    setState(() => isLoading = true);
    await Future.delayed(Duration(seconds: 1)); // Simulando delay de requisição
    setState(() {
      groups = List.generate(
        5,
        (index) => Group(
          name: 'Grupo Fake $index',
          email: 'Membro',
          members: List.generate(
            3,
            (memberIndex) => Member(
              name: 'Membro $memberIndex do Grupo $index',
              email: memberIndex == 0 ? 'Dono' : 'Membro',
            ),
          ),
        ),
      );
      isLoading = false;
    });
  }




  Future<void> createGroup(String name) async {
    try {
      final response = await http.post(
        Uri.parse('https://localhost:3333/groups'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"name": name}),
      );
      if (response.statusCode == 201) {
        fetchGroups();
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
        Uri.parse('https://localhost:3333/groups/${group.name}'),
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
      final response = await http.delete(Uri.parse('https://localhost:3333/groups/${group.name}'));
      if (response.statusCode == 200) {
        setState(() => groups.removeAt(index));
      } else {
        throw Exception('Erro ao excluir grupo.');
      }
    } catch (e) {
      print("Erro: $e");
    }
  }

  Future<void> addMember(Group group, String memberName) async {
    try {
      final response = await http.post(
        Uri.parse('https://localhost:3333/groups/${group.name}/members'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"name": memberName}),
      );
      if (response.statusCode == 201) {
        setState(() => group.members.add(Member(name: memberName, email: "Membro")));
      } else {
        throw Exception('Erro ao adicionar membro.');
      }
    } catch (e) {
      print("Erro: $e");
    }
  }

  void navigateToGroupDetails(Group group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupDetailsPage(
          group: group,
          onUpdateName: (newName) => editGroup(group, newName),
          onDeleteMember: (index) => setState(() => group.members.removeAt(index)),
          onAddMember: (memberName) => addMember(group, memberName),
          onDeleteGroup: () => deleteGroup(groups.indexOf(group)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return Card(
                  child: ListTile(
                    title: Text(group.name),
                    subtitle: Text("Seu cargo: ${group.email}"),
                    leading: Icon(Icons.group, color: const Color(0xFFC03A2B)),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () => navigateToGroupDetails(group),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC03A2B),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => CreateGroupDialog(onCreate: createGroup),
        ),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class Group {
  String name;
  final String email;
  List<Member> members;

  Group({required this.name, required this.email, this.members = const []});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      name: json['name'],
      email: json['email'],
    );
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

class GroupDetailsPage extends StatefulWidget {
  final Group group;
  final Function(String) onUpdateName;
  final Function(int) onDeleteMember;
  final Function(String) onAddMember;
  final VoidCallback onDeleteGroup;

  GroupDetailsPage({
    required this.group,
    required this.onUpdateName,
    required this.onDeleteMember,
    required this.onAddMember,
    required this.onDeleteGroup,
  });

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  final _nameController = TextEditingController();
  final _memberNameController = TextEditingController();
  bool isEditingName = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.group.name;
  }

  bool get canEditGroup =>
      widget.group.email == "Dono" || widget.group.email == "Administrador";

  void showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Adicionar Membro"),
        content: TextField(
          controller: _memberNameController,
          decoration: InputDecoration(labelText: "Nome do Membro"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_memberNameController.text.isNotEmpty) {
                widget.onAddMember(_memberNameController.text);
                _memberNameController.clear();
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text("Adicionar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void toggleEditName() {
    setState(() => isEditingName = !isEditingName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: isEditingName
                        ? TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: "Nome do Grupo",
                              border: OutlineInputBorder(),
                            ),
                          )
                        : Text(
                            widget.group.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  if (canEditGroup)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: toggleEditName,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            widget.onDeleteGroup();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  if (isEditingName)
                    IconButton(
                      icon: Icon(Icons.save, color: Colors.green),
                      onPressed: () {
                        widget.onUpdateName(_nameController.text);
                        toggleEditName();
                      },
                    ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Descrição:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                "Grupo dedicado a ${widget.group.name.toLowerCase()}.",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 20),
              Text(
                "Membros:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.group.members.length,
                itemBuilder: (context, index) {
                  final member = widget.group.members[index];
                  return Card(
                    child: ListTile(
                      title: Text(member.name),
                      subtitle: Text("Cargo: ${member.email}"),
                      trailing: canEditGroup
                          ? IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => widget.onDeleteMember(index),
                            )
                          : null,
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              if (canEditGroup)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: showAddMemberDialog,
                    icon: Icon(Icons.person_add),
                    label: Text("Adicionar Membro"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC03A2B),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
