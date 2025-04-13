import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/auth/Appwrite_service.dart';
import 'package:mashrooa_takharog/screens/StudentNavigatorScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mashrooa_takharog/screens/search_courses_page.dart';

import 'CourseDetailScreen.dart'; // Import the search results page

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> searchHistory = [];
  List<Map<String, dynamic>> searchResults = [];
  String currentQuery = '';




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
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _saveSearchHistory(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!searchHistory.contains(query)) {
      searchHistory.insert(0, query);
      if (searchHistory.length > 10) {
        searchHistory = searchHistory.sublist(0, 10);
      }
      prefs.setStringList('searchHistory', searchHistory);
    }
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
          (category) => category.toLowerCase() == query.toLowerCase(),
      orElse: () => '', // return empty string
    );

    if (matchedCategory.isEmpty) matchedCategory = null; // convert empty string to null


    try {
      // ---- Fetch courses ----
      List<String> courseQueries = [];

      // Only use Query.search on title (fulltext index required for that)
      courseQueries.add(Query.search('title', query));

      // Add category query only if matched
      if (matchedCategory != null) {
        courseQueries.add(Query.equal('category', matchedCategory));
      }

      final courseResponse = await Appwrite_service.databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        queries: courseQueries,
      );

      results.addAll(courseResponse.documents.map((doc) => {
        'type': 'course',
        'title': doc.data['title'],
        'category': doc.data['category'],
        'price': doc.data['price'].toString(),
        'courseId': doc.$id,
        'imagePath': "${doc.data['title'].replaceAll(' ', '_')}/course_cover.jpg",
        'instructorName': doc.data['name'],
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



  Future<void> _clearSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
    setState(() {
      searchHistory.clear();
    });
  }

  void _goToSearchResultsPage(String query) {
    _saveSearchHistory(query);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchCoursesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NavigatorScreen()));
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
                  const Text("Recent Searches", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    onTap: () => _goToSearchResultsPage(currentQuery),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
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
                            leading: Icon(Icons.school, color: Colors.blue),
                            title: Text(result['title'] ?? ''),
                            subtitle: Text(result['category'] ?? ''),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Coursedetailscreen(
                                      title: result['title'] ?? '',
                                      category: result['category'] ?? '',
                                      imagePath: result['imagePath'] ?? '',
                                      courseId: result['courseId'] ?? '',
                                      price: result['price']?.toString() ?? '',
                                      instructorName: result['instructorName'] ?? '',
                                    ),
                                  ),
                                );
                              }

                          ),
                          const Divider(),
                        ],
                      );
                    } else if (result['type'] == 'instructor') {
                      return Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.person, color: Colors.blue),
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
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        margin: const EdgeInsets.only(top: 8),
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
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              )

            ),
          ],
        ),
      ),
    );
  }
}
