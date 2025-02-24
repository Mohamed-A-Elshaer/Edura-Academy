import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mashrooa_takharog/auth/controllers/forget_password_controller.dart';
import 'package:mashrooa_takharog/screens/SignInScreen.dart';
import 'package:mashrooa_takharog/screens/StudentOrInstructor.dart';

class ResetPassDecisionScreen extends StatelessWidget {
  final String email;

  const ResetPassDecisionScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 80,
            ),
            Image.asset(
              'assets/images/verified.png',
              height: 220,
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Password Reset Email Sent',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 27,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 24,
            ),
            Text(email,
                style: const TextStyle(
                    color: Color(0xff545454),
                    fontSize: 14,
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w800)),
            const SizedBox(
              height: 24,
            ),
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                  'Your Account Security is Our Priority! We\'ve Sent You a Secure Link to Safely Change Your Password and Keep Your Account Protected.',
                  style: TextStyle(
                      color: Color(0xff545454),
                      fontSize: 14,
                      fontFamily: 'Mulish',
                      fontWeight: FontWeight.w800)),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 57,
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () => Get.offAll(() => StudentOrInstructor()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.white),
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 57,
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () => ForgetPasswordController.instance
                      .resendPasswordResetEmail(email),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: const Text('Resend Email')),
            ),
          ],
        ),
      ),
    );
  }
}
