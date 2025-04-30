import 'package:appwrite/appwrite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/auth/Appwrite_service.dart';
import 'package:mashrooa_takharog/auth/auth_service.dart';
import 'package:mashrooa_takharog/auth/supaAuth_service.dart';
import 'package:mashrooa_takharog/screens/AdminNavigatorScreen.dart';
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

class SignInScreen extends StatefulWidget {
  final String? userType;
  SignInScreen({super.key, this.userType});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final SupaAuthService supaAuth = SupaAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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

  Future<String?> _getUserType(String userId) async {
    try {
      // Check admin collection first
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(userId)
          .get();
      if (adminDoc.exists) {
        return 'admin';
      }

      // Then check student collection
      final studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(userId)
          .get();
      if (studentDoc.exists) {
        return 'student';
      }

      // Finally check instructor collection
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

  Future<bool> _checkEmailInCollection(String email, String collection) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('email', isEqualTo: email)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking email in $collection collection: $e");
      return false;
    }
  }

  void _showEmailExistsDialog(BuildContext context, String role) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Access Denied',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'This email is registered as a $role. Please sign in with the appropriate account type.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Color(0xff0961F5),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  void login(BuildContext context, String intendedRole) async {
    final authService = AuthService();
    final account = Appwrite_service.account;

    try {
      // First check if email exists in a different role's collection
      if (intendedRole == 'admin') {
        // Check if email exists in students or instructors collection
        bool isStudent =
            await _checkEmailInCollection(_emailController.text, 'students');
        bool isInstructor =
            await _checkEmailInCollection(_emailController.text, 'instructors');

        if (isStudent) {
          _showEmailExistsDialog(context, 'student');
          return;
        }
        if (isInstructor) {
          _showEmailExistsDialog(context, 'instructor');
          return;
        }
      } else {
        // If trying to login as student or instructor, check if email exists in admins collection
        bool isAdmin =
            await _checkEmailInCollection(_emailController.text, 'admins');
        if (isAdmin) {
          _showEmailExistsDialog(context, 'admin');
          return;
        }
      }

      final user = await authService.signInWithEmailPassword(
          _emailController.text, _passwordController.text);
      await supaAuth.signInWithEmailPasswordSupabase(
          _emailController.text, _passwordController.text);
      try {
        // Check if a session already exists
        await account.get();
        print("Appwrite: Session already active");
      } catch (e) {
        // No session exists, safe to create one
        try {
          await account.createEmailPasswordSession(
            email: _emailController.text,
            password: _passwordController.text,
          );
          print("Appwrite: Session created");
        } catch (sessionError) {
          print("Appwrite session creation error: $sessionError");
          throw sessionError;
        }
      }

      if (user != null) {
        // Check if email exists in admin collection
        final adminQuery = await FirebaseFirestore.instance
            .collection('admins')
            .where('email', isEqualTo: _emailController.text)
            .get();

        if (adminQuery.docs.isNotEmpty) {

          if (intendedRole != 'admin') {
            // Show access denied dialog
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
                        'This email belongs to an admin account. Please sign in from the admin panel.',
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

            // Sign out from all services
            await FirebaseAuth.instance.signOut();
            await SupaAuthService.signOut();
            try {
              final sessions = await account.listSessions();
              if (sessions.sessions.isNotEmpty) {
                await account.deleteSession(sessionId: 'current');
                print("Appwrite session deleted successfully");
              } else {
                print("No active Appwrite session found");
              }
            } catch (e) {
              print("Error deleting Appwrite session: $e");
            }
            return;
          }
          // If email found in admin collection, navigate to admin screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const AdminNavigatorScreen()),
          );
          return;
        }

        // Check email in opposite collection first
        final oppositeCollection =
            intendedRole == 'student' ? 'instructors' : 'students';
        final oppositeQuery = await FirebaseFirestore.instance
            .collection(oppositeCollection)
            .where('email', isEqualTo: _emailController.text)
            .get();

        if (oppositeQuery.docs.isNotEmpty) {
          // Email found in opposite collection, show error
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Access Denied',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
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
                      'This email is registered as a/an ${oppositeCollection == 'instructors' ? 'instructor' : 'student'}. Please sign in with the appropriate account type.',
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
          await FirebaseAuth.instance.signOut();
          await SupaAuthService.signOut();
          try {
            final sessions = await account.listSessions();
            if (sessions.sessions.isNotEmpty) {
              await account.deleteSession(sessionId: 'current');
              print("Appwrite session deleted successfully");
            } else {
              print("No active Appwrite session found");
            }
          } catch (e) {
            print("Error deleting Appwrite session: $e");
          }
          return;
        }

        // Check email in appropriate collection
        final collection =
            intendedRole == 'student' ? 'students' : 'instructors';
        final query = await FirebaseFirestore.instance
            .collection(collection)
            .where('email', isEqualTo: _emailController.text)
            .get();

        if (query.docs.isEmpty) {
          // Email not found in the appropriate collection
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Access Denied',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
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
                      'This email is not registered as a $intendedRole. Please sign in with the appropriate account type.',
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
          await FirebaseAuth.instance.signOut();
          await SupaAuthService.signOut();
          try {
            final sessions = await account.listSessions();
            if (sessions.sessions.isNotEmpty) {
              await account.deleteSession(sessionId: 'current');
              print("Appwrite session deleted successfully");
            } else {
              print("No active Appwrite session found");
            }
          } catch (e) {
            print("Error deleting Appwrite session: $e");
          }
          return;
        }

        // Email found in appropriate collection, proceed with login
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection(collection)
            .doc(user.user!.uid)
            .get();
        if (userDoc.exists &&
            !(userDoc.data() as Map<String, dynamic>)['isProfileComplete']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FillYourProfile(userType: widget.userType),
            ),
          );
        } else {
          Widget destination = widget.userType == 'student'
              ? NavigatorScreen(
                  password: _passwordController.text,
                )
              : InstructorNavigatorScreen(
                  password: _passwordController.text,
                );

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
            e.toString().contains('wrong-password') ||
            e.toString().contains('invalid-credential')) {
          passwordError = '*Incorrect email or password!';
        } else if (e.toString().contains('user-not-found')) {
          passwordError = '*No account found with this email!';
        } else {
          passwordError = '*Login failed. Please try again.';
        }
      });
    } finally {
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
      emailError = _emailController.text.isEmpty
          ? '*Email field cannot be empty!'
          : null;
      passwordError = _passwordController.text.isEmpty
          ? '*Password field cannot be empty!'
          : null;
    });

    if (emailError == null && passwordError == null) {
      setState(() {
        isLoading = true;
      });
      login(context, intendedRole);
    }
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
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentOrInstructor()));
            },
            icon: Icon(
              CupertinoIcons.arrow_left,
              color: Colors.black,
            )),
        backgroundColor: Colors.transparent,
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Let\'s Sign In!',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Jost',
                        fontWeight: FontWeight.w600,
                        color: Color(0xff202244),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (widget.userType != 'admin')
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
            SizedBox(
              height: 40,
            ),
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
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    'Remember me',
                    style: TextStyle(
                        color: Color(0xff545454),
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                  ),
                  if (widget.userType != 'admin') ...[
                    SizedBox(
                      width: 90,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ForgotPasswordScreen()));
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                              color: Color(0xff545454),
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        )),
                  ],
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            isLoading
                ? CircularProgressIndicator()
                : CustomElevatedBtn(
                    btnDesc: 'Sign In',
                    horizontalPad: 83,
                    onPressed: () => validateInputs(widget.userType!),
                  ),
            if (widget.userType != 'admin') ...[
              SizedBox(
                height: 20,
              ),
              Text(
                'Or Continue With',
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w700,
                    color: Color(0xff545454)),
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () => AuthService()
                          .signInWithGoogle(context, widget.userType!),
                      child: Image.asset(
                        'assets/images/googleCircle.png',
                        height: 55,
                      )),
                ],
              ),
              SizedBox(
                height: 27,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an Account?',
                    style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff545454)),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen(
                                    userType: widget.userType!,
                                  )));
                    },
                    child: Text(
                      'SIGN UP',
                      style: TextStyle(
                          shadows: [
                            Shadow(
                                color: Color(0xff0961F5), offset: Offset(0, -1))
                          ],
                          fontFamily: 'Mulish',
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.transparent,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xff0961F5),
                          decorationThickness: 3),
                    ),
                  ),
                ],
              )
            ],
          ],
        ),
      ),
    );
  }
}