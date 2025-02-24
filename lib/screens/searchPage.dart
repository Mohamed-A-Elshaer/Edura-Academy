import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/StudentNavigatorScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mashrooa_takharog/screens/search_courses_page.dart'; // Import the search results page

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> searchHistory = [];
  List<Map<String, String>> searchResults = [];
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
      'category': 'Web Development',
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
    {'name': 'Ahmed Khaled', 'specialty': 'Web Development'},
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

  void _search(String query) {
    setState(() {
      currentQuery = query;

      if (query.isEmpty) {
        searchResults.clear();
      } else {
        searchResults = [
          ...courses.where((course) =>
              course['title']!.toLowerCase().contains(query.toLowerCase()) ||
              course['category']!.toLowerCase().contains(query.toLowerCase())),
          ...mentors.where((mentor) =>
              mentor['name']!.toLowerCase().contains(query.toLowerCase()) ||
              mentor['specialty']!.toLowerCase().contains(query.toLowerCase())),
        ];
      }
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
      MaterialPageRoute(builder: (context) => const SearchCoursesPage()),
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
                          onTap: () => _goToSearchResultsPage(currentQuery),
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
                          bool isCourse =
                              searchResults[index].containsKey('title');
                          return Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  isCourse
                                      ? Icons.school
                                      : Icons.person, // Use appropriate icon
                                  color: Colors.blue,
                                ),
                                title: Text(searchResults[index]['title'] ??
                                    searchResults[index]['name']!),
                                subtitle: Text(searchResults[index]
                                        ['category'] ??
                                    searchResults[index]['specialty']!),
                              ),
                              const Divider(),
                            ],
                          );
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
                                  const Icon(Icons.search, color: Colors.blue),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Search for \"$currentQuery\"",
                                    style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
