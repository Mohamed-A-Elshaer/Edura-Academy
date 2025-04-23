import 'package:appwrite/appwrite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mashrooa_takharog/auth/Appwrite_service.dart';
import 'package:mashrooa_takharog/screens/MyCoursesScreen.dart';
import 'package:mashrooa_takharog/screens/WriteReviewScreen.dart';
import 'package:mashrooa_takharog/screens/search_courses_page.dart';
import 'package:mashrooa_takharog/widgets/CourseComment.dart';

import '../widgets/customElevatedBtn.dart';


class ReviewsScreen extends StatefulWidget{

  final String courseId;
  final String userId;

  ReviewsScreen({required this.courseId, required this.userId});
  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  double rating = 0;
  double averageRating = 0;
  int totalRatings = 0;
  bool hasRated = false;
  @override
  void initState() {
    super.initState();
    fetchRatingData();
  }
  Future<void> fetchRatingData() async {
    // 1. Fetch course doc (avgRating, totalRatings)
    final courseDoc = await Appwrite_service.databases.getDocument(
      collectionId: '67c1c87c00009d84c6ff',
      documentId: widget.courseId,
      databaseId: '67c029ce002c2d1ce046',
    );
    setState(() {
      averageRating = courseDoc.data['averageRating']?.toDouble() ?? 0.0;
      totalRatings = courseDoc.data['totalRatings'] ?? 0;
    });

    // 2. Check if user already rated it
    final ratingDocs = await Appwrite_service.databases.listDocuments(
      collectionId: '6808c1e500186c675d9b',
      queries: [
        Query.equal('courseId', widget.courseId),
        Query.equal('userId', widget.userId),
      ],
      databaseId: '67c029ce002c2d1ce046',
    );
    if (ratingDocs.documents.isNotEmpty) {
      setState(() {
        hasRated = true;
        rating = ratingDocs.documents.first.data['rating']?.toDouble() ?? 0;
      });
    }
  }

  Future<void> handleRating(double newRating) async {
    // Step 1: Fetch course name
    final courseDoc = await Appwrite_service.databases.getDocument(
      collectionId: '67c1c87c00009d84c6ff',
      documentId: widget.courseId,
      databaseId: '67c029ce002c2d1ce046',
    );
    final courseName = courseDoc.data['title'];

    // Step 2: Fetch user document
    final userDoc = await Appwrite_service.databases.getDocument(
      collectionId: '67c0cc3600114e71d658',
      documentId: widget.userId,
      databaseId: '67c029ce002c2d1ce046',
    );

    List<dynamic> ratedCourses = userDoc.data['ratedCourseIds'] ?? [];

    // Step 3: Append courseName if not already rated
    if (!ratedCourses.contains(courseName)) {
      ratedCourses.add(courseName);
      await Appwrite_service.databases.updateDocument(
        collectionId: '67c0cc3600114e71d658',
        documentId: widget.userId,
        databaseId: '67c029ce002c2d1ce046',
        data: {'ratedCourseIds': ratedCourses},
      );
    }

    if (!hasRated) {
      // New rating
      await Appwrite_service.databases.createDocument(
        collectionId: '6808c1e500186c675d9b',
        documentId: ID.unique(), // or Appwrite ID generator
        data: {
          'courseId': widget.courseId,
          'userId': widget.userId,
          'rating': newRating.toInt(),
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
        databaseId: '67c029ce002c2d1ce046',
      );

      // Update course doc
      final newSum = (averageRating * totalRatings) + newRating;
      final newTotal = totalRatings + 1;
      final newAvg = newSum / newTotal;

      List<dynamic> ratedUserIds = courseDoc.data['ratedUserIds'] ?? [];
      if (!ratedUserIds.contains(widget.userId)) {
        ratedUserIds.add(widget.userId);
      }

      await Appwrite_service.databases.updateDocument(
        collectionId: '67c1c87c00009d84c6ff',
        documentId: widget.courseId,
        data: {
          'ratingSum': newSum.toInt(),
          'totalRatings': newTotal,
          'averageRating': double.parse(newAvg.toStringAsFixed(1)),
          'ratedUserIds': ratedUserIds, // append
        }, databaseId: '67c029ce002c2d1ce046',
      );
      setState(() {
        averageRating = newAvg;
        totalRatings = newTotal;
        hasRated = true;
        rating = newRating;
      });
    } else {
      // Update previous rating
      final ratingDoc = (await Appwrite_service.databases.listDocuments(
        collectionId: '6808c1e500186c675d9b',
        queries: [
          Query.equal('courseId', widget.courseId),
          Query.equal('userId', widget.userId),
        ],
          databaseId: '67c029ce002c2d1ce046'
      ))
          .documents
          .first;

      final oldRating = ratingDoc.data['rating'] ?? 0;
      final newSum = (averageRating * totalRatings - oldRating + newRating);
      final newAvg = newSum / totalRatings;

      await Appwrite_service.databases.updateDocument(
        collectionId: '6808c1e500186c675d9b',
        documentId: ratingDoc.$id,
        data: {'rating': newRating.toInt(), 'timestamp': DateTime.now().toUtc().toIso8601String()},
        databaseId: '67c029ce002c2d1ce046',
      );

      await Appwrite_service.databases.updateDocument(
        collectionId: '67c1c87c00009d84c6ff',
        documentId: widget.courseId,
        data: {
          'ratingSum': newSum.toInt(),
          'averageRating': double.parse(newAvg.toStringAsFixed(1)),
        },
        databaseId: '67c029ce002c2d1ce046',
      );
      setState(() {
        averageRating = newAvg;
        rating = newRating;
      });
    }
  }


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
        onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyCoursesScreen()));}
      ),
      title: const Text('Reviews'),
    ),

    body:  Stack(
      children: [

        Column(
          children: [
            SizedBox(height: 25,),
            const Text(
              'Please, rate the course to help us collect feedback',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: rating,
              minRating: 1,
              allowHalfRating: false,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (value) => handleRating(value),
            ),
            SizedBox(height: 10,),
            Center(
              child: Text('${averageRating.toStringAsFixed(1)}',style: TextStyle(color: Color(0xff202244),fontFamily: 'Jost',fontWeight: FontWeight.w600,fontSize: 38),),
            ),
            Center(
              child: RatingBar.builder(
                minRating: 1,
                  itemBuilder: (context,_)=>Icon(Icons.star,color: Colors.amber,),
                onRatingUpdate: (double value) {  },
                itemSize: 25,
                ignoreGestures: true,
                initialRating: averageRating,
                allowHalfRating: true,
              )
            ),
            Center(
              child: Text('Based on $totalRatings Reviews',style: TextStyle(fontFamily: 'Mulish',color: Color(0xff545454),fontSize: 13,fontWeight: FontWeight.w700),),
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
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>WriteReviewScreen(courseId: widget.courseId,)));

          },),
        )
    ]
    ),
  );
  }
}