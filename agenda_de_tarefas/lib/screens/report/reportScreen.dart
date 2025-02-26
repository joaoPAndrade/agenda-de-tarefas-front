import 'package:flutter/material.dart';
import '../../components/navBar.dart';
import '../../components/sideBar.dart';
import '../../models/category.dart';
import './widgets/timer_widget.dart';
import 'package:flutter/material.dart';

class Reportscreen extends StatefulWidget {
  final Category category;

  Reportscreen({Key? key, required this.category}) : super(key: key);

  @override
  _ReportscreenState createState() => _ReportscreenState();
}

class _ReportscreenState extends State<Reportscreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      appBar: const navBar(),
      drawer: const Sidebar(),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: TimerWidget(category: widget.category),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset:
                  const Offset(0, 170), // Aumente esse valor para descer mais
              child: Image.asset(
                'lib/assets/tomate.png',
                width: 350,
                height: 350,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
