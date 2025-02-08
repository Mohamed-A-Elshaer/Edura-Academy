import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/auth/auth_service.dart';
import 'package:mashrooa_takharog/screens/ForgotPasswordScreen.dart';
import 'package:mashrooa_takharog/screens/HomeScreen.dart';
import 'package:mashrooa_takharog/screens/InstructorNavigatorScreen.dart';
import 'package:mashrooa_takharog/screens/StudentNavigatorScreen.dart';
import 'package:mashrooa_takharog/screens/ProfileScreen.dart';
import 'package:mashrooa_takharog/screens/SignUpScreen.dart';
import 'package:mashrooa_takharog/screens/instructor_courses_screen.dart';
import 'package:mashrooa_takharog/screens/splashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/CustomCheckBox.dart';
import '../widgets/customElevatedBtn.dart';
import '../widgets/customTextField.dart';
import 'FillYourProfile.dart';
import 'StudentOrInstructor.dart';

class SignInScreen extends StatefulWidget{

  final String? userType;
  SignInScreen({super.key,this.userType});



  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController=TextEditingController();
  final TextEditingController _passwordController=TextEditingController();
  bool isPasswordVisible = false;
  String? emailError;
  String? passwordError;
  bool isLoading = false;
  bool rememberMe = false;
  @override
  void initState() {
    super.initState();
  }



  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    if (rememberMe) {

      await prefs.setBool('rememberMe', true);
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
    } else {
      await prefs.clear();
    }
  }





  void login(BuildContext context, String intendedRole) async {
    final authService = AuthService();

    try {
      final user = await authService.signInWithEmailPassword(_emailController.text, _passwordController.text);

      if (user!= null) {


        final actualRole = await _getUserType(user.user!.uid);

        if (actualRole != intendedRole) {
          _showAccessDeniedDialog(context, intendedRole);
          await FirebaseAuth.instance.signOut();
          return;
        }
        String collection = widget.userType == 'student' ? 'students' : 'instructors';

        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(collection).doc(user.user!.uid).get();
        if (userDoc.exists && !(userDoc.data() as Map<String, dynamic>)['isProfileComplete']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FillYourProfile(userType: widget.userType),
            ),
          );
        } else {
          Widget destination = widget.userType == 'student'
              ? NavigatorScreen()
              : InstructorNavigatorScreen();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }

      }
    } catch (e) {
      print("Login Error: $e");
      setState(() {
        if (e.toString().contains('invalid-email') ||
            e.toString().contains('wrong-password')||
            e.toString().contains('invalid-credential')) {
          passwordError = '*Incorrect email or password!';
        } else if (e.toString().contains('user-not-found')) {
          passwordError = '*No account found with this email!';
        } else {
          passwordError = '*Login failed. Please try again.';
        }
      });
    }
    finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /*Future<String?> _getFirestoreEmail(String userId, String intendedRole) async {
    try {
      // Determine the correct collection based on the intended role
      final collection = intendedRole == 'student' ? 'students' : 'instructors';

      // Fetch the document from the appropriate collection
      final doc = await FirebaseFirestore.instance.collection(collection).doc(userId).get();

      if (doc.exists) {
        // Return the email field from the document
        return doc.data()?['email'];
      }
    } catch (e) {
      print("Error fetching email from Firestore: $e");
    }

    return null; // Return null if no matching document is found
  }*/




  void _showAccessDeniedDialog(BuildContext context, String intendedRole) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Access Denied',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'You are not authorized to log in as a/an $intendedRole.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }


  /* Future<bool> _isFirestoreEmailMatch(String userId, String enteredEmail) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        // Get the email stored in Firestore
        final firestoreEmail = doc.data()?['email'] ?? '';

        // Compare the email from Firestore with the entered email
        return firestoreEmail == enteredEmail;
      }
    } catch (e) {
      print("Error checking Firestore email: $e");
    }
    return false;
  }*/



  void validateInputs(String intendedRole) {
    setState(() {
      emailError = _emailController.text.isEmpty ? '*Email field cannot be empty!' : null;
      passwordError =_passwordController.text.isEmpty ? '*Password field cannot be empty!' : null;
    });

    if (emailError == null && passwordError == null) {
      setState(() {
        isLoading = true;
      });
      login(context,intendedRole);
    }
  }


  Future<String?> _getUserType(String userId) async {
    try {
      final studentDoc = await FirebaseFirestore.instance.collection('students').doc(userId).get();
      if (studentDoc.exists) {
        return 'student';
      }

      final instructorDoc = await FirebaseFirestore.instance.collection('instructors').doc(userId).get();
      if (instructorDoc.exists) {
        return 'instructor';
      }
    } catch (e) {
      print("Error fetching user type: $e");
    }

    return null;
  }



  /*Future<bool> _isProfileComplete(String userId, String intendedRole) async {
    try {
      // Determine the correct collection based on the intended role
      final collection = intendedRole == 'student' ? 'students' : 'instructors';

      // Fetch the document from the appropriate collection
      final doc = await FirebaseFirestore.instance.collection(collection).doc(userId).get();

      if (doc.exists) {
        // Return the value of isProfileComplete, or false if it's not set
        return doc.data()?['isProfileComplete'] ?? false;
      }
    } catch (e) {
      print("Error checking profile completion: $e");
    }

    return false; // Default to false if there's an error or no document
  }*/


  /*Future<bool> _checkProfileCompletion(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        // Return the value of isProfileComplete or false if it's null
        return doc.data()?['isProfileComplete'] ?? false;
      }
    } catch (e) {
      print("Error checking profile completion: $e");
    }

    return false; // Default to false if there's an error or no document
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>StudentOrInstructor()));},
            icon: Icon(CupertinoIcons.arrow_left,color: Colors.black,)),
        backgroundColor:Colors.transparent ,
        toolbarHeight: 27.0,
      ),
      backgroundColor: Color(0xffF5F9FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 36),
            Transform(
              transform: Matrix4.translationValues(-15, 0, 0),
              child: Image.asset('assets/images/EduraFirst.png'),
            ),
            SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Let’s Sign In!',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Jost',
                        fontWeight: FontWeight.w600,
                        color: Color(0xff202244),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Login to Your Account to Continue watching Courses',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w700,
                        color: Color(0xff545454),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            CustomTextField(
              hintText: 'Email',
              prefix: Icon(Icons.email_outlined, color: Color(0xff545454)),
              isPrefix: true,
              isSuffix: false,
              isObscure: false,
              controller: _emailController,
              errorMessage: emailError,
            ),
            SizedBox(height: 17),
            CustomTextField(

              hintText: 'Password',
              prefix: Icon(Icons.lock_outline_sharp, color: Color(0xff545454)),
              suffix: IconButton(
                icon: Icon(
                  isPasswordVisible
                      ? CupertinoIcons.eye
                      : CupertinoIcons.eye_slash,
                ),
                color: Color(0xff545454),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ),
              isSuffix: true,
              isPrefix: true,
              isObscure: !isPasswordVisible,
              controller: _passwordController,
              errorMessage: passwordError,
            ),
            SizedBox(height: 40,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        rememberMe = !rememberMe;
                      });
                      _saveCredentials();
                    },
                    child: rememberMe
                        ? Icon(
                      Icons.check_box,
                      size: 25.0,
                      color: Colors.green,
                    )
                        : Icon(
                      Icons.square_outlined,
                      size: 25.0,
                      color: Colors.green,
                    ),


                  ),




                  SizedBox(width: 6,),
                  Text('Remember me',style: TextStyle(color: Color(0xff545454),fontSize: 13,fontWeight:FontWeight.w700 ),),
                  SizedBox(width: 90,),
                  GestureDetector(onTap: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> ForgotPasswordScreen()));}, child: Text('Forgot Password?',style: TextStyle(color: Color(0xff545454),fontSize: 13,fontWeight:FontWeight.w700 ),)),

                ],
              ),
            ),
            SizedBox(height: 40,),
            isLoading? CircularProgressIndicator()
                : CustomElevatedBtn(btnDesc: 'Sign In'
              ,horizontalPad: 83,
              onPressed: () => validateInputs(widget.userType!),),
            SizedBox(height: 20,),
            Text('Or Continue With',style: TextStyle(fontSize: 14,fontFamily: 'Mulish',fontWeight: FontWeight.w700,color: Color(0xff545454)),),
            SizedBox(height: 25,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: ()=>AuthService().signInWithGoogle(context,widget.userType!),
                    child: Image.asset('assets/images/googleCircle.png',height: 55,)),
                SizedBox(width: 40,),
                Transform(
                    transform: Matrix4.translationValues(0, -9, 0),
                    child: GestureDetector(child: Image.asset('assets/images/appleCircle.png',height: 55,))),
              ],
            ),
            SizedBox(height: 27,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don\'t have an Account?',
                  style: TextStyle(fontFamily: 'Mulish',fontSize: 14,fontWeight: FontWeight.w700,color: Color(0xff545454)),),
                SizedBox(width: 6,),
                GestureDetector(
                  onTap: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignUpScreen(userType: widget.userType!,)));
                  },
                  child: Text('SIGN UP',style: TextStyle(
                      shadows: [
                        Shadow(
                            color: Color(0xff0961F5),
                            offset: Offset(0, -1))
                      ],
                      fontFamily: 'Mulish',fontSize: 14,fontWeight: FontWeight.w900,color: Colors.transparent,decoration: TextDecoration.underline,decorationColor: Color(0xff0961F5),decorationThickness: 3),),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}