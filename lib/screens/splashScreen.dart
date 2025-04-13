import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/IntroScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/supaAuth_service.dart';
import 'InstructorNavigatorScreen.dart';
import 'SignInScreen.dart';
import 'StudentNavigatorScreen.dart';

class SplashScreen extends StatefulWidget{
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
    var duration = Duration(seconds: 4);
    Timer(duration, _navigateBasedOnLogin);
  }

  Future<void> _navigateBasedOnLogin() async {
    final client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1') // غيّره حسب الـ endpoint الخاص بك
        .setProject('67ac8356002648e5b7e9')
        .setSelfSigned(status: true);// غيّره حسب الـ project ID الخاص بك

    final account = Account(client);
    final SupaAuthService supaAuth=SupaAuthService();

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
          await supaAuth.signInWithEmailPasswordSupabase(email, password);
          try {
            // Check if a session already exists
            await account.get();
            print("Appwrite: Session already active");
          } catch (e) {
            // No session exists, safe to create one
            try {
              await account.createEmailPasswordSession(
                email: email,
                password: password,
              );
              print("Appwrite: Session created");
            } catch (sessionError) {
              print("Appwrite session creation error: $sessionError");
              throw sessionError; // Optional: rethrow to trigger the login error handler
            }
          }

          if (user != null) {
            final userType = await _getUserType(user.user!.uid);
            if (userType == 'student') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NavigatorScreen()),
              );
            } else if (userType == 'instructor') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => InstructorNavigatorScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => IntroScreen()),
              );
            }
            return;
          }
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
      final studentDoc = await FirebaseFirestore.instance.collection('students').doc(userId).get();
      if (studentDoc.exists)
        return 'student';

      final instructorDoc = await FirebaseFirestore.instance.collection('instructors').doc(userId).get();
      if (instructorDoc.exists)
        return 'instructor';
    } catch (e) {
      print("Error fetching user type: $e");
    }
    return null;
  }

  Widget build(BuildContext context) {
   return Scaffold(

backgroundColor: Color(0xff0961F5),
     body: Column(
       children: [
SizedBox(height: 160,),
          Image.asset('assets/images/logo.png',),
        CircularProgressIndicator(
          backgroundColor: Colors.white,
strokeWidth: 4,
        )
       ],
     ),

   );
  }
}