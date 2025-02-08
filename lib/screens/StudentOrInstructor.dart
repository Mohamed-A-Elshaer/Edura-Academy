import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/letsYouInScreen.dart';
import 'package:mashrooa_takharog/widgets/customElevatedBtn.dart';

class StudentOrInstructor extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
 return Scaffold(
   backgroundColor: Color(0xffF5F9FF),
body: Center(
  child: Column(
children: [
  SizedBox(height: 46),
  Transform(
    transform: Matrix4.translationValues(-15, 0, 0),
    child: Image.asset('assets/images/EduraFirst.png'),
  ),
  SizedBox(height: 160,),
  CustomElevatedBtn(btnDesc: 'Get Started As A Student',btnWidth: 372.6,onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LetsYouIn(userType: 'student')));},),
  SizedBox(height: 50,),
  CustomElevatedBtn(btnDesc: 'Get Started As An Instructor',btnWidth: 372.6,onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LetsYouIn(userType: 'instructor')));},),

],

  ),
),

 );
  }


}