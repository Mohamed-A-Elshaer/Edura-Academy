import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import '../auth/Appwrite_service.dart';
import 'CourseDetailScreen.dart';
import 'DisplayCourseLessons.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  TextEditingController _searchController = TextEditingController();
  bool _showOngoing = true; // Default to showing ongoing courses
  List<Map<String, dynamic>> enrolledCourses = [];
  List<Map<String, dynamic>> completedCourses = [];
  List<Map<String, dynamic>> ongoingCourses = [];
  bool isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _fetchEnrolledCourses();
  }

  Future<void> _fetchEnrolledCourses() async {
    if (!mounted) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      print('Fetching enrolled courses...');

      // Get current user
      final currentUser = await Appwrite_service.account.get();

      // Get user's document
      final userDoc = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        documentId: currentUser.$id,
      );

      // Get purchased courses array and completed videos
      List<String> purchasedCourseTitles =
          List<String>.from(userDoc.data['purchased_courses'] ?? []);
      List<String> completedVideos =
          List<String>.from(userDoc.data['completed_videos'] ?? []);

      print('Purchased courses: $purchasedCourseTitles');
      print('Completed videos: $completedVideos');

      // Fetch details for each purchased course
      List<Map<String, dynamic>> courses = [];
      for (String courseTitle in purchasedCourseTitles) {
        try {
          // Search for course in courses collection
          final response = await Appwrite_service.databases.listDocuments(
            databaseId: '67c029ce002c2d1ce046',
            collectionId: '67c1c87c00009d84c6ff',
            queries: [
              Query.equal('title', courseTitle),
            ],
          );

          if (response.documents.isNotEmpty) {
            final course = response.documents.first;

            // Get video IDs for this course
            final files = await Appwrite_service.storage.listFiles(
              bucketId: '67ac838900066b15fc99',
              queries: [
                Query.startsWith('name', '${courseTitle.replaceAll(' ', '_')}'),
                Query.endsWith('name', '.mp4'),
              ],
            );

            List<String> courseVideoIds =
                files.files.map((file) => file.$id).toList();

            // Count completed videos for this course
            int completedCount = courseVideoIds
                .where((videoId) => completedVideos.contains(videoId))
                .length;

            // Calculate completion percentage
            double completionPercentage = courseVideoIds.isEmpty
                ? 0.0
                : (completedCount / courseVideoIds.length) * 100;

            print('Course: $courseTitle');
            print('Course video IDs: $courseVideoIds');
            print('Total Videos: ${courseVideoIds.length}');
            print('Completed Videos: $completedCount');
            print('Completion Percentage: $completionPercentage%');

            courses.add({
              'title': course.data['title'] ?? 'Untitled Course',
              'category': course.data['category'] ?? 'Uncategorized',
              'imagePath': course.data['imagePath'] ??
                  'https://via.placeholder.com/300x200',
              'courseId': course.$id,
              'price': course.data['price'] ?? '0',
              'instructorName':
                  course.data['instructorName'] ?? 'Unknown Instructor',
              'videoCount': courseVideoIds.length,
              'completedVideos': completedCount,
              'duration': course.data['courseDuration_inMins'] ?? 0,
              'rating': course.data['rating'] ?? '4.5',
              'completionPercentage': completionPercentage,
            });
          }
        } catch (e) {
          print('Error fetching course $courseTitle: $e');
        }
      }

      // Categorize courses
      completedCourses = courses
          .where((course) => course['completionPercentage'] >= 100)
          .toList();
      ongoingCourses = courses
          .where((course) => course['completionPercentage'] < 100)
          .toList();

      print('Completed Courses: ${completedCourses.length}');
      print('Ongoing Courses: ${ongoingCourses.length}');

      if (mounted) {
        setState(() {
          enrolledCourses = _showOngoing ? ongoingCourses : completedCourses;
          isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      print('Error fetching enrolled courses: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          _isRefreshing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing courses: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method to check and update course completion status
  Future<void> _checkAndUpdateCourseCompletion(
      String userId, String courseTitle, List<String> completedVideos) async {
    try {
      print('Checking completion status for course: $courseTitle');

      // Get user document to update completed courses
      final userDoc = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        documentId: userId,
      );

      // Get current lists
      List<String> completedCourses =
          List<String>.from(userDoc.data['completed_courses'] ?? []);
      List<String> ongoingCourses =
          List<String>.from(userDoc.data['ongoing_courses'] ?? []);

      // Get course details
      final courseResponse = await Appwrite_service.databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        queries: [
          Query.equal('title', courseTitle),
        ],
      );

      if (courseResponse.documents.isNotEmpty) {
        final course = courseResponse.documents.first;

        // Get video IDs for this course
        final files = await Appwrite_service.storage.listFiles(
          bucketId: '67ac838900066b15fc99',
          queries: [
            Query.startsWith('name', '${courseTitle.replaceAll(' ', '_')}'),
            Query.endsWith('name', '.mp4'),
          ],
        );

        List<String> courseVideoIds =
            files.files.map((file) => file.$id).toList();

        // Check if all videos are completed
        bool isFullyCompleted = true;
        for (String videoId in courseVideoIds) {
          if (!completedVideos.contains(videoId)) {
            isFullyCompleted = false;
            break;
          }
        }

        print('Course videos total: ${courseVideoIds.length}');
        print('User completed videos: ${completedVideos.length}');
        print('Is fully completed: $isFullyCompleted');

        // If course is completed and not already in completed courses list
        if (isFullyCompleted && !completedCourses.contains(courseTitle)) {
          print('Adding course to completed list: $courseTitle');

          // Add to completed courses and remove from ongoing courses
          completedCourses.add(courseTitle);
          ongoingCourses.remove(courseTitle);

          // Update user document
          await Appwrite_service.databases.updateDocument(
            databaseId: '67c029ce002c2d1ce046',
            collectionId: '67c0cc3600114e71d658',
            documentId: userId,
            data: {
              'completed_courses': completedCourses,
              'ongoing_courses': ongoingCourses,
            },
          );

          print('Updated completed and ongoing courses in database');
          print('Completed courses: $completedCourses');
          print('Ongoing courses: $ongoingCourses');
        }
      }
    } catch (e) {
      print('Error checking course completion: $e');
    }
  }

  Future<void> _markVideoAsCompleted(String courseTitle, String videoId) async {
    try {
      print(
          'Marking video as completed - Course: $courseTitle, Video: $videoId');

      setState(() {
        _isRefreshing = true;
      });

      // Get current user
      final currentUser = await Appwrite_service.account.get();

      // Get user's document
      final userDoc = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        documentId: currentUser.$id,
      );

      // Get completed videos list
      List<String> completedVideos =
          List<String>.from(userDoc.data['completed_videos'] ?? []);

      // Add video to completed list if not already there
      if (!completedVideos.contains(videoId)) {
        completedVideos.add(videoId);
        print('Added video to completed list: $videoId');
      }

      print('Updated completed videos: $completedVideos');

      // Update user document with completed videos
      await Appwrite_service.databases.updateDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        documentId: currentUser.$id,
        data: {
          'completed_videos': completedVideos,
        },
      );

      // Check if course is now completed and update status
      await _checkAndUpdateCourseCompletion(
          currentUser.$id, courseTitle, completedVideos);

      // Refresh course list to update UI
      await _fetchEnrolledCourses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course progress updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error marking video as completed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating progress: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses',
            style: TextStyle(
                color: Color(0xff202244),
                fontFamily: 'Jost',
                fontSize: 21,
                fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for...',
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
                              onTap: () {},
                              child: const Icon(Icons.search,
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
                            _showOngoing = false;
                            enrolledCourses = completedCourses;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              !_showOngoing ? Colors.teal : Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Completed (${completedCourses.length})',
                          style: TextStyle(
                            color: !_showOngoing ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showOngoing = true;
                            enrolledCourses = ongoingCourses;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _showOngoing ? Colors.teal : Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Ongoing (${ongoingCourses.length})',
                          style: TextStyle(
                            color: _showOngoing ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Enrolled Courses List
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : enrolledCourses.isEmpty
                        ? Center(
                            child: Text(
                              _showOngoing
                                  ? 'No ongoing courses'
                                  : 'No completed courses yet',
                              style: const TextStyle(fontSize: 18),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchEnrolledCourses,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: enrolledCourses.length,
                              itemBuilder: (context, index) {
                                final course = enrolledCourses[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      print(
                                          'Tapping on course: ${course['title']}');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            print(
                                                'Building DisplayCourseLessons screen');
                                            return DisplayCourseLessons(
                                              title: course['title'],
                                              courseId: course['courseId'],
                                              onVideoCompleted: (videoId) {
                                                print(
                                                    'Video completed callback received in MyCoursesScreen');
                                                _markVideoAsCompleted(
                                                        course['title'],
                                                        videoId)
                                                    .then((_) {
                                                  print(
                                                      'Course list refreshed after video completion');
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ).then((_) {
                                        print(
                                            'Returned from DisplayCourseLessons');
                                        _fetchEnrolledCourses();
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                          child: Image.network(
                                            course['imagePath'] ??
                                                'https://via.placeholder.com/300x200',
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (BuildContext context,
                                                Object error,
                                                StackTrace? stackTrace) {
                                              print(
                                                  'Error loading image: $error');
                                              return Container(
                                                height: 200,
                                                width: double.infinity,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Container(
                                                height: 200,
                                                width: double.infinity,
                                                color: Colors.grey[200],
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                course['category'],
                                                style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                course['title'],
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.person_outline,
                                                    size: 20,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    course['instructorName'],
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.video_library,
                                                        size: 20,
                                                        color: Colors.grey,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${course['completedVideos']}/${course['videoCount']} Lessons',
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.access_time,
                                                        size: 20,
                                                        color: Colors.grey,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${course['duration']} Mins',
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              LinearProgressIndicator(
                                                value: course[
                                                        'completionPercentage'] /
                                                    100,
                                                backgroundColor:
                                                    Colors.grey[200],
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  course['completionPercentage'] >=
                                                          100
                                                      ? Colors.green
                                                      : Colors.blue,
                                                ),
                                                minHeight: 8,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '${course['completionPercentage'].toStringAsFixed(1)}% Complete',
                                                    style: TextStyle(
                                                      color:
                                                          course['completionPercentage'] >=
                                                                  100
                                                              ? Colors.green
                                                              : Colors.blue,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${course['completedVideos']}/${course['videoCount']} Videos',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
          if (_isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
        ],
      ),
    );
  }
}
