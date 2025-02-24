import 'package:flutter/material.dart';
import 'Intro_widget.dart';

class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final List<IntroWidget> introList;

  const PageIndicator(
      {super.key, required this.currentIndex, required this.introList});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        introList.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: AnimatedContainer(
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 500),
            width: index == currentIndex ? 28 : 13,
            height: 13,
            decoration: BoxDecoration(
              color: index == currentIndex
                  ? const Color(0xff0961F5)
                  : const Color(0xffD5E2F5),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
