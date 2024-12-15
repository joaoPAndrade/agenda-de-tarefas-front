import 'package:flutter/material.dart';
import '../../components/navBar.dart';
import '../../components/sideBar.dart';

class HomeTasksPage extends StatefulWidget {
  const HomeTasksPage({Key? key}) : super(key: key);

  @override
  _HomeTasksPageStatus createState() => _HomeTasksPageStatus();
}

class _HomeTasksPageStatus extends State<HomeTasksPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar:  navBar(),
      drawer:  Sidebar(),
      body:  Center(
        child: Text("data"),
      ),
      
    );
  }
}
