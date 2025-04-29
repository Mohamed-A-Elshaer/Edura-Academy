import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/AdminDashboardScreen.dart';
import 'package:mashrooa_takharog/screens/AdminProfileScreen.dart';

class AdminNavigatorScreen extends StatefulWidget {
  const AdminNavigatorScreen({super.key});

  @override
  State<AdminNavigatorScreen> createState() => _AdminNavigatorScreenState();
}

class _AdminNavigatorScreenState extends State<AdminNavigatorScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff0961F5),
        unselectedItemColor: const Color(0xff545454),
        onTap: _onItemTapped,
      ),
    );
  }
}
