import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mashrooa_takharog/auth/supaAuth_service.dart';
import 'package:mashrooa_takharog/screens/FillYourProfile.dart';
import 'package:mashrooa_takharog/screens/SignInScreen.dart';
import 'package:mashrooa_takharog/screens/StudentOrInstructor.dart';
import 'package:mashrooa_takharog/screens/TermsAndCondScreen.dart';
import 'package:mashrooa_takharog/widgets/CustomCheckBox.dart';
import 'package:mashrooa_takharog/widgets/Loading.dart';
import 'package:mashrooa_takharog/widgets/customElevatedBtn.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_service.dart';
import '../widgets/customTextField.dart';

class SignUpScreen extends StatefulWidget {
  final String? userType;
  const SignUpScreen({super.key, this.userType});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool isPasswordVisible = false;
  bool isReEnterPasswordVisible = false;
  String? emailError;
  String? passwordError;
  String? confirmpasswordError;
  String? phoneError;
  bool isTermsChecked = false;
  String? termsError;

  String? verificationId;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  //final supaAuth=SupaAuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  /* Future<bool> isPhoneNumberExists(String phone) async {
    String formattedPhone = '+20$phone';

    // Check both collections for existing phone number
    final studentQuery = await FirebaseFirestore.instance
        .collection('students')
        .where('phone', isEqualTo: formattedPhone)
        .get();

    final instructorQuery = await FirebaseFirestore.instance
        .collection('instructors')
        .where('phone', isEqualTo: formattedPhone)
        .get();

