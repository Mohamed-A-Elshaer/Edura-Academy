import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/CourseDetailScreen.dart';
import 'package:mashrooa_takharog/auth/Appwrite_service.dart';
import 'package:appwrite/appwrite.dart' as appwrite;
import '../widgets/coursecard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/supaAuth_service.dart';

class Mentorprofile extends StatefulWidget {
  final String mentorId;
  final String name;
  final String imagePath;
  final int courseCount;
  final int studentCount;
  final String major;
  final String title;

  const Mentorprofile({
    Key? key,
    required this.mentorId,
    required this.name,
    required this.imagePath,
    required this.courseCount,
    required this.studentCount,
    required this.major,
    required this.title,
  }) : super(key: key);

  @override
  State<Mentorprofile> createState() => _Mentorprofile();
}

class _Mentorprofile extends State<Mentorprofile> {
  List<Map<String, dynamic>> mentorCourses = [];
  bool isLoading = true;
  List<String> savedCourseTitles = [];

  @override
  void initState() {
    super.initState();
    _fetchMentorCourses();
    _fetchSavedCourseTitles();
  }

  Future<void> _fetchSavedCourseTitles() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .get();
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

  Future<void> _fetchMentorCourses() async {
    try {
      final response = await Appwrite_service.databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        queries: [
          appwrite.Query.equal('instructor_name', widget.name),
          appwrite.Query.equal('upload_status', 'approved'),
        ],
      );

      List<Map<String, dynamic>> coursesWithImages = [];
      for (final course in response.documents) {
        final courseData = course.data;
        final coverUrl = await SupaAuthService.getCourseCoverImageUrl(courseData['title']);
        
        coursesWithImages.add({
          ...courseData,
          'imagePath': coverUrl.isNotEmpty ? coverUrl : 'assets/images/mediahandler.png',
        });
      }

      setState(() {
        mentorCourses = coursesWithImages;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching mentor courses: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            const SizedBox(height: 20),
            _buildMajorSection(),
            const SizedBox(height: 20),
            const Text(
              'Courses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCoursesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(widget.imagePath),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatColumn(widget.courseCount.toString(), 'Courses'),
            _buildStatColumn(widget.studentCount.toString(), 'Students'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatColumn(String stat, String label) {
    return Column(
      children: [
        Text(
          stat,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMajorSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        widget.major,
        style: const TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCoursesList() {
    if (mentorCourses.isEmpty) {
      return const Center(
        child: Text(
          'No courses available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: mentorCourses.length,
      itemBuilder: (context, index) {
        final course = mentorCourses[index];
        return CourseCard(
          title: course['title'] ?? 'Untitled Course',
          courseId: course['\$id'],
          price: course['price']?.toString() ?? '0',
          imagePath: course['imagePath'],
          category: course['category'] ?? 'Uncategorized',
          rating: course['averageRating']?.toDouble() ?? 0.0,
          instructorName: course['instructor_name'] ?? 'Unknown',
          isBookmarked: savedCourseTitles.contains(course['title']),
          onBookmarkToggle: () => _toggleBookmark(course['title']),
        );
      },
    );
  }
}