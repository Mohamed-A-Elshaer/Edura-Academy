import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/FilterScreen.dart';
import 'package:mashrooa_takharog/screens/StudentNavigatorScreen.dart';

class SearchCoursesPage extends StatefulWidget {
  const SearchCoursesPage({super.key});

  @override
  State<SearchCoursesPage> createState() => SearchCoursesPageState();
}

class SearchCoursesPageState extends State<SearchCoursesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showMentors = false;
  static  List<Map<String, dynamic>> savedCourses = [];
  static final List<Map<String, dynamic>> courses = [
    {
      'image': 'assets/images/course1.png',
      'category': 'Graphic Design',
      'title': 'Graphic Design Advanced',
      'price': 'EGP896',
      'rating': 4.2,
      'students': '7830 Std',
      'isSaved': false,
    },
    {
      'image': 'assets/images/course2.png',
      'category': 'Graphic Design',
      'title': 'Advance Diploma in Graphic Design',
      'price': 'EGP800',
      'rating': 4.3,
      'students': '12680 Std',
      'isSaved': false,
    },
    {
      'image': 'assets/images/course3.png',
      'category': 'Programming',
      'title': 'Web Developement Full Diploma',
      'price': 'EGP799',
      'rating': 4.2,
      'students': '990 Std',
      'isSaved': false,
    },
    {
      'image': 'assets/images/mediahandler.png',
      'category': 'Arts & Humanities',
      'title': 'Introdution to Arts',
      'price': 'EGP1000',
      'rating': 3.2,
      'students': '2000 Std',
      'isSaved': false,
    },
    {
      'image': 'assets/images/mediahandler.png',
      'category': 'Personal Development',
      'title': 'How to Discover More About Yourself',
      'price': 'EGP800',
      'rating': 3.9,
      'students': '12680 Std',
      'isSaved': false,
    },
    {
      'image': 'assets/images/mediahandler.png',
      'category': 'SEO & Marketing',
      'title': 'Introduction to Stocks',
      'price': 'EGP1500',
      'rating': 4.6,
      'students': '990 Std',
      'isSaved': false,
    },
    {
      'image': 'assets/images/mediahandler.png',
      'category': 'Office Productivity',
      'title': 'How to Manage Your Time Effectively',
      'price': 'EGP690',
      'rating': 4.0,
      'students': '12000 Std',
      'isSaved': false,
    },
    {
      'image': 'assets/images/advertisment.jpg',
      'category': 'SEO & Marketing',
      'title': 'Introduction to Social Marketing',
      'price': 'EGP800',
      'rating': 3.8,
      'students': '12680 Std',
      'isSaved': false,
    },
    {
      'image': 'assets/images/mediahandler.png',
      'category': 'Cooking',
      'title': 'Healthy Cooking for a Healthy Family.',
      'price': 'EGP799',
      'rating': 4.4,
      'students': '9990 Std',
      'isSaved': false,
    },
  ];

  final List<Map<String, String>> _mentors = [
    {'name': 'Ahmed Abdullah', 'specialty': 'Graphic Design'},
    {'name': 'Osama Ahmed', 'specialty': 'Arts & Humanities'},
    {'name': 'Amany Elsayed', 'specialty': 'Personal Development'},
    {'name': 'Mohamed Ahmed', 'specialty': 'SEO & Marketing'},
    {'name': 'Ahmed Khaled', 'specialty': 'Programming'},
    {'name': 'Robert William', 'specialty': 'Office Productivity'},
  ];

  List<Map<String, dynamic>> get filteredCourses {
    return courses.where((course) {
      final matchesSearch = course['title']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()) ||
          course['category']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }


  List<Map<String, String>> get filteredMentors {
    return _mentors.where((mentor) {
      return mentor['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          mentor['specialty']!
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NavigatorScreen()),
          ),
        ),
        title: const Text('Online Courses'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FilterScreen()));
                          },
                          child: const Icon(Icons.filter_list,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Toggle Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showMentors = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_showMentors
                          ? Colors.teal
                          : Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Courses',
                        style: TextStyle(
                            color: !_showMentors ? Colors.white : Colors.black)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showMentors = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showMentors
                          ? Colors.teal
                          : Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Mentors',
                        style: TextStyle(
                            color: _showMentors ? Colors.white : Colors.black)),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _showMentors
                ? ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredMentors.length,
              itemBuilder: (context, index) {
                final mentor = filteredMentors[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.person_outline,
                        color: Colors.grey),
                  ),
                  title: Text(
                    mentor['name']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    mentor['specialty']!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                );
              },
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
                final course = filteredCourses[index];
                return SearchCourseCard(course: course,savedCourses: savedCourses,toggleSavedCourse: _toggleSavedCourse,);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSavedCourse(String courseId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('students').doc(user.uid);
    final course = courses.firstWhere((c) => c['title'] == courseId);

    setState(() {
      if (savedCourses.any((c) => c['title'] == courseId)) {
        savedCourses.removeWhere((c) => c['title'] == courseId);
        userRef.update({
          'savedCourses': savedCourses.map((c) => c['title']).toList(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course has been removed from bookmarks successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

      } else {
        savedCourses.add(course);
        userRef.set({
          'savedCourses': savedCourses.map((c) => c['title']).toList(),
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

class SearchCourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final List<Map<String, dynamic>> savedCourses;
  final Function(String) toggleSavedCourse;
  const SearchCourseCard({super.key, required this.course,required this.savedCourses, required this.toggleSavedCourse,});

  @override
  Widget build(BuildContext context) {
    final courseId = course['title'];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                course['image'],
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
                    course['category'],
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course['price'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow[700], size: 16),
                      Text(' ${course['rating']}  |  ${course['students']}'),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                savedCourses.any((c) => c['title'] == course['title'])? Icons.bookmark : Icons.bookmark_border,
                color: savedCourses.any((c) => c['title'] == course['title'])  ? Colors.teal : null,
              ),
              onPressed: ()=>toggleSavedCourse(courseId),
            ),
          ],
        ),
      ),
    );
  }



}
