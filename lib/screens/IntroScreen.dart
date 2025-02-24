import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/StudentOrInstructor.dart';
import 'package:mashrooa_takharog/screens/letsYouInScreen.dart';
import 'package:mashrooa_takharog/widgets/Intro_widget.dart';
import '../widgets/pageIndicator.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  final List<IntroWidget> introsList = [
    IntroWidget(
        titleText: 'Online Learning',
        descriptionText:
            'We Provide Online Classes and Pre Recorded Lectures.'),
    IntroWidget(
        titleText: 'Learn Anytime',
        descriptionText: 'Book or Save Lectures for Future Reference.'),
    IntroWidget(
        titleText: 'Get Online Certificate',
        descriptionText: 'Analyze your scores and track your results.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF),
      body: Column(
        children: [
          const SizedBox(height: 70),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StudentOrInstructor()));
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 16,
                        color: Color(0xff202244)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 350),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: introsList.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return introsList[index];
              },
            ),
          ),
          SizedBox(
            height: 150,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PageIndicator(
                      currentIndex: currentIndex, introList: introsList),
                  currentIndex == introsList.length - 1
                      ? ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        StudentOrInstructor()));
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            fixedSize: const Size(204, 60),
                            backgroundColor: const Color(0xff0961F5),
                          ),
                          child: Transform(
                            transform: Matrix4.translationValues(20, 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Get Started',
                                  style: TextStyle(
                                      fontFamily: 'Jost',
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                                Image.asset('assets/images/arrow_right.png'),
                              ],
                            ),
                          ),
                        )
                      : FloatingActionButton(
                          onPressed: () {
                            if (currentIndex < introsList.length - 1) {
                              _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                            }
                          },
                          backgroundColor: const Color(0xff0961F5),
                          elevation: 4,
                          shape: const CircleBorder(),
                          child: Icon(
                            CupertinoIcons.arrow_right,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
