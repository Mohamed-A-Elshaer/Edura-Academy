import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mashrooa_takharog/screens/HomeScreen.dart';
import 'package:mashrooa_takharog/screens/InstructorNavigatorScreen.dart';
import 'package:mashrooa_takharog/screens/StudentNavigatorScreen.dart';
import 'package:mashrooa_takharog/screens/SignUpScreen.dart';
import 'package:mashrooa_takharog/screens/conpage.dart';
import 'package:mashrooa_takharog/screens/instructor_courses_screen.dart';
import 'package:mashrooa_takharog/widgets/customElevatedBtn.dart';
import 'package:mashrooa_takharog/widgets/customTextField.dart';

import 'ProfileScreen.dart';

class FillYourProfile extends StatefulWidget{
  final String? userType;
  String? email;
  String? phone;
   FillYourProfile({super.key,this.userType, this.email, this.phone});

  @override
  State<FillYourProfile> createState() => _FillYourProfileState();
}

class _FillYourProfileState extends State<FillYourProfile> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController nickNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
 // TextEditingController emailController = TextEditingController();
  //TextEditingController phoneController = TextEditingController();

  // Error messages
  String? fullNameError;
  String? nickNameError;
  String? dobError;
  //String? emailError;
 // String? phoneError;
  String? genderError;
  String selectedGender='Gender';
  //TextEditingController controller= new TextEditingController();
  @override
  Widget build(BuildContext context) {
     return WillPopScope(
         onWillPop: () async {
       final shouldLeave = await showDialog(
         context: context,
         builder: (context) => AlertDialog(
           title: Text('Incomplete Profile'),
           content: Text('You need to complete your profile before leaving.'),
           actions: [
             TextButton(
               onPressed: () => Navigator.of(context).pop(false), // Stay on the page
             child: Text('Cancel'),
           ),
         ],
       ),
     );
     return shouldLeave ?? false;
   },

     child:Scaffold(
backgroundColor: Color(0xffF5F9FF),
     appBar: AppBar(

       title: Text('Fill Your Profile',style: TextStyle(color: Color(0xff202244),fontFamily: 'Jost',fontSize: 21,fontWeight: FontWeight.w600),),
     backgroundColor:Color(0xffF5F9FF) ,

     ),
body: Center(
  child: SingleChildScrollView(
    child: Transform(
      transform: Matrix4.translationValues(0, -10, 0),
      child: Column(
      children: [
        CircleAvatar(
          radius: 50,
          child: Image.asset('assets/images/ProfilePic.png',height: 65,),),
        SizedBox(height: 40,),
        CustomTextField(hintText: 'Full Name', isPrefix: false,hpad: 20,  isSuffix: false,controller: fullNameController,
          errorMessage: fullNameError,),
        SizedBox(height: 20,),
        CustomTextField(hintText: 'Nick Name', isPrefix: false,hpad: 20,  isSuffix: false, controller: nickNameController,
          errorMessage: nickNameError,),
        SizedBox(height: 20,),
        CustomTextField(hintText: 'Date of Birth', isPrefix: true, prefix: Icon(Icons.calendar_month_outlined), isSuffix: false,onTap: () => _selectDate(context),controller: dobController,readOnly: true,errorMessage: dobError,),
        SizedBox(height: 20,),
      //  CustomTextField(hintText: 'Email', isPrefix: true, prefix: Icon(Icons.email_outlined),  isSuffix: false, controller: emailController,
         // errorMessage: emailError,),
        SizedBox(height: 4,),
    //    CustomTextField(labelText: '(+20)', isPrefix: true, prefix: Icon(Icons.phone_android),  isSuffix: false,cursorHeight: 15,controller: phoneController,
        //  errorMessage: phoneError,),

        CustomTextField(hintText: selectedGender, errorMessage: genderError,isPrefix: false,readOnly: true, hpad:20,isSuffix: true, dropdownItems: ['Male', 'Female'],
          onDropdownChanged: (value) {
            setState(() {
              if (value != null) {
                selectedGender = value;
                genderError = null;
              }
            });
          },),
        SizedBox(height: 20,),


CustomElevatedBtn(btnDesc: 'Continue',horizontalPad: 75, onPressed: _validateAndContinue,)


      ],

      ),
    ),
  ),
),
   ));
  }


  DateTime dateTime = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dateTime,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1920),
        lastDate: DateTime(2101));
    if (picked != null && picked != dateTime)
      setState(() {
        dateTime = picked;
        dobController.text = DateFormat('dd-MM-yyyy').format(picked);;
      });
  }
  void _validateAndContinue() {
    setState(() {
      // Validate inputs
      fullNameError = fullNameController.text.isEmpty ? '*Full Name is required!' : null;
      nickNameError = nickNameController.text.isEmpty ? '*Nick Name is required!' : null;
      dobError = dobController.text.isEmpty ? '*Date of Birth is required!' : null;
     // emailError = emailController.text.isEmpty ? '*Email is required!' : null;
     // phoneError = phoneController.text.isEmpty ? '*Phone number is required!' : null;
      genderError = (selectedGender == 'Gender') ? '*Gender selection is required!' : null;

      if (fullNameError == null &&
          nickNameError == null &&
          dobError == null &&
          genderError == null) {
        final user = FirebaseAuth.instance.currentUser;

        String collection = widget.userType == 'student' ? 'students' : 'instructors';

        FirebaseFirestore.instance.collection(collection).doc(user?.uid).set({
          'isProfileComplete': true,
          'fullName': fullNameController.text,
          'nickName': nickNameController.text,
          'dob': dobController.text,
          'email': widget.email,
          'phone': widget.phone,
          'gender': selectedGender,
        });


        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CongratulationsPage(userType: widget.userType,)),
        );
      }
    });


        // Navigate to the profile screen
        /*Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavigatorScreen()),
        );*/
      }







}



