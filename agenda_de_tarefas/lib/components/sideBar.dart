import 'package:flutter/material.dart';
import '../screens/groups/groups_page.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFC03A2B),
      width: 200,
      child: ListView(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Navigator.pop(context);
              },
              color: const Color.fromARGB(255, 255, 255, 255),
              iconSize: 40,
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.group,
              color: Colors.white,
            ),
            title: const Text(
              "Grupos",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GroupsPage()),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(top: 450),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                Text(
                  "Log out",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            onTap: () {
              print("0");
            },
          )
        ],
      ),
    );
  }
}
