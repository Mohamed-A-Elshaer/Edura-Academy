import 'package:mashrooa_takharog/screens/StudentNavigatorScreen.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/auth/Appwrite_service.dart';
import 'package:mashrooa_takharog/auth/supaAuth_service.dart';
import 'package:mashrooa_takharog/widgets/mentor.dart';
import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:mashrooa_takharog/screens/mentorProfile.dart';

class TopMentorsPage extends StatefulWidget {
  const TopMentorsPage({super.key});

  @override
  State<TopMentorsPage> createState() => _TopMentorsPageState();
}

class _TopMentorsPageState extends State<TopMentorsPage> {
  List<Map<String, dynamic>> mentors = [];

  @override
  void initState() {
    super.initState();
    _fetchAndSortMentors();
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

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Mentorprofile(
                            mentorId: mentor['id'],
                            name: mentor['name'],
                            imagePath: mentor['imagePath'],
                            courseCount: mentor['courseCount'],
                            studentCount: mentor['studentCount'],
                            major: mentor['major'],
                            title: mentor['title'],
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: mentor['imagePath'].startsWith('http')
                                ? NetworkImage(mentor['imagePath'])
                                : AssetImage(mentor['imagePath']) as ImageProvider,
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
                                  '${mentor['studentCount']} Students • ${mentor['courseCount']} Courses',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
