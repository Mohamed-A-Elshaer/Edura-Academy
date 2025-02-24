import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/IntroScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'InstructorNavigatorScreen.dart';
import 'StudentNavigatorScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  Future<void> startTimer() async {
    var duration = const Duration(seconds: 4);
    Timer(duration, _navigateBasedOnLogin);
  }

  Future<void> _navigateBasedOnLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMeEnabled = prefs.getBool('rememberMe') ?? false;

    if (rememberMeEnabled) {
      final email = prefs.getString('email');
      final password = prefs.getString('password');

      if (email != null && password != null) {
        try {
          final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          final userType = await _getUserType(user.user!.uid);
          if (userType == 'student') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NavigatorScreen()),
            );
          } else if (userType == 'instructor') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => InstructorNavigatorScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => IntroScreen()),
            );
          }
          return;
        } catch (e) {
          print("Error logging in with saved credentials: $e");
        }
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => IntroScreen()),
    );
  }

  Future<String?> _getUserType(String userId) async {
    try {
      final studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(userId)
          .get();
      if (studentDoc.exists) return 'student';

      final instructorDoc = await FirebaseFirestore.instance
          .collection('instructors')
          .doc(userId)
          .get();
      if (instructorDoc.exists) return 'instructor';
    } catch (e) {
      print("Error fetching user type: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0961F5),
      body: Column(
        children: [
          const SizedBox(
            height: 160,
          ),
          Image.asset(
            'assets/images/logo.png',
          ),
          const CircularProgressIndicator(
            backgroundColor: Colors.white,
            strokeWidth: 4,
          )
        ],
      ),
    );
  }
}
