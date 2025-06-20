import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/AddCoursePage.dart';
import 'package:mashrooa_takharog/widgets/customElevatedBtn.dart';

class InstructorHomeScreen extends StatefulWidget{
  @override
  State<InstructorHomeScreen> createState() => _InstructorHomeScreenState();
}

class _InstructorHomeScreenState extends State<InstructorHomeScreen> {
  String? nickname = "Loading...";
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {


        final doc = await FirebaseFirestore.instance.collection('instructors').doc(user.uid).get();
        if (doc.exists) {
          print('Document data: ${doc.data()}');
          setState(() {
            nickname = doc.data()?['nickName'] ?? "No Nickname";
          });
        } else {

          setState(() {
            nickname = "No Nickname Found";
          });
        }
      } else {
        print('No user currently signed in');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        nickname = "Error loading data";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
   return Scaffold(
       backgroundColor: Color(0xffF5F9FF),
     appBar: AppBar(
       title:  Text(
         "Hi, ${nickname ?? "Loading..."}",
         style: TextStyle(color: Color(0xff232546)),
       ),



       
       backgroundColor: Colors.transparent,
       elevation: 0
     ),
     body: Column(
       children: [
         SizedBox(height: 300,),
         Center(
           child: CustomElevatedBtn(btnDesc: 'Add Course',onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AddCoursePage()));}),
           
         ),
       ],
     ),

   );
  }
}