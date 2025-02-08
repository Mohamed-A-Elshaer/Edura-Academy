import 'package:flutter/material.dart';
import 'Intro_widget.dart';

class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final List<IntroWidget> introList;

  PageIndicator({required this.currentIndex, required this.introList});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        introList.length,
            (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 7),
          child: AnimatedContainer(
            curve: Curves.easeIn,
            duration: Duration(milliseconds: 500),
            width: index == currentIndex ? 28 : 13,
            height: 13,
            decoration: BoxDecoration(
              color: index == currentIndex ? Color(0xff0961F5) : Color(0xffD5E2F5),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
