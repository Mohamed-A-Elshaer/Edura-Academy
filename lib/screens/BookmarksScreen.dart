import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/HomeScreen.dart';
import 'package:mashrooa_takharog/screens/search_courses_page.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Map<String, dynamic>> filteredCourses = [];

  @override
  void initState() {
    super.initState();
    HomepageState.selectedCardIndex = 0;
    _loadSavedCourses();
  }

  void _loadSavedCourses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef =
        FirebaseFirestore.instance.collection('students').doc(user.uid);
    final snapshot = await userRef.get();
    if (snapshot.exists) {
      final savedTitles =
          List<String>.from(snapshot.data()?['savedCourses'] ?? []);
      setState(() {
        SearchCoursesPageState.savedCourses.clear();
        for (var title in savedTitles) {
          final course = SearchCoursesPageState.courses
              .firstWhere((c) => c['title'] == title, orElse: () => {});
          if (course.isNotEmpty) {
            SearchCoursesPageState.savedCourses.add(course);
          }
        }
        _filterCoursesByCategory("All");
      });
    }
  }

  void showRemoveBookmarkDialog(
    BuildContext context,
    Map<String, dynamic> course,
    VoidCallback onRemove,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Remove From Bookmarks?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff202244),
                ),
              ),
              const SizedBox(height: 16),
              Row(
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
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['category'] ?? "Unknown Category",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        course['title'] != null && course['title'].length > 29
                            ? "${course['title'].substring(0, 25)}..."
                            : course['title'] ?? "Unknown Title",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff202244),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${course['price']} | ★ ${course['rating']} | ${course['students']}",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Color(0xff202244)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onRemove();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff167F71),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Yes, Remove",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeCourseFromBookmarks(String courseTitle) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final studentRef =
        FirebaseFirestore.instance.collection('students').doc(user.uid);
    final snapshot = await studentRef.get();

    if (snapshot.exists) {
      final List<String> savedCourses =
          List<String>.from(snapshot.data()?['savedCourses'] ?? []);

      if (savedCourses.contains(courseTitle)) {
        savedCourses.remove(courseTitle);

        await studentRef.update({'savedCourses': savedCourses});

        setState(() {
          SearchCoursesPageState.savedCourses
              .removeWhere((course) => course['title'] == courseTitle);
          filteredCourses
              .removeWhere((course) => course['title'] == courseTitle);
        });
      }
    }
  }

  void _filterCoursesByCategory(String category) {
    setState(() {
      if (category == "All") {
        filteredCourses = List.from(SearchCoursesPageState.savedCourses);
      } else {
        filteredCourses = SearchCoursesPageState.savedCourses
            .where((course) => course['category'] == category)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bookmarks',
          style: TextStyle(
              color: Color(0xff202244),
              fontFamily: 'Jost',
              fontSize: 21,
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 23,
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: HomepageState.categories.length,
              itemBuilder: (context, index) {
                final data = HomepageState.categories[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      HomepageState.selectedCardIndex = index;
                    });
                    _filterCoursesByCategory(data['title']);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: HomepageState.selectedCardIndex == index
                          ? const Color(0xff167F71)
                          : Colors.grey[200],
                    ),
                    child: Center(
                      child: Text(
                        data['title'] ?? '',
                        style: TextStyle(
                          color: HomepageState.selectedCardIndex == index
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
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: filteredCourses.isEmpty
                ? const Center(child: Text("No bookmarks yet!"))
                : ListView.builder(
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
                      return SearchCourseCard(
                        course: course,
                        savedCourses: SearchCoursesPageState.savedCourses,
                        toggleSavedCourse: (courseId) {
                          showRemoveBookmarkDialog(
                            context,
                            course,
                            () => _removeCourseFromBookmarks(courseId),
                          );
                        },
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
