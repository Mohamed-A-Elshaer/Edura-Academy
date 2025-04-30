import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import 'package:mashrooa_takharog/screens/video_player_screen.dart';
import '../auth/Appwrite_service.dart';

class AdminCoursePreviewScreen extends StatefulWidget {
  final String title;
  final String courseId;
  final String courseCategory;
  final String courseImagePath;

  const AdminCoursePreviewScreen({
    super.key,
    required this.title,
    required this.courseId,
    required this.courseCategory,
    required this.courseImagePath,
  });

  @override
  State<AdminCoursePreviewScreen> createState() =>
      _AdminCoursePreviewScreenState();
}

class _AdminCoursePreviewScreenState extends State<AdminCoursePreviewScreen> {
  List<Map<String, dynamic>> sections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSectionsAndVideos();
  }

  Future<void> fetchSectionsAndVideos() async {
    try {
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

          models.File? matchedFile;
          for (var file in files.files) {
            if (!file.name.endsWith('.mp4')) continue;
            String storageFileName =
                file.name.split('/').last.replaceAll('.mp4', '');

            // Remove first 4 characters from storage filename
            String trimmedStorageName = storageFileName.length > 4
                ? storageFileName.substring(4)
                : storageFileName;
            String normalizedStorage =
                trimmedStorageName.replaceAll('_', ' ').toLowerCase().trim();

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
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching course content: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview: ${widget.title}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: sections.length,
              itemBuilder: (context, sectionIndex) {
                final section = sections[sectionIndex];
                return ExpansionTile(
                  title: Text(
                    '${sectionIndex + 1}. ${section['title']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Duration: ${section['duration']}'),
                  children: [
                    ...section['lessons'].map<Widget>((lesson) {
                      return ListTile(
                        leading: const Icon(Icons.play_circle_outline),
                        title: Text(lesson['title']),
                        subtitle: Text('Lesson ${lesson['number']}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(
                                videoUrl: lesson['videoUrl'],
                                lessonTitle: lesson['title'],
                                isAlreadyCompleted: false,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ],
                );
              },
            ),
    );
  }
}
