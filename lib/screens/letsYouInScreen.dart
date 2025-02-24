import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/SignInScreen.dart';
import 'package:mashrooa_takharog/screens/SignUpScreen.dart';
import 'package:mashrooa_takharog/widgets/customElevatedBtn.dart';

import '../auth/auth_service.dart';
import 'StudentOrInstructor.dart';

class LetsYouIn extends StatelessWidget {
  final String userType;
  const LetsYouIn({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF),
      body: Column(
        children: [
          const SizedBox(
            height: 70,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Transform(
                transform: Matrix4.translationValues(-20, 0, 0),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentOrInstructor(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 180,
          ),
          const Text(
            'Let\'s you in',
            style: TextStyle(
                fontSize: 24, color: Color(0xff202244), fontFamily: 'Jost'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => AuthService().signInWithGoogle(context, userType),
                child: Image.asset(
                  'assets/images/googleCircle.png',
                  height: 55,
                ),
              ),
              GestureDetector(
                onTap: () => AuthService().signInWithGoogle(context, userType),
                child: const Text(
                  'Continue with Google',
                  style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff545454),
                      fontFamily: 'Mulish',
                      fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Transform(
            transform: Matrix4.translationValues(-5, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Image.asset(
                    'assets/images/appleCircle.png',
                    height: 55,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Continue with Apple',
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xff545454),
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          const Text(
            "( Or ) ",
            style: TextStyle(
                fontSize: 15,
                fontFamily: 'Mulish',
                fontWeight: FontWeight.w800,
                color: Color(0xff545454)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 30,
          ),
          CustomElevatedBtn(
            btnDesc: 'Sign In with Your Account',
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignInScreen(
                            userType: userType,
                          )));
            },
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Don\'t have an Account?',
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
                          builder: (context) => SignUpScreen(
                                userType: userType,
                              )));
                },
                child: const Text(
                  'SIGN UP',
                  style: TextStyle(
                      shadows: [
                        Shadow(color: Color(0xff0961F5), offset: Offset(0, -1))
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
    );
  }
}
