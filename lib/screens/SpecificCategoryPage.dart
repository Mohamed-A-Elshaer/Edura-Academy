import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:appwrite/models.dart' as models;
import 'package:mashrooa_takharog/auth/Appwrite_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mashrooa_takharog/screens/HomeScreen.dart';

import '../auth/supaAuth_service.dart';
import '../widgets/coursecard.dart';
import 'StudentNavigatorScreen.dart'; // for HomepageState

class SpecificCategoryPage extends StatefulWidget {
  final String category;

  const SpecificCategoryPage({Key? key, required this.category}) : super(key: key);

  @override
  State<SpecificCategoryPage> createState() => _SpecificCategoryPageState();
}

class _SpecificCategoryPageState extends State<SpecificCategoryPage> {

  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;

  List<String> savedCourseTitles = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarksAndCourses(); // 🔥 CHANGED
  }

  Future<void> _loadBookmarksAndCourses() async {
    await _fetchSavedCourseTitles();
    await _fetchCourses();
  }

  Future<void> _fetchSavedCourseTitles() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance.collection('students').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          savedCourseTitles = List<String>.from(data['savedCourses'] ?? []);
        });
      }
    } catch (e) {
      print('Error fetching saved course titles: $e');
    }
  }

  Future<void> _fetchCourses() async {
    try {
      final models.DocumentList result = await Appwrite_service.databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046', // Replace with your DB ID
        collectionId: '67c1c87c00009d84c6ff',
        queries: [appwrite.Query.equal('category', widget.category)],
      );
      final List<Map<String, dynamic>> loadedCourses = [];

      for (var doc in result.documents) {
        final courseData = doc.data;
        final imageUrl = await SupaAuthService.getCourseCoverImageUrl(courseData['title']);
        courseData['imagePath'] = imageUrl;
        courseData['courseId'] = doc.$id;
        loadedCourses.add(courseData);
      }

      setState(() {
        _courses = loadedCourses;
        HomepageState.coursecardList = _courses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching courses: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleBookmark(String courseTitle) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('students').doc(user.uid);
    final doc = await docRef.get();

    List<String> currentSaved = List<String>.from(doc.data()?['savedCourses'] ?? []);

    bool isBookmarked;

    if (currentSaved.contains(courseTitle)) {
      currentSaved.remove(courseTitle);
      isBookmarked = false;
    } else {
      currentSaved.add(courseTitle);
      isBookmarked = true;
    }

    await docRef.update({'savedCourses': currentSaved});

    setState(() {
      savedCourseTitles = currentSaved;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBookmarked
              ? 'Course has been bookmarked successfully!'
              : 'Course has been removed from bookmarks successfully!',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NavigatorScreen()));}, icon: Icon(Icons.arrow_back_outlined,color: Colors.white,)),
        title: Text(widget.category,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
          ? const Center(child: Text('No courses found for this category.'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _courses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final course = _courses[index];
          return CourseCard(
            category: course['category'] ?? '',
            title: course['title'] ?? '',
            price: course['price']?.toString() ?? 'Free',
            rating: course['rating'],
            students: course['students'], // dummy
            imagePath: course['imagePath'],
            instructorName: course['instructor_name'] ?? 'Unknown',
            isBookmarked: savedCourseTitles.contains(course['title']),
            onBookmarkToggle: () => _toggleBookmark(course['title']),
            courseId: course['courseId'],
          );
        },
      ),
    );
  }
}
