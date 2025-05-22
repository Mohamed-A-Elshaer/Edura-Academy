import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mashrooa_takharog/auth/Appwrite_service.dart';
import 'package:mashrooa_takharog/screens/MyCoursesScreen.dart';
import 'package:mashrooa_takharog/screens/StudentNavigatorScreen.dart';
import 'package:mashrooa_takharog/screens/WriteReviewScreen.dart';
import 'package:mashrooa_takharog/screens/search_courses_page.dart';
import 'package:mashrooa_takharog/widgets/CourseComment.dart';

import '../auth/supaAuth_service.dart';
import '../widgets/customElevatedBtn.dart';


class ReviewsScreen extends StatefulWidget{

  final String courseId;
  final String userId;
  final String courseTitle;
  final String courseCategory;
  final String courseImagePath;

  ReviewsScreen({required this.courseId, required this.userId, required this.courseTitle, required this.courseCategory,  required this.courseImagePath});
  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  double rating = 0;
  double averageRating = 0;
  int totalRatings = 0;
  bool hasRated = false;
  List<Map<String, dynamic>> _allComments = [];
  String? currentAppwriteUserId;

  Realtime? realtime;
  RealtimeSubscription? authSubscription;
  @override
  void initState() {
    super.initState();
    _initUserAndFetch();
    fetchRatingData();
    _fetchAllComments();
    _subscribeToAuthChanges();
  }

  @override
  void dispose() {
    authSubscription?.close(); // Clean up subscription
    super.dispose();
  }


