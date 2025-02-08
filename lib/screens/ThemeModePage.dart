import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/ProfileScreen.dart';
import 'package:mashrooa_takharog/screens/StudentNavigatorScreen.dart';
import 'package:provider/provider.dart';

import '../providers/ThemeProvider.dart';
import 'InstructorNavigatorScreen.dart';

class ThemeModePage extends StatelessWidget{



  void _navigateBasedOnUserType(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    String userEmail = user.email ?? "";
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {

      var studentSnapshot = await firestore.collection('students')
          .where('email', isEqualTo: userEmail)
          .get();

      if (studentSnapshot.docs.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavigatorScreen()),
        );
        return;
      }


      var instructorSnapshot = await firestore.collection('instructors')
          .where('email', isEqualTo: userEmail)
          .get();

      if (instructorSnapshot.docs.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InstructorNavigatorScreen()),
        );
        return;
      }
    } catch (e) {
      print("Error checking user role: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
     appBar: AppBar(
       leading: IconButton(
         icon: const Icon(Icons.arrow_back),
         onPressed: () =>  _navigateBasedOnUserType(context)
       ),
       title: const Text('Dark Mode'),
     ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Enable Dark Mode",
              style: TextStyle(fontSize: 18),
            ),
            Switch(
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
          ],
        ),
      ),

   );
  }


}