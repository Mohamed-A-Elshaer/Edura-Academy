import 'package:flutter/material.dart';

class Categorysecurity extends StatefulWidget {
  const Categorysecurity({super.key, required this.n});
  final String n;
  @override
  State<Categorysecurity> createState() => _CategorysecurityState();
}

class _CategorysecurityState extends State<Categorysecurity> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.n,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Switch(
          value: isSwitched,
          onChanged: (value) {
            setState(() {
              isSwitched = value;
            });
          },
          activeColor: Colors.blue,
        ),
      ],
    );
  }
}
