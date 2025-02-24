import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/InstructorNavigatorScreen.dart';
import 'package:mashrooa_takharog/screens/instructor_courses_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/StudentNavigatorScreen.dart';
import '../screens/splashScreen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data == true) {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                final user = snapshot.data;
                if (user != null) {
                  return FutureBuilder<String?>(
                    future: _getUserType(user.uid),
                    builder: (context, userTypeSnapshot) {
                      if (userTypeSnapshot.connectionState ==
                          ConnectionState.done) {
                        final userType = userTypeSnapshot.data;
                        if (userType == 'student') {
                          return NavigatorScreen();
                        } else if (userType == 'instructor') {
                          return InstructorNavigatorScreen();
                        } else {
                          return SplashScreen();
                        }
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                } else {
                  return SplashScreen();
                }
              }
              return const Center(child: CircularProgressIndicator());
            },
          );
        } else {
          return SplashScreen();
        }
      },
    );
  }

  Future<bool> checkUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    if (!rememberMe) {
      await prefs.clear();
      await FirebaseAuth.instance.signOut();
      return false;
    }

    return FirebaseAuth.instance.currentUser != null;
  }

  Future<String?> _getUserType(String userId) async {
    try {
      final studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(userId)
          .get();
      if (studentDoc.exists) {
        return 'student';
      }

      final instructorDoc = await FirebaseFirestore.instance
          .collection('instructors')
          .doc(userId)
          .get();
      if (instructorDoc.exists) {
        return 'instructor';
      }
    } catch (e) {
      print("Error fetching user type: $e");
    }

    return null;
  }
}
