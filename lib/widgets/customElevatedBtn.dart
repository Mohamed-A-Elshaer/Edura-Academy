import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomElevatedBtn extends StatelessWidget {
  final String btnDesc;
  final VoidCallback? onPressed;

  const CustomElevatedBtn({
    super.key,
    required this.btnDesc,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final buttonWidth = screenWidth * 0.9;

    return ElevatedButton(
      onPressed: onPressed ?? () {},
      style: ElevatedButton.styleFrom(
        elevation: 5,
        fixedSize: Size(buttonWidth, 70),
        backgroundColor: const Color(0xff0961F5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              btnDesc,
              style: const TextStyle(
                fontFamily: 'Jost',
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Image.asset('assets/images/arrow_right.png'),
        ],
      ),
    );
  }
}
