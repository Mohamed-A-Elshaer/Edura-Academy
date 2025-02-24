import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/HomeScreen.dart';
import 'package:mashrooa_takharog/screens/StudentNavigatorScreen.dart';
import 'package:mashrooa_takharog/screens/search_courses_page.dart';

class PopularCoursesPage extends StatefulWidget {
  const PopularCoursesPage({super.key});

  @override
  State<PopularCoursesPage> createState() => _PopularCoursesPageState();
}

class _PopularCoursesPageState extends State<PopularCoursesPage> {
  String _selectedFilter = 'All';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _allCourses = [
    {
      'imagePath': 'assets/images/course1.png',
      'category': 'Graphic Design',
      'title': 'Graphic Design Advanced',
      'price': 'EGP896',
      'rating': 4.2,
      'students': '7830 Std',
    },
    {
      'imagePath': 'assets/images/course2.png',
      'category': 'Graphic Design',
      'title': 'Advance Diploma in Graphic Design',
      'price': 'EGP800',
      'rating': 4.3,
      'students': '12680 Std',
    },
    {
      'imagePath': 'assets/images/course3.png',
      'category': 'Web Development',
      'title': 'Web Developement Full Diploma',
      'price': 'EGP799',
      'rating': 4.2,
      'students': '990 Std',
    },
    {
      'imagePath': 'assets/images/mediahandler.png',
      'category': 'Arts & Humanities',
      'title': 'Introdution to Arts',
      'price': 'EGP1000',
      'rating': 3.2,
      'students': '2000 Std',
    },
    {
      'imagePath': 'assets/images/mediahandler.png',
      'category': 'Personal Development',
      'title': 'How to Discover More About Yourself',
      'price': 'EGP800',
      'rating': 3.9,
      'students': '12680 Std',
    },
    {
      'imagePath': 'assets/images/mediahandler.png',
      'category': 'SEO & Marketing',
      'title': 'Introduction to Stocks',
      'price': 'EGP1500',
      'rating': 4.6,
      'students': '990 Std',
    },
    {
      'imagePath': 'assets/images/mediahandler.png',
      'category': 'Office Productivity',
      'title': 'How to Manage Your Time Effectively',
      'price': 'EGP690',
      'rating': 4.0,
      'students': '12000 Std',
    },
    {
      'imagePath': 'assets/images/advertisment.jpg',
      'category': 'SEO & Marketing',
      'title': 'Introduction to Social Marketing',
      'price': 'EGP800',
      'rating': 3.8,
      'students': '12680 Std',
    },
    {
      'imagePath': 'assets/images/mediahandler.png',
      'category': 'Cooking',
      'title': 'Healthy Cooking for a Healthy Family.',
      'price': 'EGP799',
      'rating': 4.4,
      'students': '9990 Std',
    },
  ];

  List<Map<String, dynamic>> get filteredCourses {
    List<Map<String, dynamic>> courses = _selectedFilter == 'All'
        ? _allCourses
        : _allCourses
            .where((course) => course['category'] == _selectedFilter)
            .toList();

    if (_searchQuery.isNotEmpty) {
      courses = courses
          .where((course) =>
              course['title']
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              course['category']
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return courses;
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
                'Web Development',
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
            child: filteredCourses.isEmpty
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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildCourseCard(
                          image: course['imagePath'],
                          category: course['category'],
                          title: course['title'],
                          price: course['price'],
                          rating: course['rating'],
                          students: course['students'],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      /*   bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'MY COURSES'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border_outlined), label: 'Bookmarks'),
          BottomNavigationBarItem(
              icon: Icon(Icons.payment), label: 'TRANSACTION'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE',),
        ],
      ),*/
    );
  }

  Widget _buildCourseCard({
    required String image,
    required String category,
    required String title,
    required String price,
    required double rating,
    required String students,
  }) {
    final courseId = title;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow[700], size: 16),
                      Text(' $rating  |  $students'),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                SearchCoursesPageState.savedCourses
                        .any((c) => c['title'] == courseId)
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                color: SearchCoursesPageState.savedCourses
                        .any((c) => c['title'] == courseId)
                    ? Colors.teal
                    : null,
              ),
              onPressed: () => _toggleSavedCourse(courseId),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSavedCourse(String courseId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef =
        FirebaseFirestore.instance.collection('students').doc(user.uid);
    final course =
        HomepageState.coursecardList.firstWhere((c) => c['title'] == courseId);

    setState(() {
      if (SearchCoursesPageState.savedCourses
          .any((c) => c['title'] == courseId)) {
        SearchCoursesPageState.savedCourses
            .removeWhere((c) => c['title'] == courseId);
        userRef.update({
          'savedCourses': SearchCoursesPageState.savedCourses
              .map((c) => c['title'])
              .toList(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Course has been removed from bookmarks successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        SearchCoursesPageState.savedCourses.add(course);
        userRef.set({
          'savedCourses': SearchCoursesPageState.savedCourses
              .map((c) => c['title'])
              .toList(),
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
}
