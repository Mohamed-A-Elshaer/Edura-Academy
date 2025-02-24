import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  Color? hintColor;
  TextEditingController? controller;
  GestureTapCallback? onTap;
  bool? readOnly;
  double? cursorHeight;
  String? labelText;
  final String? hintText;
  final Widget? prefix;
  final IconButton? suffix;
  final bool isPrefix;
  final bool isSuffix;
  bool? isObscure;
  double? prefixConstraints;
  double? hpad;
  double? vpad;
  double? height;
  double? labelSize;
  final List<String>? dropdownItems;
  final ValueChanged<String?>? onDropdownChanged;
  final String? errorMessage;

  CustomTextField(
      {super.key,
      this.hintColor,
      this.hintText,
      this.isObscure,
      this.prefix,
      this.suffix,
      required this.isPrefix,
      this.hpad,
      this.vpad,
      this.prefixConstraints,
      this.height,
      this.labelSize,
      required this.isSuffix,
      this.dropdownItems,
      this.onDropdownChanged,
      this.labelText,
      this.cursorHeight,
      this.readOnly,
      this.controller,
      this.onTap,
      this.errorMessage});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 320,
          height: widget.height ?? 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 1,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            onTap: widget.onTap,
            readOnly: widget.readOnly ?? false,
            cursorHeight: widget.cursorHeight,
            obscureText: widget.isObscure ?? false,
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: const Color(0xff505050),
                fontSize: widget.labelSize ?? 14,
                fontFamily: 'Mulish',
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: widget.hintColor ?? const Color(0xff505050),
                fontSize: 14,
                fontFamily: 'Mulish',
              ),
              prefixIcon: widget.isPrefix ? widget.prefix : null,
              suffixIcon: widget.dropdownItems != null
                  ? DropdownButton<String>(
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Color(0xff545454)),
                      underline: const SizedBox(), // Remove default underline
                      dropdownColor: Colors.white,
                      items: widget.dropdownItems!
                          .map((item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ))
                          .toList(),
                      onChanged: widget.onDropdownChanged,
                    )
                  : (widget.isSuffix ? widget.suffix : null),
              prefixIconConstraints:
                  BoxConstraints(minWidth: widget.prefixConstraints ?? 30),
              suffixIconConstraints: const BoxConstraints(minWidth: 30),
              contentPadding: EdgeInsets.symmetric(
                  vertical: widget.vpad ?? 18, horizontal: widget.hpad ?? 0),
            ),
            style: const TextStyle(color: Colors.black),
          ),
        ),
        if (widget.errorMessage != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 5, left: 16),
              child: Text(
                widget.errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontFamily: 'Mulish',
                ),
              ),
            ),
          ),
      ],
    );
  }
}
