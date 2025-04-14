import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  final Icon iconFigOn;
  final Icon iconFigOff;
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const CustomCheckbox({
    super.key,
    required this.iconFigOn,
    required this.iconFigOff,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  CustomCheckboxState createState() => CustomCheckboxState();
}

class CustomCheckboxState extends State<CustomCheckbox> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.isChecked;
  }

  @override
  void didUpdateWidget(CustomCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChecked != oldWidget.isChecked) {
      setState(() {
        _isChecked = widget.isChecked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isChecked = !_isChecked;
        });
        widget.onChanged(_isChecked);
      },
      child: _isChecked ? widget.iconFigOn : widget.iconFigOff,
    );
  }
}