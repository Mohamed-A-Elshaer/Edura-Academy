import 'package:flutter/material.dart';
import 'course_lessons_screen.dart';
import 'certificate_screen.dart';

class MyCoursesScreen2 extends StatefulWidget {
  const MyCoursesScreen2({super.key});

  @override
  State<MyCoursesScreen2> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen2>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> completedCourses = [
    {
      'title': 'Graphic Design Advanced',
      'image': 'assets/images/course1.png',
      'rating': 4.2,
      'duration': '5 hrs 28 mins',
      'isCompleted': true,
    },
    {
      'title': 'Advance Diploma in Graphic Design',
      'image': 'assets/images/course2.png',
      'rating': 4.7,
      'duration': '3 hrs 28 mins',
      'isCompleted': true,
    },
    {
      'title': 'Setup your Graphic Des...',
      'image': 'assets/images/course3.png',
      'rating': 4.2,
      'duration': '4 hrs 55 mins',
      'isCompleted': true,
    },
    {
      'title': 'Web Developer course',
      'image': 'assets/images/mediahandler.png',
      'rating': 4.5,
      'duration': '6 hrs 48 mins',
      'isCompleted': true,
    },
  ];

  final List<Map<String, dynamic>> ongoingCourses = [
    {
      'title': 'Intro to UI/UX Design',
      'image': 'assets/images/course1.png',
      'rating': 4.4,
      'duration': '2 hrs 45 mins',
      'price': '\$55.25',
      'progress': 0.6,
    },
    {
      'title': 'WordPress Website Dev.',
      'image': 'assets/images/course2.png',
      'rating': 3.5,
      'duration': '1 hrs 30 mins',
      'price': '\$23.25',
      'progress': 0.3,
    },
    {
      'title': '3D Blender and UI/UX',
      'image': 'assets/images/course3.png',
      'rating': 4.8,
      'duration': '2 hrs 45 mins',
      'price': '\$66.99',
      'progress': 0.8,
    },
    {
      'title': 'Learn UX User Persona',
      'image': 'assets/images/course4.png',
      'rating': 3.9,
      'duration': '1 hrs 55 mins',
      'price': '\$45.00',
      'progress': 0.4,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'My Courses',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: "Search for...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xff0961F5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color(0xff167F71),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              tabs: const [
                Tab(text: 'Completed'),
                Tab(text: 'Ongoing'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Completed Courses Tab
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: completedCourses.length,
                  itemBuilder: (context, index) {
                    final course = completedCourses[index];
                    return Container(
                      height: 120,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseLessonsScreen(
                                courseTitle: course['title'],
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                              child: Image.asset(
                                course['image'],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            course['title'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xff167F71),
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 20),
                                        Text(
                                          ' ${course['rating']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(Icons.access_time,
                                            size: 18, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          course['duration'],
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CertificateScreen(
                                              courseTitle: course['title'],
                                            ),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(50, 30),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        'VIEW CERTIFICATE',
                                        style: TextStyle(
                                          color: Color(0xff0961F5),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Ongoing Courses Tab
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: ongoingCourses.length,
                  itemBuilder: (context, index) {
                    final course = ongoingCourses[index];
                    return Container(
                      height: 120,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseLessonsScreen(
                                courseTitle: course['title'],
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                              child: Image.asset(
                                course['image'],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            course['title'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          course['price'],
                                          style: const TextStyle(
                                            color: Color(0xff167F71),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 20),
                                        Text(
                                          ' ${course['rating']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(Icons.access_time,
                                            size: 18, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          course['duration'],
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: course['progress'],
                                        backgroundColor: Colors.grey[200],
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                          Color(0xff167F71),
                                        ),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
