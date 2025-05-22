import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/CourseDetailScreen.dart';
import 'package:mashrooa_takharog/screens/FilterScreen.dart';
import 'package:mashrooa_takharog/screens/StudentNavigatorScreen.dart';
import 'package:mashrooa_takharog/screens/searchPage.dart';

import '../auth/Appwrite_service.dart';

class SearchCoursesPage extends StatefulWidget {
  final String initialQuery;
  const SearchCoursesPage({super.key, this.initialQuery = ''});

  @override
  State<SearchCoursesPage> createState() => SearchCoursesPageState();
}

class SearchCoursesPageState extends State<SearchCoursesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showMentors = false;
  static List<Map<String, dynamic>> savedCourses = [];
  List<Map<String, dynamic>> mentors = [];
  bool isLoading = true;
  List<String> savedCourseTitles = [];

  static List<Map<String, dynamic>> courses = [];
  Map<String, dynamic>? filters;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    _searchQuery = widget.initialQuery;
    _loadBookmarksAndCourses();
  }

  Future<void> _loadBookmarksAndCourses() async {
    await _fetchSavedCourseTitles();
    await _fetchCourses();
    await _fetchMentors();
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

      setState(() {
        courses = response.documents
            .where((doc) => doc.data['upload_status'] == 'approved')
            .map((doc) => {
                  'title': doc.data['title'] ?? '',
                  'instructor': doc.data['instructor_name'] ?? '',
                  'category': doc.data['category'] ?? '',
                  'price': (doc.data['price'] ?? 0).toString(),
                  'courseId': doc.$id,
                  'imagePath': SearchPageState.getCourseCoverImageUrl(
                      doc.data['title'] ?? ''),
                  'instructorName': doc.data['name'] ?? '',
                  'rating': doc.data['averageRating'] ?? 0.0,
                  'students': '1000 Std',
                  'duration': doc.data['courseDuration_inMins'] ?? 0
                })
            .toList();
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

  Future<void> _fetchMentors() async {
    try {
      final response = await Appwrite_service.databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        queries: [
          appwrite.Query.equal('user_type', 'instructor'),
        ],
      );

      setState(() {
        mentors = response.documents.map((doc) {
          return {
            'name': doc.data['name'] ?? '',
            'specialty': doc.data['major'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching mentors: $e');
    }
  }

  List<Map<String, dynamic>> get filteredCourses {
    List<Map<String, dynamic>> result = List.from(courses);

    // Apply search filter first
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

    // If no filters are applied, return search results
    if (filters == null) {
      return result;
    }

    // Create a new list for filtered results
    List<Map<String, dynamic>> filteredResults = [];

    // Apply each filter type only if it has values
    if (filters!['categories']?.isNotEmpty ?? false) {
      filteredResults.addAll(result.where((course) {
        return filters!['categories'].contains(course['category']);
      }));
    }

    if (filters!['prices']?.isNotEmpty ?? false) {
      filteredResults.addAll(result.where((course) {
        return filters!['prices'].any((price) {
          if (price == 'Free') return course['price'] == '0';
          if (price == 'Paid') return course['price'] != '0';
          return false;
        });
      }));
    }

    if (filters!['ratings']?.isNotEmpty ?? false) {
      filteredResults.addAll(result.where((course) {
        double rating = double.tryParse(course['rating'].toString()) ?? 0;
        return filters!['ratings'].any((ratingFilter) {
          final parsed = double.tryParse(
              ratingFilter.split(' ')[0]); // "4.5" from "4.5 & Up Above"
          return parsed != null && rating >= parsed;
        });
      }));
    }

    if (filters!['durations']?.isNotEmpty ?? false) {
      filteredResults.addAll(result.where((course) {
        int courseDuration = int.tryParse(course['duration'].toString()) ?? 0;
        return filters!['durations'].any((durationFilter) {
          if (durationFilter == '0-5 Minutes') return courseDuration <= 5;
          if (durationFilter == '5-10 Minutes')
            return courseDuration > 5 && courseDuration <= 10;
          if (durationFilter == '10-30 Minutes')
            return courseDuration > 10 && courseDuration <= 30;
          if (durationFilter == '30+ Minutes') return courseDuration > 30;
          return false;
        });
      }));
    }

    // If no filters were applied (all were empty), return all results
    if (filteredResults.isEmpty &&
        (!(filters!['categories']?.isNotEmpty ?? false) &&
            !(filters!['prices']?.isNotEmpty ?? false) &&
            !(filters!['ratings']?.isNotEmpty ?? false) &&
            !(filters!['durations']?.isNotEmpty ?? false))) {
      return result;
    }

    // Remove duplicates by courseId
    final ids = filteredResults.map((e) => e['courseId']).toSet();
    filteredResults.retainWhere((x) => ids.remove(x['courseId']));

    return filteredResults;
  }

  List<Map<String, dynamic>> get filteredMentors {
    if (_searchQuery.isEmpty) return mentors;

    return mentors.where((mentor) {
      return mentor['name']!
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          mentor['specialty']!
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NavigatorScreen()));}
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
                          // Replace the entire filter icon's onTap with this:
                          onTap: () async {
                            try {
                              final result =
                                  await Navigator.push<Map<String, dynamic>>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FilterScreen(
                                    initialFilters: filters ??
                                        {
                                          'categories': [],
                                          'prices': [],
                                          'ratings': [],
                                          'durations': []
                                        },
                                  ),
                                ),
                              );

                              if (result != null) {
                                setState(() {
                                  // Create a new filters map with all fields
                                  final newFilters = <String, dynamic>{
                                    'categories': List<String>.from(
                                        result['categories'] ?? []),
                                    'prices': List<String>.from(
                                        result['prices'] ?? []),
                                    'ratings': List<String>.from(
                                        result['ratings'] ?? []),
                                    'durations': List<String>.from(
                                        result['durations'] ?? []),
                                  };

                                  // Only set filters if at least one filter is active
                                  filters = (newFilters['categories']!
                                              .isNotEmpty ||
                                          newFilters['prices']!.isNotEmpty ||
                                          newFilters['ratings']!.isNotEmpty ||
                                          newFilters['durations']!.isNotEmpty)
                                      ? newFilters
                                      : null;

                                  print('Applied filters: $filters');
                                });
                              } else {
                                setState(() {
                                  filters = null;
                                });
                              }
                            } catch (e) {
                              print('Error handling filters: $e');
                            }
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
                      backgroundColor:
                          !_showMentors ? Colors.teal : Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Courses',
                        style: TextStyle(
                            color:
                                !_showMentors ? Colors.white : Colors.black)),
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
                      backgroundColor:
                          _showMentors ? Colors.teal : Colors.grey[200],
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _showMentors
                    ? filteredMentors.isEmpty
                        ? const Center(child: Text('No mentors available!'))
                        : ListView.builder(
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
                    : filteredCourses.isEmpty
                        ? const Center(child: Text('No courses available!'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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

class SearchCourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final List<String> savedCourseTitles;
  final Function(String) onBookmarkToggle;

  const SearchCourseCard({
    super.key,
    required this.course,
    required this.savedCourseTitles,
    required this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    final courseId = course['courseId'] ?? '';
    final imagePath = course['imagePath'] ?? '';
    final category = course['category'] ?? '';
    final title = course['title'] ?? '';
    final instructor = course['instructor'] ?? '';
    final price = course['price']?.toString() ?? '0';
    final rating = course['rating']?.toString() ?? '0';
    final students = course['students']?.toString() ?? '0 Std';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imagePath,
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
                    'By: $instructor',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'EGP $price',
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
            Column(children: [
              IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Coursedetailscreen(
                                category: category,
                                imagePath: imagePath,
                                title: title,
                                courseId: courseId,
                                price: price,
                                instructorName: instructor)));
                  },
                  icon: Icon(Icons.arrow_forward_ios_outlined)),
              IconButton(
                icon: Icon(
                  savedCourseTitles.contains(title)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: savedCourseTitles.contains(title) ? Colors.teal : null,
                ),
                onPressed: () => onBookmarkToggle(title),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
