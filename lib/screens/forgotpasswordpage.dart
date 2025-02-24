import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/StudentOrInstructor.dart';
import 'EnterYourPhoneResetEmail.dart';
import 'craetnewpass.dart';
import 'numerickeyboard.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final String uid;

  const ForgotPasswordPage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.uid,
  });

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  List<String> enteredCode = ['', '', '', '', '', ''];
  bool isLoading = false;

  void updateCode(int index, String value) {
    setState(() {
      enteredCode[index] = value;
    });
  }

  void deleteCode() {
    setState(() {
      for (int i = enteredCode.length - 1; i >= 0; i--) {
        if (enteredCode[i] != '') {
          enteredCode[i] = '';
          break;
        }
      }
    });
  }

  bool isCodeComplete() {
    return !enteredCode.contains('');
  }

  Future<void> verifyOtpAndNavigate() async {
    String otpCode = enteredCode.join();

    try {
      setState(() {
        isLoading = true;
      });

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otpCode,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NewPass(
              phoneNumber: widget.phoneNumber,
              uid: widget.uid,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _maskPhoneNumber(String phoneNumber) {
    String visiblePart = phoneNumber.substring(phoneNumber.length - 3);
    return '(+20) ***-***-*$visiblePart';
  }

  @override
  Widget build(BuildContext context) {
    String maskedPhoneNumber = _maskPhoneNumber(widget.phoneNumber);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => EnterYourPhoneResetEmail()),
            );
          },
        ),
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Code has been sent to $maskedPhoneNumber',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        enteredCode[index],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed:
                  isCodeComplete() && !isLoading ? verifyOtpAndNavigate : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Verify',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 30),
            NumericKeypad(
              onNumberPressed: (String value) {
                for (int i = 0; i < 6; i++) {
                  if (enteredCode[i] == '') {
                    updateCode(i, value);
                    break;
                  }
                }
              },
              onDeletePressed: deleteCode,
            ),
          ],
        ),
      ),
    );
  }
}
