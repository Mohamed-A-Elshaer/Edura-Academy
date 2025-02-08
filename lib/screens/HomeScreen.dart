
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/popular_courses_page.dart';
import 'package:mashrooa_takharog/screens/searchPage.dart';
import 'package:mashrooa_takharog/screens/search_courses_page.dart';
import 'package:mashrooa_takharog/screens/top_mentors_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'categoriesPage.dart';
import '../widgets/coursecard.dart';
import '../widgets/mentor.dart';
import 'ProfileScreen.dart';


class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  int currentIndex = 0;
  String? nickname = "Loading...";
  final PageController _pageController = PageController(viewportFraction: 0.9);
  final PageController _coursePageController = PageController(viewportFraction: 0.6);
 static int selectedCardIndex = -1;
  int selectedcategoryindex=-1;
  final List<Map<String, String>> mentors = [
    {"name": "Ahmed Abdullah", "imagePath": "assets/images/mentor.jpg"},
    {"name": "Osama Ahmed", "imagePath": "assets/images/mentor.jpg"},
    {"name": "Amany Elsayed", "imagePath": "assets/images/mentor.jpg"},
    {"name": "Mohamed Ahmed", "imagePath": "assets/images/mentor.jpg"},
    {"name": "Ahmed Khaled", "imagePath": "assets/images/mentor.jpg"},
  ];

  final List<Map<String, dynamic>> _specialCardData = [
    {
      "discount": "25% OFF*",
      "title": "Today's Special",
      "description": "Get a discount for every course order only valid for today!",
      "backgroundColor": Colors.blue,
    },
    {
      "discount": "15% OFF*",
      "title": "Limited Offer",
      "description": "Special discount for our premium members!",
      "backgroundColor": Colors.green,
    },
    {
      "discount": "10% OFF*",
      "title": "Weekend Sale",
      "description": "Grab courses with discounted prices this weekend only!",
      "backgroundColor": Colors.purple,
    },
  ];

 static  final List<Map<String, dynamic>> categories = [
    {"title": "All"},
    {"title": "Graphic Design"},
    {"title": "Arts & Humanities"},
    {"title": "Cooking"},
    {"title": "SEO & Marketing"},
   {"title": "Web Development"},
   {"title": "Finance and Accounting"},
    {"title": "Personal Development"},
    {"title": "Office Productivity"},
  ];

  final List<Map<String, dynamic>> newcategories = [

    {"title": "Graphic Design"},
    {"title": "Cooking"},
    {"title": "SEO & Marketing"},
    {"title": "Web Development"},
    {"title": "Arts & Humanities"},
    {"title": "Finance and Accounting"},
    {"title": "Personal Development"},
    {"title": "Office productivity"},
  ];



  static final List<Map<String, dynamic>> coursecardList = [
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

  List<Map<String, dynamic>> filteredCourses = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _filterCourses(0);
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {


        final doc = await FirebaseFirestore.instance.collection('students').doc(user.uid).get();
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


  void _filterCourses(int index) {
    setState(() {
      selectedCardIndex = index;
      if (index == 0) {
        // Show all courses when "All" is selected
        filteredCourses = List.from(coursecardList);
      } else {
        String selectedCategory = categories[index]['title'];
        filteredCourses = coursecardList
            .where((course) => course['category'] == selectedCategory)
            .toList();
      }
    });
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
        title:  Text(
          "Hi, ${nickname ?? "Loading..."}",
          style: TextStyle(color: Color(0xff232546)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:Color(0xff0961F5),
                width: 2.0,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.notifications,
                color: Color(0xff0961F5),
              ),
            ),
          ),

          const SizedBox(width: 16),
        ],
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
                    onTap: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SearchPage()));
                      },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
                      prefixIcon: Icon(Icons.search_outlined,),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(data['discount'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(data['title'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                )),
                            Text(data['description'] ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
SliverToBoxAdapter(child: SizedBox(height: 8,),),

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
                  const    Spacer(),
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
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white
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
                    onTap: () =>_filterCourses(index),
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
          SliverToBoxAdapter(
            child: SizedBox(height: 11,),
          ),

          SliverToBoxAdapter(
              child: SizedBox(
                height: 300,
                child: filteredCourses.isEmpty
                    ? Center(
                  child: Text(
                    "No courses available!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
                    :ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = filteredCourses[index];
                    return Container(
                      margin: const EdgeInsets.only(left: 2),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: CourseCard(
                        title: course['title'],
                        price: course['price'],
                        rating: course['rating'],
                        students: course['students'],
                        imagePath: course['imagePath'],
                        category: course['category'],
                      ),
                    );
                  },
                ),
              )



          ),
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
              child:  SizedBox(
                height: 122,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: mentors.length,
                  itemBuilder: (context, index) {
                    final mentor = mentors[index];
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      margin: const EdgeInsets.only(right: 8),
                      child: MentorCard(
                        name: mentor['name']!,
                        imagePath: mentor['imagePath']!,
                      ),
                    );
                  },
                ),
              )
          ),





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
