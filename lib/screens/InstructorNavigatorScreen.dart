import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/HomeScreen.dart';
import 'package:mashrooa_takharog/screens/InstructorHomeScreen.dart';
import 'package:mashrooa_takharog/screens/ProfileScreen.dart';
import 'package:mashrooa_takharog/screens/instructor_courses_screen.dart';

class InstructorNavigatorScreen extends StatefulWidget {
  String? password;
   InstructorNavigatorScreen({super.key,this.password});

  @override
  _MyInstructorNavigatorScreenState createState() => _MyInstructorNavigatorScreenState();
}

class _MyInstructorNavigatorScreenState extends State<InstructorNavigatorScreen> {

  int currentIndex = 0;
  late List<Widget?> _screens;
  @override
  void initState() {
    super.initState();
    _screens = [
      InstructorHomeScreen(),
      InstructorCoursesScreen(),
      ProfileScreen(password: widget.password),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'My Courses',),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile',),
        ],
      ),
    );
  }
}