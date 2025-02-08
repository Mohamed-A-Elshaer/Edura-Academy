import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/search_courses_page.dart';

import '../screens/HomeScreen.dart';

class CourseCard extends StatefulWidget {
  final String category;
  final String title;
  final String price;
  final double rating;
  final String students;
  final String imagePath;

  const CourseCard({
    required this.category,
    required this.title,
    required this.price,
    required this.rating,
    required this.students,
    required this.imagePath,
    Key? key,
  }) : super(key: key);

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  void _toggleSavedCourse(String courseId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('students').doc(user.uid);
    final course = HomepageState.coursecardList.firstWhere((c) => c['title'] == courseId);

    setState(() {
      if (SearchCoursesPageState.savedCourses.any((c) => c['title'] == courseId)) {
        SearchCoursesPageState.savedCourses.removeWhere((c) => c['title'] == courseId);
        userRef.update({
          'savedCourses': SearchCoursesPageState.savedCourses.map((c) => c['title']).toList(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course has been removed from bookmarks successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

      } else {
        SearchCoursesPageState.savedCourses.add(course);
        userRef.set({
          'savedCourses': SearchCoursesPageState.savedCourses.map((c) => c['title']).toList(),
        }, SetOptions(merge: true));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course has been added to bookmarks successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
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

          Container(
            height: 112,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.category,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
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
            'Price: ${widget.price}',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),


          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '${widget.rating} (${widget.students})',
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
                  SearchCoursesPageState.savedCourses.any((c) => c['title'] == widget.title)? Icons.bookmark : Icons.bookmark_border,
                  color: SearchCoursesPageState.savedCourses.any((c) => c['title'] == widget.title)  ? Colors.teal : null,
                ),
                onPressed: ()=>_toggleSavedCourse(courseId),
              ),
              ),
          ),
        ],
      ),
    );
  }
}
