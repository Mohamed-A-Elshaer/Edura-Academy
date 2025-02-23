import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/widgets/CourseOnAction.dart';
import 'package:mashrooa_takharog/widgets/customElevatedBtn.dart';

import '../widgets/customTextField.dart';

class PaymentDecisionScreen extends StatefulWidget{
  @override
  State<PaymentDecisionScreen> createState() => _PaymentDecisionScreenState();
}

class _PaymentDecisionScreenState extends State<PaymentDecisionScreen> {
  bool isSelected=false;
  
  @override
  Widget build(BuildContext context) {
return Scaffold(
    appBar: AppBar(
    leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: (){}
    ),
    title: const Text('Payment Methods'),
    ),
  body: Column(
    children: [
      const SizedBox(height: 30,),
      CourseOnAction(),
  const SizedBox(height: 80,),

      Align(
        alignment: Alignment.centerLeft,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Select the Payment Method you Want to Use',
            style: TextStyle(
              fontFamily: 'Mulish',
              fontSize: 14,
              color: Color(0xff545454),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      const SizedBox(height: 18,),
  Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(4, 4),
            ),
          ],
        ),


          child: CustomTextField(
            isPrefix: true,
            isSuffix: false,
            prefix: GestureDetector(
              onTap: (){
                setState(() {
                  isSelected=!isSelected;

                });
              },
              child: isSelected? Icon(Icons.radio_button_checked,color: Color(0xff167F71),):Icon(Icons.radio_button_off,color: Color(0xffB4BDC4),) ,
            ),
            hpad: 55,
            prefixConstraints: 80,
            height: 65,
            readOnly: true,
            labelSize: 16,
            hintText: 'Visa Card',
            hintColor: Colors.black,
          ),
        ),
    ),
  ),
      SizedBox(height: 90,),
      Align(
          alignment: Alignment.center,
          child: CustomElevatedBtn(onPressed: (){ _showConfirmationDialog(context);},btnDesc: 'Enroll Course -750EGP'))

    ],
  ),


    );
  }



  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Stack(
          children: [

            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur effect
              child: Container(
                color: Colors.black.withOpacity(0.2), // Dark overlay
              ),
            ),

            // Dialog Box
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Rounded Borders
              ),
              contentPadding: EdgeInsets.all(20),
              title: Text(
                'Confirm Payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Jost'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you sure you want to proceed with the payment?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontFamily: 'Mulish'),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel',
                            style: TextStyle(color: Colors.grey[700])),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showCongratulationsDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff167F71),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Confirm', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
              contentPadding: EdgeInsets.all(20),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 40),
                    Image.asset('assets/images/congGreenMark.png',height: 190,),
                    Text(
                      'Congratulations!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Jost'),
                    ),
                    SizedBox(height: 17),

                    Text(
                      'You Purchased the Course Successfully. Purchase a New Course as soon as possible!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Mulish',color: Color(0xff545454)),
                    ),
                    SizedBox(height: 13,),
                    InkWell(
                      onTap: () {
                      },
                      child: Text(
                        'Watch the Course',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Mulish',
                          fontWeight: FontWeight.bold,
                          color: Color(0xff167F71),
                          decoration: TextDecoration.underline, // Underline text
                        ),
                      ),
                    ),
                    SizedBox(height: 10),


                    CustomElevatedBtn(
                      btnDesc: 'E-Receipt',
                      btnWidth: 200,
                      onPressed: () {}, // Empty action
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