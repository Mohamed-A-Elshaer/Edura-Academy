import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/auth/Appwrite_service.dart';
import 'package:mashrooa_takharog/auth/supaAuth_service.dart';
import 'package:mashrooa_takharog/screens/popular_courses_page_new.dart';
import 'package:mashrooa_takharog/screens/searchPage.dart';
import 'package:mashrooa_takharog/screens/search_courses_page.dart';
import 'package:mashrooa_takharog/screens/top_mentors_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:appwrite/appwrite.dart' as appwrite;
import 'SpecificCategoryPage.dart';
import 'categoriesPage.dart';
import '../widgets/coursecard.dart';
import '../widgets/mentor.dart';
import 'ProfileScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  int currentIndex = 0;
  String? nickname = "Loading...";
  final PageController _pageController = PageController(viewportFraction: 0.9);
  final PageController _coursePageController =
      PageController(viewportFraction: 0.6);
  static int selectedCardIndex = -1;
  int selectedcategoryindex = -1;
  List<String> savedCourseTitles = [];
  List<Map<String, dynamic>> mentors = [];

  final List<String> motivationalQuotes = [
    "Keep going, you're doing great!",
    "Learning is a treasure that will follow its owner everywhere.",
    "Success is the sum of small efforts repeated day in and day out.",
    "The future belongs to those who learn more skills and combine them in creative ways.",
    "Don't watch the clock; do what it does. Keep going.",
  ];

  String getRandomQuote() {
    final random = Random();
    int index = random.nextInt(motivationalQuotes.length);
    return motivationalQuotes[index];
  }

  final List<Map<String, dynamic>> _specialCardData = [
    {
      "backgroundColor": Color(0xff0961F5),
    },
    {
      "backgroundColor": Color(0xff00C853),
    },
    {
      "backgroundColor": Color(0xffFF6D00),
    },
  ];

  static final List<Map<String, dynamic>> categories = [
    {"title": "All"},
    {"title": "Graphic Design"},
    {"title": "Arts & Humanities"},
    {"title": "Cooking"},
    {"title": "SEO & Marketing"},
    {"title": "Programming"},
    {"title": "Finance and Accounting"},
    {"title": "Personal Development"},
    {"title": "Office Productivity"},
  ];

  final List<Map<String, dynamic>> newcategories = [
    {"title": "Graphic Design"},
    {"title": "Cooking"},
    {"title": "SEO & Marketing"},
    {"title": "Programming"},
    {"title": "Arts & Humanities"},
    {"title": "Finance and Accounting"},
    {"title": "Personal Development"},
    {"title": "Office productivity"},
  ];

  static List<Map<String, dynamic>> coursecardList = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchCoursesData();
    _fetchSavedCourseTitles();
    _fetchAndSortMentors();
  }

  List<Map<String, dynamic>> filteredCourses = [];
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

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          print('Document data: ${doc.data()}');
          setState(() {
            nickname = doc.data()?['nickName'] ?? "No Nickname";
          });
        } else {
          setState(() {
            nickname = "No Nickname Found";
          });
        }
      } else {
        print('No user currently signed in');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        nickname = "Error loading data";
      });
    }
  }

  Future<void> _fetchCoursesData() async {
    try {
      final coursesResponse = await Appwrite_service.databases.listDocuments(
        collectionId: '67c1c87c00009d84c6ff',
        databaseId: '67c029ce002c2d1ce046',
        queries: [
          appwrite.Query.equal('upload_status', 'approved'),
          appwrite.Query.orderDesc('averageRating'),
          appwrite.Query.limit(100)
        ],
      );

      final usersResponse = await Appwrite_service.databases.listDocuments(
        collectionId: '67c0cc3600114e71d658',
        databaseId: '67c029ce002c2d1ce046',
      );

      final Map<String, int> coursePurchaseCounts = {};
      for (final userDoc in usersResponse.documents) {
        final purchasedCourses =
            List<String>.from(userDoc.data['purchased_courses'] ?? []);
        for (final courseTitle in purchasedCourses) {
          final lowerTitle = courseTitle.toLowerCase();
          coursePurchaseCounts[lowerTitle] =
              (coursePurchaseCounts[lowerTitle] ?? 0) + 1;
        }
      }

      final List<Map<String, dynamic>> fetchedCourses = [];
      for (final doc in coursesResponse.documents) {
        final courseTitle = doc.data['title'] ?? 'Untitled';
        final purchaseCount =
            coursePurchaseCounts[courseTitle.toLowerCase()] ?? 0;

        final coverUrl =
            await SupaAuthService.getCourseCoverImageUrl(courseTitle);

        fetchedCourses.add({
          'id': doc.$id,
          'imagePath':
              coverUrl.isNotEmpty ? coverUrl : 'assets/images/mediahandler.png',
          'category': doc.data['category'] ?? 'Unknown',
          'title': courseTitle,
          'price': '${doc.data['price']?.toString() ?? '0'}',
          'rating': doc.data['averageRating']?.toDouble() ?? 0.0,
          'students': purchaseCount,
          'instructor_name': doc.data['instructor_name'] ?? 'Unknown',
        });
      }

      setState(() {
        coursecardList = fetchedCourses;
        _filterCourses(0);
      });
    } catch (e) {
      print('Error fetching courses: $e');
      setState(() {
        _filterCourses(0);
      });
    }
  }

  void _filterCourses(int index) async {
    setState(() {
      selectedCardIndex = index;
      filteredCourses = []; // Clear while loading
    });

    try {
      // 1. First get fresh user data to count purchases
      final usersResponse = await Appwrite_service.databases.listDocuments(
        collectionId: '67c0cc3600114e71d658',
        databaseId: '67c029ce002c2d1ce046',
      );

      // 2. Count purchases (same as in _fetchCoursesData)
      final Map<String, int> coursePurchaseCounts = {};
      for (final userDoc in usersResponse.documents) {
        final purchasedCourses =
            List<String>.from(userDoc.data['purchased_courses'] ?? []);
        for (final courseTitle in purchasedCourses) {
          final lowerTitle = courseTitle.toLowerCase();
          coursePurchaseCounts[lowerTitle] =
              (coursePurchaseCounts[lowerTitle] ?? 0) + 1;
        }
      }

      // 3. Apply filtering
      List<Map<String, dynamic>> resultCourses;
      if (index == 0) {
        resultCourses = List.from(coursecardList);
      } else {
        String selectedCategory = categories[index]['title'];
        resultCourses = coursecardList
            .where((course) => course['category'] == selectedCategory)
            .toList();
      }

      // 4. Update counts and sort
      resultCourses = resultCourses.map((course) {
        return {
          ...course,
          'students': coursePurchaseCounts[course['title'].toLowerCase()] ?? 0,
        };
      }).toList()
        ..sort((a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0));

      setState(() {
        filteredCourses = index == 0
            ? resultCourses.take(10).toList()
            : resultCourses.take(6).toList();
      });
    } catch (e) {
      print('Error filtering courses: $e');
    }
  }

  Future<void> _fetchAndSortMentors() async {
    try {
      // Fetch all instructors
      final instructorsResponse = await Appwrite_service.databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        queries: [
          appwrite.Query.equal('user_type', 'instructor'),
        ],
      );

      // Fetch all courses
      final coursesResponse = await Appwrite_service.databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        queries: [
          appwrite.Query.equal('upload_status', 'approved'),
        ],
      );

      // Create maps to store counts for each instructor
      Map<String, int> instructorStudentCounts = {};
      Map<String, int> instructorCourseCounts = {};

      // Count courses for each instructor
      for (final course in coursesResponse.documents) {
        final instructorName = course.data['instructor_name'];
        if (instructorName != null) {
          instructorCourseCounts[instructorName] = (instructorCourseCounts[instructorName] ?? 0) + 1;
        }
      }

      // Count students for each instructor's courses
      final usersResponse = await Appwrite_service.databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
      );

      for (final user in usersResponse.documents) {
        final purchasedCourses = List<String>.from(user.data['purchased_courses'] ?? []);
        for (final courseTitle in purchasedCourses) {
          // Find the course to get instructor name
          final course = coursesResponse.documents.firstWhere(
            (c) => c.data['title'] == courseTitle,
            orElse: () => coursesResponse.documents.first,
          );
          if (course != null) {
            final instructorName = course.data['instructor_name'];
            if (instructorName != null) {
              instructorStudentCounts[instructorName] = (instructorStudentCounts[instructorName] ?? 0) + 1;
            }
          }
        }
      }

      // Create mentor list with all required data
      List<Map<String, dynamic>> mentorList = [];
      for (final instructor in instructorsResponse.documents) {
        // Get instructor's email from Appwrite
        final instructorEmail = instructor.data['email'];

        // Get Supabase user ID using email
        final supabaseUserId = await SupaAuthService.getSupabaseUserId(instructorEmail);

        // Get profile image URL from Supabase storage
        String profileImageUrl = 'assets/images/mentor.jpg';
        if (supabaseUserId != null) {
          try {
            final files = await Supabase.instance.client.storage
                .from('profiles')
                .list(path: supabaseUserId);

            final hasProfileImage = files.any((file) => file.name == 'profile');
            if (hasProfileImage) {
              profileImageUrl = Supabase.instance.client.storage
                  .from('profiles')
                  .getPublicUrl('$supabaseUserId/profile');
            }
          } catch (e) {
            print('Error fetching profile image for instructor ${instructor.data['name']}: $e');
          }
        }

        mentorList.add({
          'id': instructor.$id,
          'name': instructor.data['name'] ?? 'Unknown',
          'imagePath': profileImageUrl,
          'studentCount': instructorStudentCounts[instructor.data['name']] ?? 0,
          'courseCount': instructorCourseCounts[instructor.data['name']] ?? 0,
          'major': instructor.data['major'] ?? 'No major specified',
          'title': instructor.data['title'] ?? 'Instructor',
        });
      }

      // Sort mentors by student count in descending order
      mentorList.sort((a, b) => (b['studentCount'] as int).compareTo(a['studentCount'] as int));

      setState(() {
        mentors = mentorList;
      });
    } catch (e) {
      print('Error fetching and sorting mentors: $e');
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

  @override
  void dispose() {
    _pageController.dispose();
    _coursePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Hi, ${nickname ?? "Loading..."}",
          style: TextStyle(color: Color(0xff232546)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0
      ),
      body: CustomScrollView(
        slivers: [
          // Search Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What would you like to learn today?\nsearch below!',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchPage()));
                    },
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 20.0),
                      prefixIcon: Icon(
                        Icons.search_outlined,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xff0961F5),
                          ),
                          child: const Icon(
                            Icons.search_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      hintText: "search for...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _specialCardData.length,
                itemBuilder: (context, index) {
                  final data = _specialCardData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: data['backgroundColor'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            getRandomQuote(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 8,
            ),
          ),

          SliverToBoxAdapter(
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _specialCardData.length,
                effect: const WormEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: Colors.blue,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Text(
                    'SEE ALL',
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Categoriespage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    color: Colors.blue,
                  )
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: newcategories.length > 4 ? 4 : newcategories.length,
                itemBuilder: (context, index) {
                  final data = newcategories[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedcategoryindex = index;
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpecificCategoryPage(
                            category: data['title'] ?? '',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          data['title'] ?? '',
                          style: TextStyle(
                            color: selectedcategoryindex == index
                                ? Colors.blue
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  const Text(
                    'Popular Courses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Text(
                    'SEE ALL',
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PopularCoursesPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final data = categories[index];
                  return GestureDetector(
                    onTap: () => _filterCourses(index),
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
          ),
        const  SliverToBoxAdapter(
            child: SizedBox(
              height: 11,
            ),
          ),

          SliverToBoxAdapter(
              child: SizedBox(
            height: 360,
            child: filteredCourses.isEmpty
                ? const Center(
                    child: Text(
                      "No courses available!",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
                      return Container(
                        margin: const EdgeInsets.only(left: 2),
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: CourseCard(
                          title: course['title'],
                          courseId: course['id'],
                          price: course['price'],
                          imagePath: course['imagePath'],
                          category: course['category'],
                          rating: course['rating'] ?? 0.0,
                          instructorName:
                              course['instructor_name'] ?? 'Unknown',
                          isBookmarked:
                              savedCourseTitles.contains(course['title']),
                          onBookmarkToggle: () =>
                              _toggleBookmark(course['title']),
                        ),
                      );
                    },
                  ),
          )),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  const Text(
                    'Top Mentors',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Text(
                    'SEE ALL',
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TopMentorsPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
              child: SizedBox(
            height: 122,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mentors.length,
              itemBuilder: (context, index) {
                final mentor = mentors[index];
                return MentorCard(
                  name: mentor['name'],
                  imagePath: mentor['imagePath'],
                  mentorId: mentor['id'],
                  courseCount: mentor['courseCount'],
                  studentCount: mentor['studentCount'],
                  major: mentor['major'],
                  title: mentor['title'],
                );
              },
            ),
          )),
        ],
      ),
      /*   bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            currentIndex = index; // Update the current index
          });

        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'My Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border_outlined), label: 'Bookmarks'),
          BottomNavigationBarItem(
              icon: Icon(Icons.payment), label: 'Transaction'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile',),
        ],
      ),*/
    );
  }
}
