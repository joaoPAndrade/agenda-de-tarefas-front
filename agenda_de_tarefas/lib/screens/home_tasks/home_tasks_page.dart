import 'package:flutter/material.dart';
import '../../components/navBar.dart';
import '../../components/sideBar.dart';
import './widgets/calendar_widget.dart';

class HomeTasksPage extends StatefulWidget {
  const HomeTasksPage({Key? key}) : super(key: key);

  @override
  _HomeTasksPageStatus createState() => _HomeTasksPageStatus();
}

class _HomeTasksPageStatus extends State<HomeTasksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const navBar(),
      drawer: const Sidebar(),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: const Column(
          children: [
            Expanded(
              child: CalendarWidget(),
            )
          ],
        ),
      ),
    );
  }
}
