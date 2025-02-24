import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/EnterYourPhoneResetEmail.dart';
import 'package:mashrooa_takharog/screens/EnterYourResetEmail.dart';
import 'package:mashrooa_takharog/screens/SignInScreen.dart';
import 'package:mashrooa_takharog/screens/StudentOrInstructor.dart';
import 'package:mashrooa_takharog/widgets/customElevatedBtn.dart';
import 'package:mashrooa_takharog/widgets/customTextField.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => StudentOrInstructor()));
          },
          icon: const Icon(CupertinoIcons.arrow_left, color: Colors.black),
        ),
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            color: Color(0xff202244),
            fontFamily: 'Jost',
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xffF5F9FF),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 240),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 43.0),
              child: Text(
                'Select which contact details should we use to Reset Your Password',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 14,
                  color: Color(0xff545454),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedOption = 'email';
                });
                debugPrint('Email option tapped');
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedOption == 'email'
                        ? Colors.blue
                        : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(8.0),
                child: IgnorePointer(
                  child: CustomTextField(
                    isPrefix: true,
                    isSuffix: false,
                    hpad: 55,
                    prefixConstraints: 80,
                    height: 75,
                    prefix: Image.asset(
                      'assets/images/ForgotPasswordIcon.png',
                      height: 36,
                    ),
                    readOnly: true,
                    labelText: 'Via Email',
                    labelSize: 16,
                    hintText: 'Select to enter your email',
                    hintColor: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedOption = 'sms';
                });
                debugPrint('SMS option tapped');
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedOption == 'sms'
                        ? Colors.blue
                        : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.all(8.0), // Ensure padding for tap area
                child: IgnorePointer(
                  child: CustomTextField(
                    isPrefix: true,
                    isSuffix: false,
                    hpad: 55,
                    prefixConstraints: 80,
                    height: 75,
                    prefix: Image.asset(
                      'assets/images/ForgotPasswordIcon.png',
                      height: 36,
                    ),
                    readOnly: true,
                    labelText: 'Via SMS',
                    labelSize: 16,
                    hintText: 'Select to enter your phone number',
                    hintColor: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            CustomElevatedBtn(
              btnDesc: 'Continue',
              horizontalPad: 75,
              onPressed: () {
                if (_selectedOption == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select an option')),
                  );
                } else {
                  if (_selectedOption == 'email') {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EnterYourResetEmail()));
                  } else if (_selectedOption == 'sms') {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EnterYourPhoneResetEmail()));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
