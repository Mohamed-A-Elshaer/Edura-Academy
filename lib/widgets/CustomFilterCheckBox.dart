import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'CustomCheckBox.dart';

class CustomFilterCheckBox extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Function(bool) onChanged;

  const CustomFilterCheckBox({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomCheckbox(
          iconFigOn: Icon(Icons.check_box, color: Color(0xff167F71), size: 30),
          iconFigOff: Icon(CupertinoIcons.square, color: Color(0xff167F71), size: 30),
          isChecked: isSelected,
          onChanged: onChanged,
        ),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Mulish',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xff202244).withOpacity(0.8),
          ),
        )
      ],
    );
  }
}