import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mashrooa_takharog/screens/WriteReviewScreen.dart';
import 'package:mashrooa_takharog/widgets/customElevatedBtn.dart';

class DialougeTestScreen extends StatelessWidget {
  const DialougeTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomElevatedBtn(
          btnDesc: 'Press',
          onPressed: () {
            _showCongratulationsDialog(context);
          },
        ),
      ),
    );
  }

  void _showCongratulationsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Rounded Borders
              ),
              contentPadding: const EdgeInsets.all(20),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    Image.asset(
                      'assets/images/congGreenMark.png',
                      height: 190,
                    ),
                    const Text(
                      'Congratulations!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Jost'),
                    ),
                    const SizedBox(height: 17),
                    const Text(
                      'You have Completed the Course Successfully! Please Rate & Write your Review on the Course.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Mulish',
                          color: Color(0xff545454)),
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                    Center(
                        child: RatingBar.builder(
                      minRating: 0,
                      glow: true,
                      glowColor: Colors.amberAccent, // Color of the glow effect
                      glowRadius: 3,
                      updateOnDrag: true,

                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (double value) {},
                      itemSize: 25,
                      allowHalfRating: true,
                    )),
                    const SizedBox(height: 30),
                    CustomElevatedBtn(
                      btnDesc: 'Write a Review',
                      btnWidth: 250,
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WriteReviewScreen()));
                      }, // Empty action
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
