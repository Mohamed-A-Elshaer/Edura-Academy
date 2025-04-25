import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CourseOnAction extends StatelessWidget{
  final String title;
  final String category;
  final String imagePath;

  CourseOnAction({
    required this.title,
    required this.category,
    required this.imagePath,
  });
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
            // Add Expanded to the image container to limit its width
            Expanded(
              flex: 2, // Gives 2 parts of space to image
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: 86,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imagePath,
                    height: 60,
                    width: 100, // Add fixed width
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Add Expanded to the text column
            Expanded(
              flex: 3, // Gives 3 parts of space to text
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 12,
                        color: Color(0xffFF6B00),
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis, // Prevent text overflow
                  ),
                  SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 14,
                        color: Color(0xff202244),
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis, // Prevent text overflow
                    maxLines: 2, // Limit to 2 lines
                  ),
                ],
              ),
            ),
          ],
    ),
    );
  }


}