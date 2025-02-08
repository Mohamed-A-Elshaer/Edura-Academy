import 'package:flutter/material.dart';

class Categorycard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const Categorycard({
    required this.title,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: isSelected
              ? const Color(0xff167F71)
              : const Color(0xffE8F1FF), 
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 12, color: isSelected
              ?  Colors.white
              :  const Color(0xffE8F1FF),),
          ),
        ),
      ),
    );
  }
}
