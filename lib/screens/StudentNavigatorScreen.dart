import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/BookmarksScreen.dart';
import 'package:mashrooa_takharog/screens/HomeScreen.dart';
import 'package:mashrooa_takharog/screens/MyCoursesScreen.dart';
import 'package:mashrooa_takharog/screens/ProfileScreen.dart';

class NavigatorScreen extends StatefulWidget {
  @override
  _MyNavigatorScreenState createState() => _MyNavigatorScreenState();
}

class _MyNavigatorScreenState extends State<NavigatorScreen> {
  int currentIndex = 0;
  final List<Widget?> _screens = [
   Homepage(),
    MyCoursesScreen(),
    BookmarksScreen(),
    null,
    null,
    ProfileScreen(userType: 'student',)
  ];

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
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'My Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border_outlined), label: 'Bookmarks'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Blogs'),

          BottomNavigationBarItem(
              icon: Icon(Icons.payment), label: 'Transaction'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile',),
        ],
      ),
    );
  }
}