import 'package:appwrite/appwrite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import 'package:mashrooa_takharog/screens/video_player_screen.dart';
import '../auth/Appwrite_service.dart';
import '../widgets/customElevatedBtn.dart';
import 'ReviewsScreen.dart';

class DisplayCourseLessons extends StatefulWidget {

  final String title;
  final String courseId;
  final Function(String)? onVideoCompleted;

  const DisplayCourseLessons({
    super.key,
    required this.title,
    required this.courseId,
    this.onVideoCompleted,
  });

  @override
  State<DisplayCourseLessons> createState() => _DisplayCourseLessonsState();
}

class _DisplayCourseLessonsState extends State<DisplayCourseLessons> {
  List<Map<String, dynamic>> sections = [];


  @override
  void initState() {
    super.initState();
    fetchSectionsAndVideos();
  }

  Future<void> fetchSectionsAndVideos() async {
    try {
      // ✅ Fetch course details from Appwrite database
      final course = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: widget.courseId,
      );

      List<String> sectionNames = List<String>.from(course.data['sections']);
      List<String> sectionDurations =
      List<String>.from(course.data['section_durations']);
      List<String> videoTitlesFromDb =
      List<String>.from(course.data['videos'] ?? []);

      List<Map<String, dynamic>> fetchedSections = [];

      for (int i = 0; i < sectionNames.length; i++) {
        String rawSection = sectionNames[i];
        String sectionTitle = rawSection.replaceFirst(RegExp(r'^\d+-\s*'), '');
        String duration =
        (i < sectionDurations.length) ? sectionDurations[i] : "0 Mins";

        // ✅ Fetch all files from Appwrite Storage for this section
        final files = await Appwrite_service.storage.listFiles(
          bucketId: '67ac838900066b15fc99',
          queries: [
            Query.startsWith(
              'name',
              '${widget.title.replaceAll(' ', '_')}/${rawSection.replaceAll(' ', '_')}',
            ),
          ],
        );

        List<Map<String, dynamic>> lessons = [];
        int lessonNumber = 1;

        for (String dbVideoTitle in videoTitlesFromDb) {
          // ✅ Remove first 4 characters like "01- "
          String dbVideoTrimmed = dbVideoTitle.length > 4
              ? dbVideoTitle.substring(4)
              : dbVideoTitle;
          String dbVideoNameOnly = dbVideoTrimmed
              .trim()
              .split('/')
              .last
              .replaceAll('.mp4', '')
              .toLowerCase();
          String normalizedDbVideo =
          dbVideoNameOnly.replaceAll('_', ' ').toLowerCase();

          // ✅ Try to find matching file in storage
          models.File? matchedFile;
          for (var file in files.files) {
            if (!file.name.endsWith('.mp4')) continue;

            String storageFileName =
            file.name.split('/').last.replaceAll('.mp4', '');

            // ✅ Remove first 4 characters from storage filename
            String trimmedStorageName = storageFileName.length > 4
                ? storageFileName.substring(4)
                : storageFileName;
            String normalizedStorage =
            trimmedStorageName.replaceAll('_', ' ').toLowerCase().trim();

            print('🔍 Comparing:');
            print('   DB: $normalizedDbVideo');
            print('   Storage: $normalizedStorage');
            if (normalizedStorage == dbVideoNameOnly) {
              matchedFile = file;
              break;
            }
          }

          if (matchedFile != null) {
            String videoUrl =
                'https://cloud.appwrite.io/v1/storage/buckets/67ac838900066b15fc99/files/${matchedFile.$id}/view?project=67ac8356002648e5b7e9';

            lessons.add({
              'number': lessonNumber.toString().padLeft(2, '0'),
              'title': dbVideoTitle.replaceAll('.mp4', ''),
              'videoId': matchedFile.$id,
              'videoUrl': videoUrl,
              'filePath': matchedFile.name,
            });

            lessonNumber++;
          } else {
            print('⚠️ No match found for: $dbVideoTitle');
          }
        }

        fetchedSections.add({
          'title': sectionTitle,
          'duration': duration,
          'lessons': lessons,
        });
      }

      setState(() {
        sections = fetchedSections;
      });
    } catch (e) {
      print('❌ Error fetching sections and videos: $e');
    }
  }

  void _handleVideoCompletion(String videoId) {
    if (widget.onVideoCompleted != null) {
      print('Video completion triggered for ID: $videoId');
      widget.onVideoCompleted!(videoId);
      // Show completion message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video marked as completed!'),
          backgroundColor: Colors.green,
        ),
      );
      // Pop back to MyCoursesScreen which will trigger a refresh
      Navigator.pop(context);
    }
  }

  Future<String> getAppwriteUserID() async{

    final currentUser = await Appwrite_service.account.get();
    return currentUser.$id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Course Lessons',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
    children: [
    Padding(
    padding: const EdgeInsets.only(bottom: 80.0), // leave space for the button
    child: ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: sections.length,
    itemBuilder: (context, sectionIndex) {
    final section = sections[sectionIndex];
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text(
    section['title'],
    style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    ),
    ),
    Text(
    section['duration'],
    style: TextStyle(
    color: Colors.grey[600],
    fontSize: 14,
    ),
    ),
    ],
    ),
    const SizedBox(height: 20),
    ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: (section['lessons'] as List).length,
    itemBuilder: (context, lessonIndex) {
    final lesson = section['lessons'][lessonIndex];
    return _buildLessonTile(
    lesson['number'],
    lesson['title'].toString().substring(4),
    lesson['videoUrl'],
    );
    },
    ),
    ],
    );
    },
    ),
    ),

    // 🔳 Floating button at the bottom center
    Positioned(
    bottom: 7,
    left: 0,
    right: 0,
    child: Center(
    child: CustomElevatedBtn(
    btnDesc: 'Rate/Write a Review',
    btnWidth: 290,
    onPressed: () async {
      String userId = await getAppwriteUserID();
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(
    builder: (context) => ReviewsScreen(courseId: widget.courseId, userId:userId ),
    ),
    );
    },
    ),
    ),
    ),
    ],
    ),

    );
  }

  Widget _buildLessonTile(String number, String title, String videoUrl) {
    // استخراج معرف الفيديو من الURL
    String videoId = videoUrl.split('/files/')[1].split('/view')[0];

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setTileState) {
        return FutureBuilder<bool>(
          future: _checkVideoCompletion(videoId),
          builder: (context, snapshot) {
            bool isCompleted = snapshot.data ?? false;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(
                      videoUrl: videoUrl,
                      lessonTitle: title,
                      isAlreadyCompleted: isCompleted,
                      onVideoCompleted: () => _handleVideoCompletion(videoId),
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green : Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white)
                            : Text(
                          number,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isCompleted ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                    Icon(Icons.play_circle_outline,
                        color: isCompleted ? Colors.green : Colors.blue),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to check video completion status
  Future<bool> _checkVideoCompletion(String videoId) async {
    try {
      final currentUser = await Appwrite_service.account.get();
      final userDoc = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        documentId: currentUser.$id,
      );
      List<String> completedVideos =
      List<String>.from(userDoc.data['completed_videos'] ?? []);
      return completedVideos.contains(videoId);
    } catch (e) {
      print('Error checking video completion status: $e');
      return false;
    }
  }
}