    return studentQuery.docs.isNotEmpty || instructorQuery.docs.isNotEmpty;
  }*/

  void register(BuildContext context) async {
    if (_passwordController.text == _confirmPasswordController.text) {
      try {
        final String formattedPhone = '+20${_phoneController.text}';

        await verifyPhoneNumber(context, formattedPhone);
      } catch (e) {
        print('Error during registration: $e');
        setState(() {
          if (e.toString().contains('invalid-email')) {
            emailError = '*Invalid email: doesn\'t exist!';
          } else if (e.toString().contains('weak-password')) {
            passwordError =
                '*Password is too weak! It must be at least 8 characters.';
            confirmpasswordError =
                '*Password is too weak! It must be at least 8 characters.';
          } else if (e.toString().contains('email-already-in-use')) {
            emailError = '*Email already in use!';
          } else {
            emailError = '*Sign-up failed. Please try again.';
          }
        });
      }
    } else {
      setState(() {
        confirmpasswordError = '*Passwords don\'t match!';
      });
    }
  }

  Future<void> addUserToSupabase() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      print("User registered: ${response.user?.id}");
    } catch (e) {
      print("Error during registration: $e");
    }
  }

  Future<void> verifyPhoneNumber(
      BuildContext context, String formattedPhone) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waiting for authentication...'),
          duration: Duration(seconds: 7),
        ),
      );
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print(
              'Verification completed automatically with credential: $credential');
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Phone verification failed: $e');
          setState(() {
            phoneError = '*Phone verification failed. Please try again.';
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            this.verificationId = verificationId;
          });
          showOtpDialog(context, formattedPhone);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            this.verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      print('Error during phone verification: $e');
      setState(() {
        phoneError = '*Failed to verify phone number.';
      });
    }
  }

  void showOtpDialog(BuildContext context, String formattedPhone) {
    final TextEditingController otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter OTP'),
        content: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'OTP'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Waiting for authentication...'),
                    duration: Duration(seconds: 5), // Adjust as needed
                  ),
                );
                final PhoneAuthCredential phoneCredential =
                    PhoneAuthProvider.credential(
                  verificationId: verificationId!,
                  smsCode: otpController.text,
                );

                final String email = _emailController.text.trim();
                final String password = _passwordController.text.trim();
                final UserCredential userCredential =
                    await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                //  await supaAuth.signUpWithEmailPasswordSupabase(email, password);

                await userCredential.user!.linkWithCredential(phoneCredential);

                String collection =
                    widget.userType == 'student' ? 'students' : 'instructors';
                await FirebaseFirestore.instance
                    .collection(collection)
                    .doc(userCredential.user!.uid)
                    .set({
                  'isProfileComplete': false,
                  'email': email,
                  'phone': formattedPhone,
                });

                await addUserToSupabase();

                Navigator.of(context).pop();
                navigateToNextScreen();
              } catch (e) {
                print('Error during registration: $e');
                Navigator.of(context).pop();

                try {
                  final user = _auth.currentUser;
                  if (user != null) {
                    await user.delete();
                  }
                } catch (cleanupError) {
                  print('Error during account cleanup: $cleanupError');
                }

                setState(() {
                  if (e is FirebaseAuthException &&
                      e.code == 'email-already-in-use') {
                    emailError = '*Email address already exists!';
                  } else {
                    phoneError =
                        '*Failed to complete registration(phone number may be already exists!). Please try again.';
                  }
                });
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void navigateToNextScreen() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BusyChildWidget(
            loadingWidget: const LoadingWidget(),
            child: FillYourProfile(
              userType: widget.userType,
              email: _emailController.text,
              phone: _phoneController.text,
            ),
          ),
        ),
      );
    }
  }

  void validateInputs() {
    setState(() {
      emailError = _emailController.text.isEmpty
          ? '*Email field cannot be empty!'
          : !RegExp(r'^[^@\s]+@[^@\s]+\.(com|org|net|edu|gov)$')
                  .hasMatch(_emailController.text)
              ? '*Invalid email address!'
              : null;
      passwordError = _passwordController.text.isEmpty
          ? '*Password field cannot be empty!'
          : null;
      confirmpasswordError = _confirmPasswordController.text.isEmpty
          ? '*Confirm password field cannot be empty!'
          : null;
      phoneError = _phoneController.text.isEmpty
          ? '*Phone field cannot be empty!'
          : null;
      termsError =
          !isTermsChecked ? '*You must agree to terms and conditions!' : null;

      RegExp passwordRegExp = RegExp(r'^(?=.*[A-Z])[A-Za-z0-9]{8,}$');
      if (!passwordRegExp.hasMatch(_passwordController.text)) {
        passwordError =
            '*Password must be at least 8 characters long, contain at least one uppercase letter, and include only letters and numbers.';
        confirmpasswordError =
            '*Password must be at least 8 characters long, contain at least one uppercase letter, and include only letters and numbers.';
      } else {
        passwordError = null;
        confirmpasswordError = null;
      }
    });

    if (emailError == null &&
        passwordError == null &&
        confirmpasswordError == null &&
        phoneError == null &&
        termsError == null) {
      register(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          'Help',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.help,
                              color: Colors.black,
                              size: 48,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Notice that password must be at least 8 characters long, contain at least one uppercase letter, and include only letters and numbers.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
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
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.help))
        ],
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentOrInstructor()));
            },
            icon: const Icon(
              CupertinoIcons.arrow_left,
              color: Colors.black,
            )),
        backgroundColor: Colors.transparent,
        toolbarHeight: 30.0,
      ),
      backgroundColor: const Color(0xffF5F9FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 2),
            Transform(
              transform: Matrix4.translationValues(-15, 0, 0),
              child: Image.asset('assets/images/EduraFirst.png'),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Getting Started!',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Jost',
                        fontWeight: FontWeight.w600,
                        color: Color(0xff202244),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Create an Account to Start exploring',
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
            const SizedBox(height: 30),
            CustomTextField(
              hintText: 'Email',
              prefix:
                  const Icon(Icons.email_outlined, color: Color(0xff545454)),
              isPrefix: true,
              isSuffix: false,
              controller: _emailController,
              errorMessage: emailError,
            ),
            const SizedBox(height: 17),
            CustomTextField(
              hintText: 'Phone Number',
              prefix: const Icon(Icons.phone, color: Color(0xff545454)),
              isPrefix: true,
              isSuffix: false,
              controller: _phoneController,
              errorMessage: phoneError,
            ),
            const SizedBox(height: 17),
            CustomTextField(
              hintText: 'Password',
              prefix: const Icon(Icons.lock_outline_sharp,
                  color: Color(0xff545454)),
              suffix: IconButton(
                icon: Icon(
                  isPasswordVisible
                      ? CupertinoIcons.eye
                      : CupertinoIcons.eye_slash,
                ),
                color: const Color(0xff545454),
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
            const SizedBox(height: 17),
            CustomTextField(
              hintText: 'Re-enter Password',
              prefix: const Icon(Icons.lock_outline_sharp,
                  color: Color(0xff545454)),
              suffix: IconButton(
                icon: Icon(
                  isReEnterPasswordVisible
                      ? CupertinoIcons.eye
                      : CupertinoIcons.eye_slash,
                ),
                color: const Color(0xff545454),
                onPressed: () {
                  setState(() {
                    isReEnterPasswordVisible = !isReEnterPasswordVisible;
                  });
                },
              ),
              isSuffix: true,
              isPrefix: true,
              isObscure: !isReEnterPasswordVisible,
              controller: _confirmPasswordController,
              errorMessage: confirmpasswordError,
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34.0),
              child: Row(
                children: [
                  CustomCheckbox(
                    iconFigOn: const Icon(
                      Icons.check_circle,
                      size: 25.0,
                      color: Colors.green,
                    ),
                    iconFigOff: const Icon(
                      Icons.radio_button_unchecked,
                      size: 25.0,
                      color: Colors.black,
                    ),
                    isChecked: isTermsChecked,
                    onChanged: (value) {
                      setState(() {
                        isTermsChecked = value;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TermsAndCondScreen())),
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Agree to ',
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (termsError != null)
              Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    termsError!,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                      fontFamily: 'Jost',
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 42),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 29.0),
              child: CustomElevatedBtn(
                horizontalPad: 72,
                onPressed: validateInputs,
                btnDesc: 'Sign Up',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Or Continue With',
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Mulish',
                  fontWeight: FontWeight.w700,
                  color: Color(0xff545454)),
            ),
            const SizedBox(
              height: 16,
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
                const SizedBox(
                  width: 40,
                ),
                Transform(
                    transform: Matrix4.translationValues(0, -9, 0),
                    child: GestureDetector(
                        child: Image.asset(
                      'assets/images/appleCircle.png',
                      height: 55,
                    ))),
              ],
            ),
            const SizedBox(
              height: 7,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an Account?',
                  style: TextStyle(
                      fontFamily: 'Mulish',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff545454)),
                ),
                const SizedBox(
                  width: 6,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignInScreen(
                                  userType: widget.userType,
                                )));
                  },
                  child: const Text(
                    'SIGN IN',
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
        ),
      ),
    );
  }
}
