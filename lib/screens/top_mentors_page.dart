import 'package:mashrooa_takharog/screens/StudentNavigatorScreen.dart';

import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/auth/Appwrite_service.dart';
import 'package:mashrooa_takharog/auth/supaAuth_service.dart';
import 'package:mashrooa_takharog/widgets/mentor.dart';
import 'package:appwrite/appwrite.dart' as appwrite;

class TopMentorsPage extends StatefulWidget {
  const TopMentorsPage({super.key});

  @override
  State<TopMentorsPage> createState() => _TopMentorsPageState();
}

class _TopMentorsPageState extends State<TopMentorsPage> {
  List<Map<String, dynamic>> mentors = [];
  int? expandedIndex;

  @override
  void initState() {
    super.initState();
    _fetchAndSortMentors();
  }

  Future<void> _fetchAndSortMentors() async {
    try {
      // Fetch all instructors
      final instructorsResponse =
          await Appwrite_service.databases.listDocuments(
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

      // Create a map to store student counts for each instructor
      Map<String, int> instructorStudentCounts = {};
      Map<String, List<Map<String, dynamic>>> instructorCourses = {};

      // Count students for each instructor's courses
      for (final course in coursesResponse.documents) {
        final instructorId = course.data['instructor_id'];
        final studentCount = await getTotalStudents(course.data['title']);

        instructorStudentCounts[instructorId] =
            (instructorStudentCounts[instructorId] ?? 0) + studentCount;

        // Add course to instructor's courses list
        if (!instructorCourses.containsKey(instructorId)) {
          instructorCourses[instructorId] = [];
        }
        instructorCourses[instructorId]!.add({
          'title': course.data['title'],
          'description': course.data['description'],
          'price': course.data['price'],
          'rating': course.data['averageRating'],
          'students': studentCount,
        });
      }

      // Create mentor list with student counts
      List<Map<String, dynamic>> mentorList = [];
      for (final instructor in instructorsResponse.documents) {
        // Get instructor's email from Appwrite
        final instructorEmail = instructor.data['email'];

        // Get Supabase user ID using email
        final supabaseUserId =
            await SupaAuthService.getSupabaseUserId(instructorEmail);

        // Get profile image URL from Supabase storage
        String profileImageUrl = 'assets/images/mentor.jpg';
        if (supabaseUserId != null) {
          try {
            final files = await SupaAuthService.supabase.storage
                .from('profiles')
                .list(path: supabaseUserId);

            final hasProfileImage = files.any((file) => file.name == 'profile');
            if (hasProfileImage) {
              profileImageUrl = SupaAuthService.supabase.storage
                  .from('profiles')
                  .getPublicUrl('$supabaseUserId/profile');
            }
          } catch (e) {
            print(
                'Error fetching profile image for instructor ${instructor.data['name']}: $e');
          }
        }

        mentorList.add({
          'id': instructor.$id,
          'name': instructor.data['name'] ?? 'Unknown',
          'email': instructorEmail,
          'imagePath': profileImageUrl,
          'studentCount': instructorStudentCounts[instructor.$id] ?? 0,
          'courses': instructorCourses[instructor.$id] ?? [],
        });
      }

      // Sort mentors by student count in descending order
      mentorList.sort((a, b) =>
          (b['studentCount'] as int).compareTo(a['studentCount'] as int));

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => NavigatorScreen()));
          },
        ),
        title: const Text('Top Mentors'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: mentors.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mentors.length,
              itemBuilder: (context, index) {
                final mentor = mentors[index];
                final isExpanded = expandedIndex == index;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            expandedIndex = isExpanded ? null : index;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    mentor['imagePath'].startsWith('http')
                                        ? NetworkImage(mentor['imagePath'])
                                        : AssetImage(mentor['imagePath'])
                                            as ImageProvider,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mentor['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${mentor['studentCount']} Students • ${mentor['courses'].length} Courses',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded) ...[
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email: ${mentor['email']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Courses',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...mentor['courses'].map<Widget>((course) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course['title'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          course['description'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '\$${course['price']}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  course['rating']
                                                          ?.toStringAsFixed(
                                                              1) ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  '${course['students']} students',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
