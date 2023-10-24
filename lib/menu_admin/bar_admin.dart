import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      currentIndex: 0, // Initial selected tab index
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.white),
          label: '_____',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_sharp, color: Colors.white),
          label: '_____',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: Colors.white),
          label: '_____',
        ),
      ],
    );
  }
}
