import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CourseOnAction extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 120,
        width: 360,
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.2),
    spreadRadius: 1,
    blurRadius: 6,
    offset: Offset(4, 4),
    ),
    ],
        ),

        child: Row(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 86,


            child: ClipRRect(
              borderRadius: BorderRadius.circular(20), // Ensure the image is clipped
              child: Image.asset(
                'assets/images/advertisment.jpg',
                height: 60,
                fit: BoxFit.cover, // Ensures the image fills the container properly
              ),
            ),

    ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40,),
              Text('Graphic Design',style: TextStyle(fontFamily: 'Mulish',fontSize: 12,color: Color(0xffFF6B00),fontWeight: FontWeight.w700),),
             SizedBox(height: 10,),
              Text('Setup your Graphic Desig..',style: TextStyle(fontFamily: 'Jost',fontSize: 14,color: Color(0xff202244),fontWeight: FontWeight.w600),),

            ],
          )

      ],
    ),
    );
  }


}