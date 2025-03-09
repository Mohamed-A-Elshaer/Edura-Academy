import 'package:flutter/material.dart';

class Categoryaddnewcard extends StatelessWidget {
  const Categoryaddnewcard(
      {super.key, required this.name, required this.name1});
  final String name;
  final String name1;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(right: 200),
        child: Text(
          name,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      const SizedBox(height: 10),
      Container(
        width: 350,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            name1,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      )
    ]);
  }
}
