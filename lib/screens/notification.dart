import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/widgets/categorysecurity.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Categorysecurity(n: "Special Offers"),
            SizedBox(height: 20),
            Categorysecurity(n: "Sound"),
            SizedBox(height: 20),
            Categorysecurity(n: "Vibrate"),
            SizedBox(height: 20),
            Categorysecurity(n: "General Notification"),
            SizedBox(height: 20),
            Categorysecurity(n: "Promo & Discount"),
            SizedBox(height: 20),
            Categorysecurity(n: "Payment Options"),
            SizedBox(height: 20),
            Categorysecurity(n: "App Update"),
            SizedBox(height: 20),
            Categorysecurity(n: "New Service Available"),
            SizedBox(height: 20),
            Categorysecurity(n: "New Tips Available"),
          ],
        ),
      ),
    );
  }
}
