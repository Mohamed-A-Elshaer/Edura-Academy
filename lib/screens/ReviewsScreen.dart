import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mashrooa_takharog/screens/WriteReviewScreen.dart';
import 'package:mashrooa_takharog/screens/search_courses_page.dart';
import 'package:mashrooa_takharog/widgets/CourseComment.dart';

import '../widgets/customElevatedBtn.dart';


class ReviewsScreen extends StatefulWidget{
  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  double rating=0;

  static  final List<Map<String, dynamic>> ratingCategories = [
    {"title": "Excellent"},
    {"title": "Good"},
    {"title": "Average"},
    {"title": "Below Average"},
  ];
  static int selectedCardIndex = -1;

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: (){}
      ),
      title: const Text('Reviews'),
    ),

    body:  Stack(
      children: [

        Column(
          children: [
            SizedBox(height: 25,),
            Center(
              child: Text('4.8',style: TextStyle(color: Color(0xff202244),fontFamily: 'Jost',fontWeight: FontWeight.w600,fontSize: 38),),
            ),
            Center(
              child: RatingBar.builder(
                minRating: 1,
                  itemBuilder: (context,_)=>Icon(Icons.star,color: Colors.amber,),
                onRatingUpdate: (double value) {  },
                itemSize: 25,
                ignoreGestures: true,
                initialRating: 4.8,
                allowHalfRating: true,
              )
            ),
            Center(
              child: Text('Based on 448 Reviews',style: TextStyle(fontFamily: 'Mulish',color: Color(0xff545454),fontSize: 13,fontWeight: FontWeight.w700),),
            ),
        SizedBox(height: 20,),



           SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ratingCategories.length,
                  itemBuilder: (context, index) {
                    final data = ratingCategories[index];
                    return GestureDetector(
                      onTap: (){
                        setState(() {
                          selectedCardIndex=index;
                        });

                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: selectedCardIndex == index
                              ? const Color(0xff167F71)
                              : Colors.grey[200],
                        ),
                        child: Center(
                          child: Text(
                            data['title'] ?? '',
                            style: TextStyle(
                              color: selectedCardIndex == index
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 16,),
            Expanded(
              child: ListView.builder(
              itemCount: 15,
                  itemBuilder:(context,index){
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: CourseComment(),
                    );

                  } ),
            ),
            SizedBox(height: 60,),
          ],
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: CustomElevatedBtn(btnWidth: double.infinity ,btnDesc: 'Write a Review',horizontalPad: 71,onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>WriteReviewScreen()));

          },),
        )
    ]
    ),
  );
  }
}