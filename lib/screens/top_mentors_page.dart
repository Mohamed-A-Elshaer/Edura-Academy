import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/HomeScreen.dart';
import 'package:mashrooa_takharog/screens/StudentNavigatorScreen.dart';

class TopMentorsPage extends StatefulWidget {
  const TopMentorsPage({Key? key}) : super(key: key);

  @override
  State<TopMentorsPage> createState() => _TopMentorsPageState();
}

class _TopMentorsPageState extends State<TopMentorsPage> {
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  final List<Map<String, String>> mentors = [
    {'name': 'Ahmed Abdullah', 'specialty': '3D Design'},
    {'name': 'Osama Ahmed', 'specialty': 'Arts & Humanities'},
    {'name': 'Amany Elsayed', 'specialty': 'Personal Development'},
    {'name': 'Mohamed Ahmed', 'specialty': 'SEO & Marketing'},
    {'name': 'Ahmed Khaled', 'specialty': 'Programming'},
    {'name': 'Robert William', 'specialty': 'Office Productivity'},
  ];

  List<Map<String, String>> get filteredMentors {
    if (_searchText.isEmpty) {
      return mentors;
    }
    return mentors.where((mentor) =>
    mentor['name']!.toLowerCase().contains(_searchText.toLowerCase()) ||
        mentor['specialty']!.toLowerCase().contains(_searchText.toLowerCase())
    ).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: _isSearching
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchText = '';
              _searchController.clear();
            });
          },
        )
            : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NavigatorScreen()));
          },
        ),
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Search mentors...",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchText = value;
            });
          },
        )
            : const Text('Top Mentors'),
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
      body: ListView.builder(
        itemCount: filteredMentors.length,
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person_outline, color: Colors.grey[400]),
            ),
            title: Text(
              filteredMentors[index]['name']!,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              filteredMentors[index]['specialty']!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          );
        },
      ),
     /* bottomNavigationBar: BottomNavigationBar(
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
        ],
      ),*/
    );
  }
}
