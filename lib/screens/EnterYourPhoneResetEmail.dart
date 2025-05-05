import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/ForgotPasswordScreen.dart';
import 'package:mashrooa_takharog/screens/forgotpasswordpage.dart';
import '../widgets/customElevatedBtn.dart';

class EnterYourPhoneResetEmail extends StatefulWidget {
  @override
  State<EnterYourPhoneResetEmail> createState() =>
      _EnterYourPhoneResetEmailState();
}

class _EnterYourPhoneResetEmailState extends State<EnterYourPhoneResetEmail> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _verificationId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<String?> _getUidByPhoneNumber(String phoneNumber) async {
    try {
      String normalizedPhone = phoneNumber.replaceFirst('+20', '');

      QuerySnapshot instructorSnapshot = await _firestore
          .collection('instructors')
          .where('phone', isEqualTo: normalizedPhone)
          .get();

      if (instructorSnapshot.docs.isNotEmpty) {
        return instructorSnapshot.docs.first.id;
      }

      QuerySnapshot studentSnapshot = await _firestore
          .collection('students')
          .where('phone', isEqualTo: normalizedPhone)
          .get();

      if (studentSnapshot.docs.isNotEmpty) {
        return studentSnapshot.docs.first.id;
      }


      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching UID: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<void> _sendCodeToPhoneNumber() async {
    if (_formKey.currentState!.validate()) {
      String phoneNumber = _phoneController.text.trim();

      if (!phoneNumber.startsWith('+20')) {
        phoneNumber = '+20$phoneNumber';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wait for authentication...'),
          duration: Duration(seconds: 7),
        ),
      );

      String? uid = await _getUidByPhoneNumber(phoneNumber);

      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number is not registered.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          codeSent: (String verificationId, int? resendToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForgotPasswordPage(
                  verificationId: verificationId,
                  phoneNumber: phoneNumber,
                  uid: uid,
                ),
              ),
            );
          },
          verificationCompleted: (PhoneAuthCredential credential) {
          },
          verificationFailed: (FirebaseAuthException e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.message}')),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Handle timeout
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ForgotPasswordScreen(),
              ),
            );
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
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Don\'t worry, sometimes people can forget too. Enter your phone number and we will send you a password reset link.',
                style: TextStyle(
                  color: Color(0xff545454),
                  fontSize: 14,
                  fontFamily: 'Mulish',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_android, color: Color(0xff545454)),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !RegExp(r'^(010|011|012|015)\d{8}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 30),
             CustomElevatedBtn(
              btnDesc: 'Submit',
              horizontalPad: 83,
              onPressed: _sendCodeToPhoneNumber,
            ),
          ],
        ),
      ),
    );
  }
}