  void _subscribeToAuthChanges() {
    // Check every 2 seconds for auth changes
    Timer.periodic(Duration(seconds: 2), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final newUserId = await Appwrite_service.getCurrentAppwriteUserId();
      if (newUserId != currentAppwriteUserId) {
        setState(() {
          currentAppwriteUserId = newUserId;
        });
        _fetchAllComments();
      }
    });
  }

  Future<void> _initUserAndFetch() async {
    currentAppwriteUserId = await Appwrite_service.getCurrentAppwriteUserId();
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
        hasRated = ratingDocs.documents.first.data['hasRated'] ?? false;
        rating = ratingDocs.documents.first.data['rating']?.toDouble() ?? 0;
      });
    }
  }

  Future<void> _fetchAllComments() async {
    try {
      // 1. Fetch all rating documents for this course
      final ratings = await Appwrite_service.databases.listDocuments(
        collectionId: '6808c1e500186c675d9b',
        queries: [
          Query.equal('courseId', widget.courseId),
          Query.orderDesc('timestamp'),
        ],
        databaseId: '67c029ce002c2d1ce046',
      );

      List<Map<String, dynamic>> commentsWithUserData = [];

      for (var ratingDoc in ratings.documents) {
        // 2. Fetch user data for each comment
        final userDoc = await Appwrite_service.databases.getDocument(
          databaseId: '67c029ce002c2d1ce046',
          collectionId: '67c0cc3600114e71d658',
          documentId: ratingDoc.data['userId'],
        );
        final String? supabaseUserId = await SupaAuthService.getSupabaseUserId(userDoc.data['email']);

        // 3. Get all comments for this user
        List<String> comments = List<String>.from(ratingDoc.data['comments'] ?? []);

        for (var comment in comments) {
          commentsWithUserData.add({
            'userId': ratingDoc.data['userId'],
            'supabaseUserId': supabaseUserId,
            'userName': userDoc.data['name'],
            'comment': comment,
            'rating': ratingDoc.data['rating']?.toDouble() ?? 0.0,
            'timestamp': ratingDoc.data['timestamp'],
          });
        }
      }

      setState(() {
        _allComments = commentsWithUserData;
      });
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  Future<void> handleRating(double newRating) async {
    try {
      // Step 1: Fetch course document
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

      // Step 3: Update rated courses list for user
      List<dynamic> ratedCourses = userDoc.data['ratedCourseIds'] ?? [];
      if (!ratedCourses.contains(courseName)) {
        ratedCourses.add(courseName);
        await Appwrite_service.databases.updateDocument(
          collectionId: '67c0cc3600114e71d658',
          documentId: widget.userId,
          databaseId: '67c029ce002c2d1ce046',
          data: {'ratedCourseIds': ratedCourses},
        );
      }

      // Step 4: Check for existing rating document
      final ratingDocs = await Appwrite_service.databases.listDocuments(
        collectionId: '6808c1e500186c675d9b',
        queries: [
          Query.equal('courseId', widget.courseId),
          Query.equal('userId', widget.userId),
        ],
        databaseId: '67c029ce002c2d1ce046',
      );

      if (ratingDocs.documents.isEmpty) {
        // Case 1: No existing document - create new one
        await Appwrite_service.databases.createDocument(
          collectionId: '6808c1e500186c675d9b',
          documentId: ID.unique(),
          data: {
            'courseId': widget.courseId,
            'userId': widget.userId,
            'rating': newRating.toInt(),
            'comments': [], // Initialize empty comments array
            'timestamp': DateTime.now().toUtc().toIso8601String(),
            'hasRated': true,
          },
          databaseId: '67c029ce002c2d1ce046',
        );
      } else {
        // Case 2: Existing document found - update rating
        final ratingDoc = ratingDocs.documents.first;
        final oldRating = ratingDoc.data['rating']?.toDouble() ?? 0;

        await Appwrite_service.databases.updateDocument(
          collectionId: '6808c1e500186c675d9b',
          documentId: ratingDoc.$id,
          data: {
            'rating': newRating.toInt(),
            'timestamp': DateTime.now().toUtc().toIso8601String(),
            'hasRated': true,
          },
          databaseId: '67c029ce002c2d1ce046',
        );
      }

      // Step 5: Update course rating statistics
      final ratingSum = courseDoc.data['ratingSum']?.toDouble() ?? 0;
      final currentTotalRatings = courseDoc.data['totalRatings'] ?? 0;

      double newSum;
      int newTotal;

      if (!hasRated) {
        // First rating from this user
        newSum = ratingSum + newRating;
        newTotal = currentTotalRatings + 1;

        // Update rated users list
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
            'ratedUserIds': ratedUserIds,
            'averageRating': double.parse((newSum / newTotal).toStringAsFixed(1)),
          },
          databaseId: '67c029ce002c2d1ce046',
        );
      } else {
        // Updating existing rating
        final oldRating = rating;
        newSum = ratingSum - oldRating + newRating;
        newTotal = currentTotalRatings;

        await Appwrite_service.databases.updateDocument(
          collectionId: '67c1c87c00009d84c6ff',
          documentId: widget.courseId,
          data: {
            'ratingSum': newSum.toInt(),
            'averageRating': double.parse((newSum / newTotal).toStringAsFixed(1)),
          },
          databaseId: '67c029ce002c2d1ce046',
        );
      }

      setState(() {
        averageRating = double.parse((newSum / newTotal).toStringAsFixed(1));
        totalRatings = newTotal;
        rating = newRating;
        hasRated = true;
      });

    } catch (e) {
      print('Error handling rating: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update rating: $e')),
      );
    }
  }


  static  final List<Map<String, dynamic>> ratingCategories = [
    {"title": "All"},
    {"title": "Excellent"},
    {"title": "Good"},
    {"title": "Average"},
    {"title": "Below Average"},
  ];
  static int selectedCardIndex = 0;

  List<Map<String, dynamic>> _getFilteredComments() {
    if (selectedCardIndex == -1 || selectedCardIndex == 0) {
      return _allComments; // Show all comments
    }

    double minRating = 0;
    double maxRating = 5;

    switch (selectedCardIndex) {
      case 1: // Excellent (5 stars)
        minRating = 5;
        break;
      case 2: // Good (4 stars)
        minRating = 4;
        maxRating = 4.9;
        break;
      case 3: // Average (3 stars)
        minRating = 3;
        maxRating = 3.9;
        break;
      case 4: // Below Average (<3 stars)
        maxRating = 2.9;
        break;
    }

    return _allComments.where((comment) {
      final rating = comment['rating'];
      return rating >= minRating && rating <= maxRating;
    }).toList();
  }

  Future<void> _deleteComment(String userId, String comment, String timestamp) async {
    try {
      // Show confirmation dialog
      bool confirmDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete'),
          content: const Text('Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirmDelete != true) return;

      // Get the rating document for this user
      final ratingDocs = await Appwrite_service.databases.listDocuments(
        collectionId: '6808c1e500186c675d9b',
        queries: [
          Query.equal('courseId', widget.courseId),
          Query.equal('userId', userId),
        ],
        databaseId: '67c029ce002c2d1ce046',
      );

      if (ratingDocs.documents.isNotEmpty) {
        final ratingDoc = ratingDocs.documents.first;
        List<String> comments = List<String>.from(ratingDoc.data['comments'] ?? []);

        // Remove the comment
        comments.removeWhere((c) => c == comment);

        // Update the document
        await Appwrite_service.databases.updateDocument(
          collectionId: '6808c1e500186c675d9b',
          documentId: ratingDoc.$id,
          data: {'comments': comments},
          databaseId: '67c029ce002c2d1ce046',
        );

        // Refresh comments
        _fetchAllComments();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deleted!'),backgroundColor: Colors.green,),
        );
      }
    } catch (e) {
      print('Error deleting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete comment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NavigatorScreen()));}
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
                itemCount: _getFilteredComments().length,
                itemBuilder: (context, index) {
                  final commentData = _getFilteredComments()[index];
                  print('Current user: $currentAppwriteUserId');
                  print('Comment by: ${commentData['userId']}');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: CourseComment(
                      userName: commentData['userName'],
                      rating: commentData['rating'],
                      comment: commentData['comment'],
                      timestamp: commentData['timestamp'],
                      supabaseUserId: commentData['supabaseUserId'],
                      currentUserId: currentAppwriteUserId,
                      userId: commentData['userId'],
                      onDelete: () => _deleteComment(
                        commentData['userId'],
                        commentData['comment'],
                        commentData['timestamp'],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 60,),
          ],
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: CustomElevatedBtn( btnDesc: 'Write a Review',onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>WriteReviewScreen(courseId: widget.courseId,courseTitle: widget.courseTitle,courseCategory: widget.courseCategory,courseImagePath:widget.courseImagePath , )));

          },),
        )
    ]
    ),
  );
  }
}