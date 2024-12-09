import 'package:flutter/material.dart';

class navBar extends StatelessWidget implements PreferredSizeWidget {
  const navBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
              },
              color: Color(0xFFC03A2B),
              iconSize: 40,
            ),
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
              },
              color: Color(0xFFC03A2B),
              iconSize: 40,
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
              },
              color: Color(0xFFC03A2B),
              iconSize: 40,
            ),
          ],
        ),
      );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}