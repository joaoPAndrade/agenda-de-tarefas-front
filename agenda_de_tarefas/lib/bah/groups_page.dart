import 'package:flutter/material.dart';
import '../../components/navBar.dart';
import '../../components/sideBar.dart';
import './widgets/group_list.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({Key? key}) : super(key: key);

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class Group {
  final int id;
  final String name;
  final String description;
  final String donoDogrupo;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.donoDogrupo,
  });
}

class _GroupsPageState extends State<GroupsPage> {
  List<Group> groups = [
    Group(
        id: 1,
        name: 'Group 1',
        description: 'Description 1',
        donoDogrupo: 'John Doe'),
    Group(
        id: 1,
        name: 'Group 2',
        description: 'Description 2',
        donoDogrupo: 'Jane Smith'),
    Group(
        id: 1,
        name: 'Group 3',
        description: 'Description 3',
        donoDogrupo: 'Mike Johnson')
  ];

  Future<void> _fetchGroups() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      groups.add(Group(
        id: 1,
        name: 'Group 4',
        description: 'Description 4',
        donoDogrupo: 'Alice Cooper',
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const navBar(),
      drawer: const Sidebar(),
      body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8DDCE),
          ),
          child: Container(
            margin: const EdgeInsets.all(15),
            child: groups.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder( 
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      return group_list(
                        id: groups[index].id,
                        donoDogrupo: groups[index].donoDogrupo,
                        nome: groups[index].name,
                        descricao: groups[index].description,
                      );
                    },
                  ),
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Botão "+" clicado');
        },
        backgroundColor: const Color(0xFFC03A2B),
        child: const Icon(
          Icons.add,
          color: Color(0xFFF8DDCE),
          size: 50,
        ),
      ),
    );
  }
}
