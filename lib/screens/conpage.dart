import 'package:flutter/material.dart';

import 'InstructorNavigatorScreen.dart';
import 'StudentNavigatorScreen.dart';

class CongratulationsPage extends StatefulWidget {
  final String? userType;
  String?password;

   CongratulationsPage({super.key,this.userType,this.password});

  @override
  State<CongratulationsPage> createState() => _CongratulationsPageState();
}

class _CongratulationsPageState extends State<CongratulationsPage> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }
  void _navigateAfterDelay() {
    Future.delayed(const Duration(seconds: 7), () {

        Widget destination = widget.userType == 'student'
            ? NavigatorScreen(password: widget.password,)
            : InstructorNavigatorScreen(password: widget.password,);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
Image.asset('assets/images/congGreenMark.png'),
                  const SizedBox(height: 16),
                  const Text(
                    'Congratulations',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Account is Ready to Use.\nYou will be redirected to the Home Page in a Few Seconds.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
