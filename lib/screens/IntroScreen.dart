import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/StudentOrInstructor.dart';
import 'package:mashrooa_takharog/screens/letsYouInScreen.dart';
import 'package:mashrooa_takharog/widgets/Intro_widget.dart';
import '../widgets/pageIndicator.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  final List<IntroWidget> introsList = [
    IntroWidget(
        titleText: 'Online Learning',
        descriptionText: 'We Provide Online Classes and Pre Recorded Lectures.'),
    IntroWidget(
        titleText: 'Learn Anytime',
        descriptionText: 'Book or Save Lectures for Future Reference.'),
    IntroWidget(
        titleText: 'Live the Full Experience',
        descriptionText: 'Every moment. Every lesson. All in your hands.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F9FF),
      body: Column(
        children: [
          SizedBox(height: 70),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: GestureDetector(
                  onTap: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>StudentOrInstructor()));},
                  child: Text(
                    'Skip',
                    style: TextStyle(
                        fontFamily: 'Jost', fontSize: 16, color: Color(0xff202244)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 350),

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

          Container(
            height: 150,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PageIndicator(currentIndex: currentIndex, introList: introsList),


                currentIndex==introsList.length-1? ElevatedButton(

                  onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> StudentOrInstructor()));

                },
                  child: Transform(

                    transform: Matrix4.translationValues(20, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Get Started',
                          style: TextStyle(fontFamily: 'Jost',fontSize: 18,color: Colors.white,fontWeight: FontWeight.w600),),
                        Image.asset('assets/images/arrow_right.png'),
                      ],

                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    fixedSize: Size(204,60),
                    backgroundColor: Color(0xff0961F5),


                  ),

                )

                    : FloatingActionButton(
                    child: Icon(
                      CupertinoIcons.arrow_right,
                      color: Colors.white,
                      size: 36,
                    ),
                    onPressed: () {
                      if (currentIndex < introsList.length - 1) {
                        _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      }
                    },
                    backgroundColor: Color(0xff0961F5),
                    elevation: 4,
                    shape: CircleBorder(),
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
