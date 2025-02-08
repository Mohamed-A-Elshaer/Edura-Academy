
import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
   CustomCheckbox({
    super.key,
    this.isChecked = false,
    required this.iconFigOn,
    required this.iconFigOff,
     required this.onChanged,
  });

  final Icon iconFigOn;
  final Icon iconFigOff;
   bool isChecked;
   final ValueChanged<bool> onChanged;

  @override
  CustomCheckboxState createState() => CustomCheckboxState();
}


class CustomCheckboxState extends State<CustomCheckbox> {
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      onTap: () {
        setState(() {
          _isChecked = !_isChecked;
          widget.onChanged(_isChecked);
        });
      },
      child: _isChecked
          ? widget.iconFigOn
          : widget.iconFigOff
    );

  }
}