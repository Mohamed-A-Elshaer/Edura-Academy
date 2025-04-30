import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/auth/Appwrite_service.dart';
import 'package:mashrooa_takharog/screens/StudentNavigatorScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mashrooa_takharog/screens/search_courses_page.dart';

import '../auth/supaAuth_service.dart';
import 'CourseDetailScreen.dart'; // Import the search results page

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> searchHistory = [];
  List<Map<String, dynamic>> searchResults = [];
  String currentQuery = '';
  String? userId;

  // Example course and mentor data
  final List<Map<String, String>> courses = [
    {
      'category': 'Graphic Design',
      'title': 'Graphic Design Advanced',
    },
    {
      'category': 'Graphic Design',
      'title': 'Advance Diploma in Graphic Design',
    },
    {
      'category': 'Programming',
      'title': 'Web Developement Full Diploma',
    },
    {
      'category': 'Arts & Humanities',
      'title': 'Introdution to Arts',
    },
    {
      'category': 'Personal Development',
      'title': 'How to Discover More About Yourself',
    },
    {
      'category': 'SEO & Marketing',
      'title': 'Introduction to Stocks',
    },
    {
      'category': 'Office Productivity',
      'title': 'How to Manage Your Time Effectively',
    },
    {
      'category': 'SEO & Marketing',
      'title': 'Introduction to Social Marketing',
    },
    {
      'category': 'Cooking',
      'title': 'Healthy Cooking for a Healthy Family.',
    },
  ];

  final List<Map<String, String>> mentors = [
    {'name': 'Ahmed Abdullah', 'specialty': '3D Design'},
    {'name': 'Osama Ahmed', 'specialty': 'Arts & Humanities'},
    {'name': 'Amany Elsayed', 'specialty': 'Personal Development'},
    {'name': 'Mohamed Ahmed', 'specialty': 'SEO & Marketing'},
    {'name': 'Ahmed Khaled', 'specialty': 'Programming'},
    {'name': 'Robert William', 'specialty': 'Office Productivity'},
  ];

  @override
  void initState() {
    super.initState();
    _initUserAndLoadHistory();
  }

  static String getCourseCoverImageUrl(String courseName) {
    try {
      String formattedCourseName = courseName.replaceAll(' ', '_');
      final path = '$formattedCourseName/course_cover.jpg';
      final publicUrl =
          SupaAuthService.supabase.storage.from('profiles').getPublicUrl(path);
      print(publicUrl);
      return publicUrl;
    } catch (e) {
      print('Error fetching cover image from Supabase: $e');
      return ''; // fallback
    }
  }

  Future<void> _initUserAndLoadHistory() async {
    try {
      final user = await Appwrite_service.account.get();
      setState(() {
        userId = user.$id;
      });
      _loadSearchHistory();
    } catch (e) {
      print('Error getting current user: $e');
    }
  }

  Future<void> _loadSearchHistory() async {
    if (userId == null) return;

    try {
      final response = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        documentId: userId!,
      );

      setState(() {
        searchHistory =
            List<String>.from(response.data['searches_history'] ?? []);
      });
      print('Loaded search history: $searchHistory');
    } catch (e) {
      print('Error loading search history: $e');
    }
  }

  Future<void> saveSearchToHistory(String keyword) async {
    if (keyword.trim().isEmpty || userId == null) return;

    try {
      // Get current history
      final currentDoc = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        documentId: userId!,
      );

      List<String> history =
          List<String>.from(currentDoc.data['searches_history'] ?? []);

      // Avoid duplicates
      history.remove(keyword);
      history.insert(0, keyword); // Add to front

      // Limit to 10 items
      if (history.length > 10) {
        history.removeRange(10, history.length);
      }

      // Update document
      await Appwrite_service.databases.updateDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        documentId: userId!,
        data: {
          'searches_history': history,
        },
      );

      setState(() {
        searchHistory = history;
      });
      print('Saved search history: $history');
    } catch (e) {
      print('Error saving search history: $e');
    }
  }

  Future<void> _clearSearchHistory() async {
    if (userId == null) return;

    try {
      await Appwrite_service.databases.updateDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        documentId: userId!,
        data: {
          'searches_history': [],
        },
      );

      setState(() {
        searchHistory.clear();
      });
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  void _goToSearchResultsPage(String query) {
    saveSearchToHistory(query);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchCoursesPage()),
    );
  }

  void _search(String query) async {
    setState(() {
      currentQuery = query;
    });

    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }

    List<Map<String, String>> results = [];

    // Define your allowed enum values for course categories
    List<String> allowedCategories = [
      "Graphic Design",
      "Arts & Humanities",
      "Cooking",
      "Finance and Accounting",
      "Personal Development",
      "Office Productivity",
      "Programming",
      "SEO & Marketing"
    ];

    // Check if the query matches any enum category value
    String? matchedCategory = allowedCategories.firstWhere(
      (category) => category.toLowerCase().contains(query.toLowerCase()),
      orElse: () => '',
    );

    if (matchedCategory.isEmpty)
      matchedCategory = null; // convert empty string to null

    try {
      // ---- Fetch courses ----
      List<String> courseQueries = [
        Query.or([
          Query.search('title', query),
          Query.equal('category', matchedCategory ?? '__no_match__'),
        ]),
        Query.equal('upload_status', 'approved')
      ];

      final courseResponse = await Appwrite_service.databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        queries: courseQueries,
      );

      results.addAll(courseResponse.documents.map((doc) => {
            'type': 'course',
            'title': doc.data['title'] ?? '',
            'category': doc.data['category'] ?? '',
            'price': (doc.data['price'] ?? 0).toString(),
            'courseId': doc.$id,
            'imagePath': getCourseCoverImageUrl(doc.data['title'] ?? ''),
            'instructorName': doc.data['name'] ?? '',
          }));

      // ---- Fetch instructors ----
      final instructorResponse = await Appwrite_service.databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        queries: [
          Query.equal('user_type', 'instructor'),
          Query.or([
            Query.search('name', query),
            Query.search('major', query),
          ]),
        ],
      );

      results.addAll(instructorResponse.documents.map((doc) => {
            'type': 'instructor',
            'name': doc.data['name'],
            'specialty': doc.data['major'],
          }));
    } catch (e) {
      print('Error fetching search results: $e');
    }

    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => NavigatorScreen()));
          },
        ),
        title: const Text('Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearSearchHistory,
            tooltip: "Clear Search History",
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (query) {
                _search(query);
              },
              onSubmitted: (query) {
                saveSearchToHistory(query);
                _goToSearchResultsPage(query);
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search for courses or mentors...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Search History
            if (searchHistory.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Recent Searches",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: searchHistory.map((query) {
                      return GestureDetector(
                        onTap: () {
                          _searchController.text = query;
                          _search(query);
                        },
                        child: Chip(label: Text(query)),
                      );
                    }).toList(),
                  ),
                ],
              ),

            const SizedBox(height: 10),

            // Search Results
            Expanded(
                child: searchResults.isEmpty && currentQuery.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text("No matching results found"),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              saveSearchToHistory(currentQuery);
                              _goToSearchResultsPage(currentQuery);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search, color: Colors.blue),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Search for \"$currentQuery\"",
                                    style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 14,
                                      child:
                                          Icon(Icons.arrow_forward_ios_sharp))
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: searchResults.length + 1,
                        itemBuilder: (context, index) {
                          if (index < searchResults.length) {
                            final result = searchResults[index];
                            if (result['type'] == 'course') {
                              return Column(
                                children: [
                                  ListTile(
                                      leading: Icon(Icons.school,
                                          color: Colors.blue),
                                      title: Text(result['title'] ?? ''),
                                      subtitle: Text(result['category'] ?? ''),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                Coursedetailscreen(
                                              title: result['title'] ?? '',
                                              category:
                                                  result['category'] ?? '',
                                              imagePath: getCourseCoverImageUrl(
                                                  result['title'] ?? ''),
                                              courseId:
                                                  result['courseId'] ?? '',
                                              price:
                                                  result['price']?.toString() ??
                                                      '',
                                              instructorName:
                                                  result['instructorName'] ??
                                                      '',
                                            ),
                                          ),
                                        );
                                      }),
                                  const Divider(),
                                ],
                              );
                            } else if (result['type'] == 'instructor') {
                              return Column(
                                children: [
                                  ListTile(
                                    leading:
                                        Icon(Icons.person, color: Colors.blue),
                                    title: Text(result['name'] ?? ''),
                                    subtitle: Text(result['specialty'] ?? ''),
                                  ),
                                  const Divider(),
                                ],
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          } else {
                            // The "Search for [query]" option
                            return GestureDetector(
                              onTap: () => _goToSearchResultsPage(currentQuery),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.search,
                                        color: Colors.blue),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Search for \"$currentQuery\"",
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 14,
                                        child:
                                            Icon(Icons.arrow_forward_ios_sharp))
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      )),
          ],
        ),
      ),
    );
  }
}
