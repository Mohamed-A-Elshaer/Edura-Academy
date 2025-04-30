import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/search_courses_page.dart';
import '../auth/Appwrite_service.dart';
import '../screens/CourseDetailScreen.dart';
import '../screens/HomeScreen.dart';
import 'package:appwrite/appwrite.dart' as appwrite;

class CourseCard extends StatefulWidget {
  final String category;
  final String title;
  final String price;
   double? rating;
   int? students;
  final String instructorName;
  String imagePath;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;
  final courseId;

   CourseCard({
    required this.category,
    required this.title,
    required this.price,
     this.rating,
     this.students,
    required this.imagePath,
     required this.instructorName,
     required this.isBookmarked,
     required this.onBookmarkToggle,
      this.courseId,
    Key? key,
  }) : super(key: key);

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  @override
  void initState() {
    super.initState();
    getAverageRating();
    getTotalStudents();
  }



  Future<void> getAverageRating() async {
    try {
      final course = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff', // courses collection
        documentId: widget.courseId,
      );
      final ratingData = course.data['averageRating'];

      setState(() {
        widget.rating = (ratingData is int) ? ratingData.toDouble() : (ratingData ?? 0.0);
      });
    } catch (e) {
      print('Error fetching average rating: $e');
    }
  }


  Future<void> getTotalStudents() async {
    try {
      final result = await Appwrite_service.databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658', // users collection
          queries: [appwrite.Query.contains('purchased_courses', widget.title)]
      );
      setState(() {
        widget.students = result.total;
      });
    } catch (e) {
      print('Error fetching total students: $e');
    }
  }

  void _toggleSavedCourse(String courseTitle) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('students').doc(user.uid);
    final isAlreadySaved = SearchCoursesPageState.savedCourses.any((c) => c['title'] == courseTitle);

    if (isAlreadySaved) {
      await userRef.update({
        'savedCourses': FieldValue.arrayRemove([courseTitle]),
      });

      setState(() {
        SearchCoursesPageState.savedCourses.removeWhere((c) => c['title'] == courseTitle);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course has been removed from bookmarks successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Add only minimal info needed to savedCourses, or rebuild it later from title
      setState(() {
        SearchCoursesPageState.savedCourses.add({
          'title': courseTitle,
          'category': widget.category,
          'price': widget.price,
          'rating': widget.rating,
          'students': widget.students,
          'imagePath': widget.imagePath,
          'instructorName': widget.instructorName,
        });
      });

      await userRef.set({
        'savedCourses': FieldValue.arrayUnion([courseTitle]),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course has been added to bookmarks successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final courseId = widget.title;
    return Container(
    //  width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.imagePath,
              height: 112,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
            )

          ),


    const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                widget.category,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
              IconButton(onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Coursedetailscreen(category: widget.category, imagePath:widget.imagePath,title: widget.title,courseId:widget.courseId , price: widget.price,instructorName: widget.instructorName,)));}, icon: Icon(Icons.navigate_next),color: Colors.teal,),
            ],
          ),
          //const SizedBox(height: 8),
          Text(
            'by: ${widget.instructorName}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),


          Text(
            'Price: EGP${widget.price}',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),


          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '${(widget.rating ?? 0.0).toStringAsFixed(1)} '
                    '(${int.tryParse(widget.students.toString() ?? '') ?? 0})',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),

            ],
          ),



          Transform(
            transform: Matrix4.translationValues(0, -10, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child:
              IconButton(
                icon: Icon(
                  widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: widget.isBookmarked ? Colors.teal : null,
                ),
                onPressed: widget.onBookmarkToggle,
              ),



            ),
          ),
        ],
      ),
    );

  }
}
