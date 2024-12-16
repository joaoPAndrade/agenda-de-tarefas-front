// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import '../screens/profileScreen/profileScreen.dart';
import '../screens/home_tasks/home_tasks_page.dart';
class navBar extends StatelessWidget implements PreferredSizeWidget {
  const navBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              color: const Color(0xFFC03A2B),
              iconSize: 40,
            ),
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) =>  HomeTasksPage()),
                );
              },
              color: const Color(0xFFC03A2B),
              iconSize: 40,
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const profileScreen()),
                );
              },
              color: const Color(0xFFC03A2B),
              iconSize: 40,
            ),
          ],
        ),
      );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}