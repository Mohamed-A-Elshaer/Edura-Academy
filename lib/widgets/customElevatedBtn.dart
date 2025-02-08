import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomElevatedBtn extends StatelessWidget{
  String btnDesc;
  double horizontalPad;
  VoidCallback? onPressed;
double? btnWidth;

   CustomElevatedBtn({super.key,required this.btnDesc,this.horizontalPad=0,this.onPressed,this.btnWidth});

  @override
  Widget build(BuildContext context) {
   return ElevatedButton(onPressed: onPressed??(){},
     child: Transform(

       transform: Matrix4.translationValues(20, 0, 0),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Padding(
             padding:  EdgeInsets.symmetric(horizontal: horizontalPad),
             child: Text(btnDesc,
               style: TextStyle(fontFamily: 'Jost',fontSize: 18,color: Colors.white,fontWeight: FontWeight.w600)),
           ),
           Image.asset('assets/images/arrow_right.png'),
         ],

       ),
     ),
     style: ElevatedButton.styleFrom(
       elevation: 5,
       fixedSize: Size(btnWidth??350,70),
       backgroundColor: Color(0xff0961F5),


     ),

   );

  }


}