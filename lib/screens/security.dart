import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/notification.dart';
import 'package:mashrooa_takharog/widgets/categorysecurity.dart';

class Security extends StatelessWidget {
  const Security({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Security',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Categorysecurity(n: 'Remember Me'),
            const SizedBox(height: 30),
            const Categorysecurity(n: 'Biometric ID'),
            const SizedBox(height: 30),
            const Categorysecurity(n: 'Face ID'),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Google Authenticator',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const NotificationPage();
                        },
                      ));
                    },
                    icon: const Text(
                      '>',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
