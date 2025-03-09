// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/widgets/categorylanguage.dart';

class Language extends StatelessWidget {
  const Language({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Language',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 210.0),
              child: Text(
                'All Language',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            CategoryLanguage(),
          ],
        ),
      ),
    );
  }
}
