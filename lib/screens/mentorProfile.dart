import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/CourseDetailScreen.dart';
//import 'package:mashrooa_takharog/screens/search_courses_page.dart';



class Mentorprofile extends StatefulWidget {
  const Mentorprofile({super.key});

  @override
  State<Mentorprofile> createState() => _Mentorprofile();
}

class _Mentorprofile extends State<Mentorprofile> {
  bool _showrating = false;
  @override
  Widget build(BuildContext context) {
    return 
       Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          leading: const Icon(Icons.arrow_back),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              _buildProfileSection(),
              const SizedBox(height: 20),
              
             
              _buildQuoteSection(),
              const SizedBox(height: 20),

             
           Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showrating = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_showrating
                          ? Colors.teal
                          : Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Courses',
                        style: TextStyle(
                            color: !_showrating ? Colors.white : Colors.black)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showrating = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showrating
                          ? Colors.teal
                          : Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Ratings',
                        style: TextStyle(
                            color: _showrating ? Colors.white : Colors.black)),
                  ),
                ),
              ],
            ),
          ),
           if(_showrating)...[
                  ReviewCard(
              name: 'Will',
              review:
                  'This course has been very useful. Mentor was well spoken totally tuned.',
              timeAgo: '2 Weeks Ago',
              rating: 4.3,
            )
             ]  
          ,

             if(!_showrating)...[

               Expanded(
                child: _buildContentList(),
              ),
             ],
              const SizedBox(height: 16),

             
              
            ],
          ),
        ),
      )
    ;
  }

  
  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/mentor.jpg'), 
                ),
                SizedBox(height: 16),
                Text(
                  'Ramy Gamal',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                 Text(
          'Graphic Designer At Google',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatColumn('26', 'Courses'),
            _buildStatColumn('15800', 'Students'),
            _buildStatColumn('8750', 'Ratings'),
          ],
        ),
      ],
    );
  }

  
  Widget _buildStatColumn(String stat, String label) {
    return Column(
      children: [
        Text(
          stat,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  
  Widget _buildQuoteSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        '“But how much, or rather, can it now do as much as it did then? Nor am I unaware that there is utility in history, not only pleasure.”',
        style: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

 
  Widget _buildTabBar() {
    return const DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: 'Courses'),
              Tab(text: 'Ratings'),
            ],
          ),
        ],
      ),
    );
  }

  
  Widget _buildContentList() {
    return ListView(
      children: [
        _buildCourseItem(
          'Graphic Design Adv..',
          'Graphic Design',
          '799₹ /-',
          4.2,
          '7830 Std',
        ),
        _buildCourseItem(
          'Graphic Design Adv..',
          'Graphic Design',
          '799₹ /-',
          4.2,
          '989 Std',
        ),
      ],
    );
  }

  Widget _buildCourseItem(
      String title, String category, String price, double rating, String students) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage('assets/images/advertisment.jpg'), 
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$rating ★',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    students,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}