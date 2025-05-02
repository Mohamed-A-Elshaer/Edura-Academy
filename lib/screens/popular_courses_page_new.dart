import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/StudentNavigatorScreen.dart';
import 'package:mashrooa_takharog/screens/search_courses_page.dart';
import 'package:appwrite/appwrite.dart' as appwrite;
import '../auth/Appwrite_service.dart';
import '../auth/supaAuth_service.dart';

class PopularCoursesPage extends StatefulWidget {
  const PopularCoursesPage({super.key});

  @override
  State<PopularCoursesPage> createState() => _PopularCoursesPageState();
}

class _PopularCoursesPageState extends State<PopularCoursesPage> {
  String _selectedFilter = 'All';
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool isLoading = true;
  List<String> savedCourseTitles = [];

  static List<Map<String, dynamic>> courses = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarksAndCourses();
  }

  Future<void> _loadBookmarksAndCourses() async {
    await _fetchSavedCourseTitles();
    await _fetchCourses();
    await updateCourseStudentCounts();
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
        setState(() {
          savedCourseTitles =
              List<String>.from(doc.data()!['savedCourses'] ?? []);
        });
      }
    } catch (e) {
      print('Error fetching saved course titles: $e');
    }
  }

  Future<void> _fetchCourses() async {
    try {
      final response = await Appwrite_service.databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
      );

      List<Map<String, dynamic>> fetchedCourses = [];
      
      for (var doc in response.documents.where((doc) => doc.data['upload_status'] == 'approved')) {
        final courseTitle = doc.data['title'] ?? '';
        final imageUrl = await SupaAuthService.getCourseCoverImageUrl(courseTitle);
        
        fetchedCourses.add({
          'title': courseTitle,
          'instructor': doc.data['instructor_name'] ?? '',
          'category': doc.data['category'] ?? '',
          'price': (doc.data['price'] ?? 0).toString(),
          'courseId': doc.$id,
          'imagePath': imageUrl,
          'instructorName': doc.data['name'] ?? '',
          'rating': doc.data['averageRating'] ?? 0.0,
          'students': '1000 Std',
          'duration': doc.data['courseDuration_inMins'] ?? 0
        });
      }

      setState(() {
        courses = fetchedCourses;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching courses: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateCourseStudentCounts() async {
    for (int i = 0; i < courses.length; i++) {
      final courseTitle = courses[i]['title'];

      try {
        final studentCount = await getTotalStudents(courseTitle);
        setState(() {
          courses[i]['students'] = '$studentCount Std';
        });
      } catch (e) {
        print('Error getting students for $courseTitle: $e');
      }
    }
  }

  Future<int> getTotalStudents(String courseTitle) async {
    final response = await Appwrite_service.databases.listDocuments(
      databaseId: '67c029ce002c2d1ce046',
      collectionId: '67c0cc3600114e71d658',
      queries: [
        appwrite.Query.contains('purchased_courses', courseTitle),
      ],
    );

    return response.total;
  }

  List<Map<String, dynamic>> get filteredCourses {
    List<Map<String, dynamic>> result = List.from(courses);

    // Apply category filter
    if (_selectedFilter != 'All') {
      result = result.where((course) => course['category'] == _selectedFilter).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      result = result.where((course) {
        return course['title']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            course['category']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Sort by rating in descending order
    result.sort((a, b) {
      double ratingA = double.tryParse(a['rating'].toString()) ?? 0.0;
      double ratingB = double.tryParse(b['rating'].toString()) ?? 0.0;
      return ratingB.compareTo(ratingA);
    });

    return result;
  }

  Future<void> _toggleBookmark(String courseTitle) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef =
        FirebaseFirestore.instance.collection('students').doc(user.uid);
    final doc = await docRef.get();

    List<String> currentSaved =
        List<String>.from(doc.data()?['savedCourses'] ?? []);
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
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NavigatorScreen()));
                },
              ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search Courses...',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              )
            : const Text('Popular Courses'),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                'All',
                'Graphic Design',
                'Arts & Humanities',
                'Cooking',
                'SEO & Marketing',
                'Programming',
                'Finance and Accounting',
                'Personal Development',
                'Office Productivity',
              ]
                  .map((filter) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          backgroundColor:
                              _selectedFilter == filter ? Colors.teal : null,
                          labelStyle: TextStyle(
                            color:
                                _selectedFilter == filter ? Colors.white : null,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredCourses.isEmpty
                    ? const Center(
                        child: Text(
                          "No courses available!",
                          style:
                              TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredCourses.length,
                        itemBuilder: (context, index) {
                          final course = filteredCourses[index];
                          return SearchCourseCard(
                            course: course,
                            savedCourseTitles: savedCourseTitles,
                            onBookmarkToggle: _toggleBookmark,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 