import 'package:appwrite/appwrite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/ReviewsScreen.dart';
import 'package:mashrooa_takharog/widgets/CourseOnAction.dart';
import 'package:mashrooa_takharog/widgets/customElevatedBtn.dart';

import '../auth/Appwrite_service.dart';

class WriteReviewScreen extends StatefulWidget{
  final String courseId;
  final String courseTitle;
  final String courseCategory;
  final String courseImagePath;

  WriteReviewScreen({required this.courseId, required this.courseTitle, required this.courseCategory, required this.courseImagePath});
  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {

  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;
  int _maxChars = 30000;

  Future<void> _submitReview() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please write a comment')),
      );
      return;
    }

    try {
      final currentUser = await Appwrite_service.account.get();

      // 1. Check for existing rating document
      final existingRatings = await Appwrite_service.databases.listDocuments(
        collectionId: '6808c1e500186c675d9b',
        queries: [
          Query.equal('courseId', widget.courseId),
          Query.equal('userId', currentUser.$id),
        ],
        databaseId: '67c029ce002c2d1ce046',
      );

      if (existingRatings.documents.isEmpty) {
        // Case 1: No existing document - create new one with comment only
        await Appwrite_service.databases.createDocument(
          collectionId: '6808c1e500186c675d9b',
          documentId: ID.unique(),
          data: {
            'courseId': widget.courseId,
            'userId': currentUser.$id,
            'rating': 0, // Default rating (not rated yet)
            'comments': [_controller.text], // Initialize with first comment
            'timestamp': DateTime.now().toUtc().toIso8601String(),
            'hasRated': false,
          },
          databaseId: '67c029ce002c2d1ce046',
        );
      } else {
        // Case 2: Existing document found - add new comment
        final existingDoc = existingRatings.documents.first;
        List<dynamic> existingComments = existingDoc.data['comments'] ?? [];

        await Appwrite_service.databases.updateDocument(
          collectionId: '6808c1e500186c675d9b',
          documentId: existingDoc.$id,
          data: {
            'comments': [...existingComments, _controller.text],
            'timestamp': DateTime.now().toUtc().toIso8601String(),
          },
          databaseId: '67c029ce002c2d1ce046',
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review submitted!'),backgroundColor: Colors.green,),
      );
      // Navigate back to ReviewsScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewsScreen(
            courseId: widget.courseId,
            userId: currentUser.$id,
            courseTitle: widget.courseTitle,
            courseCategory: widget.courseCategory,
            courseImagePath: widget.courseImagePath,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: $e')),
      );
    }
  }




  Future<String> getAppwriteUserID() async{

    final currentUser = await Appwrite_service.account.get();
    return currentUser.$id;
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       leading: IconButton(
           icon: const Icon(Icons.arrow_back),
           onPressed: () async{
             String userId = await getAppwriteUserID();
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ReviewsScreen(courseId:widget.courseId, userId:userId, courseTitle: widget.courseTitle, courseCategory: widget.courseCategory, courseImagePath: widget.courseImagePath, )));
           }
       ),
       title: const Text('Write a Review'),



     ),

     body: SingleChildScrollView(
       child: Padding(
         padding: const EdgeInsets.all(20.0),
         child: Column(
       
       
           children: [
       CourseOnAction(title: widget.courseTitle, category: widget.courseCategory, imagePath: widget.courseImagePath,),
         SizedBox(height: 40,),
         Align(
             alignment: Alignment.centerLeft,
             child: Text('Write your Review',style: TextStyle(color: Color(0xff202244),fontFamily: 'Jost',fontSize: 18,fontWeight: FontWeight.w600),)),
       
             SizedBox(height: 30,),
             Container(
           height: 160,
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
       
               child: Padding(
                 padding: const EdgeInsets.all(10.0),
                 child: Stack(
                   children: [
                     TextField(
                       controller: _controller,
                       maxLines: null,
                       maxLength: _maxChars, // Prevents exceeding character limit
                       onChanged: (text) {
                         setState(() {
                           _isTyping = text.isNotEmpty;
                         });
                       },
                       decoration: InputDecoration(
                         hintText: _isTyping ? '' : 'Write your comment here...',
                         border: InputBorder.none,
                         counterText: '', // Hides default Flutter counter
                       ),
                     ),
                   ],
                 ),
               ),
         ),
             SizedBox(height: 50,),
             CustomElevatedBtn(btnDesc: 'Submit Review',onPressed: _submitReview,)
           ],
         ),
       ),
     ),

   );
  }
}