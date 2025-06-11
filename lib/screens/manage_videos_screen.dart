import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:mashrooa_takharog/auth/Appwrite_service.dart';
import 'package:mashrooa_takharog/screens/AddCoursePage.dart';
import 'package:mashrooa_takharog/screens/video_player_screen.dart';
import 'package:video_player/video_player.dart';

class ManageVideosScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle; // Needed for storage path

  const ManageVideosScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  _ManageVideosScreenState createState() => _ManageVideosScreenState();
}

class _ManageVideosScreenState extends State<ManageVideosScreen> {
  final Client client = Client()
    ..setEndpoint('https://cloud.appwrite.io/v1')
    ..setProject('67ac8356002648e5b7e9'); // Replace with your project ID

  late Databases databases;
  static late Storage storage;
  List<Map<String, dynamic>> sections = [];

  File? selectedVideo;
  String? selectedVideoName;
  List<String> sectionDurations = [];


  @override
  void initState() {
    super.initState();
    databases = Databases(client);
    storage = Storage(client);
    fetchSectionsAndVideos();
  }

  Future<void> fetchSectionsAndVideos() async {
    try {
      // ✅ Fetch course details from Appwrite database
      final models.Document course = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: widget.courseId,
      );

      List<String> sectionNames = List<String>.from(course.data['sections']);
      List<String> sectionDurations = List<String>.from(course.data['section_durations']);
      List<String> videoTitlesFromDb = List<String>.from(course.data['videos'] ?? []);

      List<Map<String, dynamic>> fetchedSections = [];

      for (int i = 0; i < sectionNames.length; i++) {
        String rawSection = sectionNames[i];
        String sectionTitle = rawSection.replaceFirst(RegExp(r'^\d+-\s*'), '');
        String duration = (i < sectionDurations.length) ? sectionDurations[i] : "0 Mins";

        // ✅ Fetch all files from Appwrite Storage for this section
        final models.FileList files = await Appwrite_service.storage.listFiles(
          bucketId: '67ac838900066b15fc99',
          queries: [
            Query.startsWith(
              'name',
              '${widget.courseTitle.replaceAll(' ', '_')}/${rawSection.replaceAll(' ', '_')}',
            ),
          ],
        );

        List<Map<String, dynamic>> lessons = [];
        int lessonNumber = 1;

        for (String dbVideoTitle in videoTitlesFromDb) {
          // ✅ Extract filename (e.g., '01- Introduction to Flutter')
          String dbVideoNameOnly = dbVideoTitle.trim().split('/').last.replaceAll('.mp4', '').toLowerCase();

          // ✅ Try to find matching file in storage
          models.File? matchedFile;
          for (var file in files.files) {
            if (!file.name.endsWith('.mp4')) continue;

            String storageFileName = file.name.split('/').last.replaceAll('.mp4', '');
            String normalizedStorage = storageFileName.replaceAll('_', ' ').toLowerCase().trim();

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
      });
    } catch (e) {
      print('❌ Error fetching sections and videos: $e');
    }
  }




  Future<int> getVideoDurationInSeconds(String filePath) async {
    final controller = VideoPlayerController.file(File(filePath));
    await controller.initialize();
    final duration = controller.value.duration;
    await controller.dispose();
    return duration.inSeconds;
  }





  Future<void> pickVideo(int sectionIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      //final durationInSeconds = await getVideoDurationInSeconds(file.path);

      //final durationInMinutes = (durationInSeconds / 60).ceil();

      setState(() {
        selectedVideo = file;
        selectedVideoName = result.files.single.name;
      });

      // 👇 تحديث مدة القسم في قاعدة البيانات
     // await updateSectionDuration(sectionIndex, durationInMinutes);

      // 👇 إعادة حساب وتحديث مدة الدورة الكاملة
      //await updateCourseDuration(widget.courseId);

      // 👇 فتح نافذة إضافة الفيديو
      _showAddVideoDialog(sectionIndex);
    }
  }


  void _showAddVideoDialog(int sectionIndex) async {
    TextEditingController videoTitleController = TextEditingController();
    String? selectedVideoPath;
    VideoPlayerController? _videoController;
    int videoDurationInMinutes = 0;
    bool isLoading = false;

    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null && result.files.single.path != null) {
      selectedVideoPath = result.files.single.path!;
      _videoController = VideoPlayerController.file(File(selectedVideoPath));
      await _videoController.initialize();
      videoDurationInMinutes = (_videoController.value.duration.inSeconds / 60).ceil();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add a new video'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: videoTitleController,
                    decoration: InputDecoration(
                      hintText: "Enter video title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  if (selectedVideoPath != null)
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 100,
                          child: _videoController!.value.isInitialized
                              ? VideoPlayer(_videoController!)
                              : Center(child: CircularProgressIndicator()),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                selectedVideoPath = null;
                                _videoController?.dispose();
                                _videoController = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _videoController?.dispose();
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : TextButton(
                        onPressed: () async {
                          if (videoTitleController.text.isNotEmpty && selectedVideoPath != null) {
                            setState(() => isLoading = true);
                            try {
                              await addVideoToSection(
                                sectionIndex,
                                videoTitleController.text,
                                selectedVideoPath!,
                                videoDurationInMinutes,
                              );
                              _videoController?.dispose();
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                setState(() => isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Failed to add video: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Text('Add'),
                      ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> addVideoToSection(
      int sectionIndex,
      String videoTitle,
      String videoPath,
      int videoDurationInMinutes,
      ) async {
    try {
      if (selectedVideo == null) return;

      // Show uploading snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Uploading video..."),
          duration: Duration(seconds: 6),
        ),
      );

      // Get properly formatted section title with number
      final rawSectionTitle = sections[sectionIndex]['title'];
      final sectionNumber = await _extractSectionNumber(rawSectionTitle);
      final formattedSectionTitle = '$sectionNumber- ${rawSectionTitle.replaceFirst(RegExp(r'^\d+-\s*'), '')}';

      String courseFolder = widget.courseTitle.replaceAll(' ', '_');
      String sectionTitle = formattedSectionTitle.replaceAll(' ', '_');
      String formattedTitle = videoTitle.replaceAll(' ', '_');

      // Get current course document
      var courseDoc = await Appwrite_service.databases.getDocument(
        databaseId: "67c029ce002c2d1ce046",
        collectionId: "67c1c87c00009d84c6ff",
        documentId: widget.courseId,
      );

      List<dynamic> existingVideos = List.from(courseDoc.data['videos'] ?? []);
      List<dynamic> videoDurations = List.from(courseDoc.data['video_durations'] ?? []);

      // Determine the next video number
      int newVideoNumber = 1;
      if (existingVideos.isNotEmpty) {
        String lastVideoTitle = existingVideos.last.toString();
        RegExp regex = RegExp(r"(\d+)-");
        Match? match = regex.firstMatch(lastVideoTitle);
        if (match != null) {
          newVideoNumber = int.parse(match.group(1)!) + 1;
        }
      }

      // Format new video title with numbering
      String formattedIndex = newVideoNumber.toString().padLeft(2, '0');
      String newFormattedTitle = "$formattedIndex- $videoTitle";
      String storagePath = '$courseFolder/$sectionTitle/$formattedIndex-_$formattedTitle.mp4';

      // Upload the video file
      final result = await Appwrite_service.storage.createFile(
        bucketId: '67ac838900066b15fc99',
        fileId: ID.unique(),
        file: InputFile.fromPath(
          path: videoPath,
          filename: storagePath,
        ),
      );

      String videoUrl = 'https://cloud.appwrite.io/v1/storage/buckets/67ac838900066b15fc99/files/${result.$id}/view?project=67ac8356002648e5b7e9';

      // Add video to videos array
      existingVideos.add(newFormattedTitle);
      videoDurations.add(videoDurationInMinutes);

      // Update the course document
      await Appwrite_service.databases.updateDocument(
        databaseId: "67c029ce002c2d1ce046",
        collectionId: "67c1c87c00009d84c6ff",
        documentId: widget.courseId,
        data: {
          'videos': existingVideos,
          'video_durations': videoDurations,
          'upload_status':"pending"
        },
      );

      // Update section duration
      await updateSectionDuration(sectionIndex, videoDurationInMinutes);

      // Update local state
      if (mounted) {
        setState(() {
          sections[sectionIndex]['lessons'].add({
            'number': (sections[sectionIndex]['lessons'].length + 1).toString().padLeft(2, '0'),
            'title': videoTitle,
            'videoId': result.$id,
            'videoUrl': videoUrl,
            'filePath': storagePath,
            'duration': videoDurationInMinutes,
          });
        });
      }

      // Show success message and pop dialog
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Video uploaded successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error uploading video: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to upload video"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

// Helper function to extract or generate section number
  Future<String> _extractSectionNumber(String sectionTitle) async {
    // Check if title already has a number prefix
    final match = RegExp(r'^(\d+)').firstMatch(sectionTitle);
    if (match != null) {
      return match.group(1)!.padLeft(2, '0');
    }

    try {
      // Fetch course document from database
      final models.Document course = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: widget.courseId,
      );

      // Get sections array from database
      List<String> dbSections = List<String>.from(course.data['sections'] ?? []);

      // Search for matching section in database
      for (String dbSection in dbSections) {
        // Extract the title part (after number prefix)
        final dbTitle = dbSection.replaceFirst(RegExp(r'^\d+-\s*'), '').trim();

        if (dbTitle == sectionTitle.trim()) {
          // Extract the number from the database section name
          final numberMatch = RegExp(r'^(\d+)').firstMatch(dbSection);
          if (numberMatch != null) {
            return numberMatch.group(1)!.padLeft(2, '0');
          }
        }
      }

      // If no match found, check if it's a new section being added (not in DB yet)
      for (var section in sections) {
        final existingTitle = section['title'].replaceFirst(RegExp(r'^\d+-\s*'), '').trim();
        if (existingTitle == sectionTitle.trim()) {
          final existingMatch = RegExp(r'^(\d+)').firstMatch(section['title']);
          if (existingMatch != null) {
            return existingMatch.group(1)!.padLeft(2, '0');
          }
        }
      }

      // Fallback: generate new number based on position
      return (sections.length + 1).toString().padLeft(2, '0');
    } catch (e) {
      print('Error fetching section number from DB: $e');
      // Fallback to local sections if DB fails
      for (var section in sections) {
        if (section['title'].contains(sectionTitle)) {
          final existingMatch = RegExp(r'^(\d+)').firstMatch(section['title']);
          if (existingMatch != null) {
            return existingMatch.group(1)!.padLeft(2, '0');
          }
        }
      }
      return (sections.length + 1).toString().padLeft(2, '0');
    }
  }
  Future<void> updateSectionDuration(int sectionIndex, int additionalMinutes) async {
    try {
      // ✅ Get current course data
      final models.Document course = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: widget.courseId,
      );

      List<String> sectionDurations = List<String>.from(course.data['section_durations']);

      // ✅ Ensure section duration exists in the array
      while (sectionDurations.length <= sectionIndex) {
        sectionDurations.add("0 Mins");
      }

      // ✅ Update section duration
      int currentDuration = int.parse(sectionDurations[sectionIndex].split(' ')[0]);
      int updatedDuration = currentDuration + additionalMinutes;
      sectionDurations[sectionIndex] = "$updatedDuration mins";

      // ✅ Update database
      await Appwrite_service.databases.updateDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: widget.courseId,
        data: {
          'section_durations': sectionDurations,
        },
      );

// ✅ Recalculate total course duration
      int totalDuration = sectionDurations.fold(0, (sum, durationString) {
        int duration = int.tryParse(durationString.split(' ')[0]) ?? 0;
        return sum + duration;
      });

// ✅ Update courseDuration_inMins field
      await Appwrite_service.databases.updateDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: widget.courseId,
        data: {
          'courseDuration_inMins': totalDuration,
        },
      );


    } catch (e) {
      print("❌ Error updating section duration: $e");
    }
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
      body: sections.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sections.length,
              itemBuilder: (context, sectionIndex) {
                final section = sections[sectionIndex];
                final lessons = section['lessons'] as List;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.blue),
                            onPressed: () => pickVideo(sectionIndex),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDeleteSection(sectionIndex),
                          ),
                          SizedBox(width: 8,),
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: Colors.blue,
                            child: Text(
                              (sectionIndex + 1).toString(), // Dynamic number
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 5,),
                          Text(
                            section['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            section['duration'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // List of lessons
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: lessons.length,
                      itemBuilder: (context, lessonIndex) {
                        final lesson = lessons[lessonIndex];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: ListTile(
                            leading: Text(
                              lesson['number'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xff0961F5),
                              ),
                            ),
                            title: Text(
                              lesson['title'].substring(4), // Remove '01-'
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Edit Button
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                  onPressed: () {
                                    showEditVideoDialog(
                                        context,
                                        lesson['title'],
                                        lesson['videoId'],
                                        widget.courseTitle,
                                        section['title'],
                                        widget.courseId,
                                            (newTitle) {
                                          setState(() {
                                            lesson['title'] = newTitle;
                                          });
                                        }

                                    );
                                  },
                                ),

                                // Delete Button (with full sync)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final lesson = lessons[lessonIndex];
                                    await handleDeleteVideo(
                                      courseId: widget.courseId,
                                      videoPath: lesson['filePath'],
                                      sectionIndex: sectionIndex,
                                      fileId: lesson['videoId'],
                                      lessonIndex: lessonIndex,
                                      videoDuration: lesson['duration'] is int
                                          ? lesson['duration']
                                          : int.tryParse(lesson['duration'].toString()) ?? 0,
                                    );
                                  },
                                ),



                                // Play icon
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200],
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Color(0xff0961F5),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),

                            // Play video
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(
                                    lessonTitle: lesson['title'] ?? '',
                                    videoUrl: lesson['videoUrl'] ?? '',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          // Bottom Add Section Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 55,
              margin: const EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                onPressed: () => _showAddSectionDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                ),
                child: const Text(
                  "Add a New Section",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSection(int sectionIndex) {
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Delete Section"),
              content: const Text("Are you sure you want to delete this section and all its videos?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      )
                    : TextButton(
                        onPressed: () async {
                          setState(() => isLoading = true);
                          Navigator.pop(context);
                          await handleDeleteSection(sectionIndex);
                        },
                        child: const Text("Delete", style: TextStyle(color: Colors.red)),
                      ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> handleDeleteSection(int sectionIndex) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Deleting section...")),
      );

      // 1. Get current course document
      final doc = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: widget.courseId,
      );

      // 2. Extract all arrays we need to modify
      List<dynamic> sectionsList = List.from(doc.data['sections'] ?? []);
      List<dynamic> sectionDurations = List.from(doc.data['section_durations'] ?? []);
      List<dynamic> videos = List.from(doc.data['videos'] ?? []);
      List<dynamic> videoDurations = List.from(doc.data['video_durations'] ?? []);

      // 3. Get section info before deletion
      final sectionTitle = sectionsList[sectionIndex].toString();
      final deletedSectionFolder =
          '${widget.courseTitle.replaceAll(' ', '_')}/${sectionTitle.replaceAll(' ', '_')}';

      // 🔍 List files in this section's folder
      final filesToDelete = await Appwrite_service.storage.listFiles(
        bucketId: '67ac838900066b15fc99',
        queries: [Query.startsWith('name', deletedSectionFolder)],
      );

      // Extract normalized video names from Storage
      final Set<String> videoNamesFromStorage = filesToDelete.files.map((file) {
        final rawName = file.name.split('/').last; // Just the filename
        final nameWithoutExtension = rawName.replaceAll('.mp4', '');
        return nameWithoutExtension.replaceAll('_', ' ').trim(); // Normalize
      }).toSet();

      // 🔁 Now match and remove from videos + durations
      List<int> indexesToRemove = [];
      for (int i = 0; i < videos.length; i++) {
        final dbVideoName = videos[i].toString().trim();
        if (videoNamesFromStorage.contains(dbVideoName)) {
          indexesToRemove.add(i);
        }
      }

      for (int i = indexesToRemove.length - 1; i >= 0; i--) {
        final index = indexesToRemove[i];
        videos.removeAt(index);
        if (index < videoDurations.length) {
          videoDurations.removeAt(index);
        }
      }



      // 4. Update database arrays
      sectionsList.removeAt(sectionIndex);
      sectionDurations.removeAt(sectionIndex);



      // 6. Recalculate total course duration
      int totalCourseDuration = 0;
      for (var duration in sectionDurations) {
        final mins = int.tryParse(duration.toString().split(' ')[0]) ?? 0;
        totalCourseDuration += mins;
      }

      // 7. Update DB
      await Appwrite_service.databases.updateDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: widget.courseId,
        data: {
          'sections': sectionsList,
          'section_durations': sectionDurations,
          'videos': videos,
          'video_durations': videoDurations,
          'courseDuration_inMins': totalCourseDuration,
        },
      );

// 8. Delete section files from Storage


      for (final file in filesToDelete.files) {
        await Appwrite_service.storage.deleteFile(
          bucketId: '67ac838900066b15fc99',
          fileId: file.$id,
        );
      }


      // 10. Update UI
      if (mounted) {
        setState(() {
          sections.removeAt(sectionIndex);
          for (int i = sectionIndex; i < sections.length; i++) {
            final currentTitle = sections[i]['title'];
            if (currentTitle.contains('-')) {
              final parts = currentTitle.split('-');
              final newTitleNum = (i + 1).toString().padLeft(2, '0');
              sections[i]['title'] = '$newTitleNum-${parts[1]}';
            }
          }
        });
      }

      // 11. Show success
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Section deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error deleting section: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete section: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }












  Future<void> updateSectionAndCourseDurations({
    required String courseId,
    required int updatedSectionIndex,
    required int updatedSectionDuration,
  }) async {
    try {
      final doc = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: courseId,
      );

      List<dynamic> durations = List.from(doc.data['section_durations'] ?? []);
      durations[updatedSectionIndex] = '$updatedSectionDuration mins';

      // ⏱️ إعادة حساب المجموع الكامل
      int totalDuration = durations.fold<int>(0, (sum, durationStr) {
        final number = int.tryParse(durationStr.toString().split(' ').first) ?? 0;
        return sum + number;
      });

      await Appwrite_service.databases.updateDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: courseId,
        data: {
          'section_durations': durations,
          'courseDuration_inMins': totalDuration,
        },
      );
    } catch (e) {
      print("❌ Failed to update durations: $e");
    }
  }


  Future<void> updateVideoTitleInDatabase({
    required String courseId,
    required String oldTitle,
    required String newTitle,
  }) async {
    try {
      final doc = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: courseId,
      );

      List<String> videos = List<String>.from(doc.data['videos']);
      int index = videos.indexWhere((title) => title == oldTitle);
      if (index != -1) {
        videos[index] = newTitle;
        await Appwrite_service.databases.updateDocument(
          databaseId: '67c029ce002c2d1ce046',
          collectionId: '67c1c87c00009d84c6ff',
          documentId: courseId,
          data: {'videos': videos},
        );
      }
    } catch (e) {
      print("❌ Error updating video title in DB: $e");
      throw e;
    }
  }



  void showEditVideoDialog(
      BuildContext context,
      String oldVideoTitle,
      String fileId,
      String courseTitle,
      String sectionTitle,
      String courseId,
      Function(String) onRenameSuccess,
      ) {
    final TextEditingController _titleController =
    TextEditingController(text: oldVideoTitle.replaceFirst(RegExp(r'^\d+-\s*'), ''));
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit video's title"),
              content: TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: "Enter the new title"),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : TextButton(
                        onPressed: () async {
                          String newTitlePart = _titleController.text.trim();
                          if (newTitlePart.isNotEmpty) {
                            try {
                              setState(() => isLoading = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Renaming video, please wait..."),
                                  backgroundColor: Colors.blueAccent,
                                  duration: Duration(seconds: 5),
                                ),
                              );

                              final numberPrefix = RegExp(r'^(\d+)-').firstMatch(oldVideoTitle)?.group(1) ?? '01';
                              final newFullTitle = '$numberPrefix- $newTitlePart';

                              await renameVideo(
                                courseId: courseId,
                                oldVideoTitle: oldVideoTitle,
                                newVideoTitle: newTitlePart,
                                courseTitle: courseTitle,
                                sectionTitle: sectionTitle,
                                fileId: fileId,
                              );

                              if (context.mounted) {
                                await fetchSectionsAndVideos();
                                onRenameSuccess(newFullTitle);
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Video has been renamed successfully!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              print("❌ Error renaming video: $e");
                              if (context.mounted) {
                                setState(() => isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Failed to rename video: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: const Text("Edit"),
                      ),
              ],
            );
          },
        );
      },
    );
  }





  Future<void> renameVideo({
    required String courseId,
    required String oldVideoTitle,
    required String newVideoTitle,
    required String courseTitle,
    required String sectionTitle,
    required String fileId,
  }) async {
    try {
      const String bucketId = '67ac838900066b15fc99';

      final formattedCourse = courseTitle.replaceAll(' ', '_');
      final formattedSection = sectionTitle.replaceAll(' ', '_');

      // Detect section number
      String detectedSectionNumber = '01';
      try {
        final doc = await Appwrite_service.databases.getDocument(
          databaseId: '67c029ce002c2d1ce046',
          collectionId: '67c1c87c00009d84c6ff',
          documentId: courseId,
        );

        List<dynamic> sections = List.from(doc.data['sections'] ?? []);
        for (var section in sections) {
          final dbTitle = section.toString().replaceFirst(RegExp(r'^\d+-\s*'), '').trim();
          if (dbTitle == sectionTitle.trim()) {
            final match = RegExp(r'^(\d+)').firstMatch(section.toString());
            if (match != null) {
              detectedSectionNumber = match.group(1)!.padLeft(2, '0');
              break;
            }
          }
        }
      } catch (e) {
        print("⚠️ Error detecting section number: $e");
      }

      // Extract number prefix from old title
      final prefix = RegExp(r'^(\d+)').firstMatch(oldVideoTitle)?.group(1) ?? '01';
      final numberedPrefix = '$prefix-';
      final fullDisplayTitle = '$numberedPrefix $newVideoTitle';  // DB Title
      final fileStorageName = '${numberedPrefix}_${newVideoTitle.replaceAll(' ', '_')}.mp4'; // Storage name
      final storagePath = '$formattedCourse/${detectedSectionNumber}-_$formattedSection/$fileStorageName';

      // Fetch existing videos
      final doc = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: courseId,
      );

      List<dynamic> videos = List.from(doc.data['videos'] ?? []);

      // Keep index for proper order replacement
      final index = videos.indexWhere((v) => v.toString().endsWith(oldVideoTitle));
      if (index == -1) {
        print("❌ Old video title not found in videos array.");
        return;
      }

      // Download old file
      final fileBytes = await Appwrite_service.storage.getFileView(
        bucketId: bucketId,
        fileId: fileId,
      );

      // Upload new file
      await Appwrite_service.storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: fileBytes,
          filename: storagePath,
        ),
      );

      // Replace at the same index to keep order
      videos[index] = fullDisplayTitle;

      await Appwrite_service.databases.updateDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: courseId,
        data: {'videos': videos},
      );

      // Delete old file
      await Appwrite_service.storage.deleteFile(
        bucketId: bucketId,
        fileId: fileId,
      );
    } catch (e) {
      print('❌ Error in renameVideo: $e');
    }
  }






  void _showAddSectionDialog(BuildContext context) {
    TextEditingController _sectionTitleController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add a New Section"),
              content: TextField(
                controller: _sectionTitleController,
                decoration: InputDecoration(
                  hintText: "Enter the section title",
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: Colors.red)),
                ),
                isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : TextButton(
                        onPressed: () async {
                          String sectionTitle = _sectionTitleController.text.trim();
                          if (sectionTitle.isNotEmpty) {
                            setState(() => isLoading = true);
                            await addSection(sectionTitle);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: Text("Add", style: TextStyle(color: Colors.blue)),
                      ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> addSection(String sectionTitle) async {
    try {
      final document = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: widget.courseId,
      );

      List<dynamic> sectionNames = List.from(document.data['sections'] ?? []);
      List<dynamic> sectionDurations = List.from(document.data['section_durations'] ?? []);

      // Format section title: "01- Your Title"
      int highestNumber = 0;
      for (var section in sectionNames) {
        final match = RegExp(r'^(\d+)').firstMatch(section.toString());
        if (match != null) {
          int currentNumber = int.parse(match.group(1)!);
          if (currentNumber > highestNumber) {
            highestNumber = currentNumber;
          }
        }
      }

      // Calculate new section number (highest + 1)
      int newSectionNumber = highestNumber + 1;
      String formattedSectionNumber = newSectionNumber.toString().padLeft(2, '0');
      String newSectionTitle = "$formattedSectionNumber- $sectionTitle";

      sectionNames.add(newSectionTitle);
      sectionDurations.add("0 mins");

      await Appwrite_service.databases.updateDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: widget.courseId,
        data: {
          'sections': sectionNames,
          'section_durations': sectionDurations,
        },
      );

      setState(() {
        sections.add(buildSectionModel(newSectionTitle, "0 mins", []));
      });



      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Section added successfully!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      print("❌ Failed to add section: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Section failed to be added!"), backgroundColor: Colors.red),
      );
    }
  }

  Map<String, dynamic> buildSectionModel(String title, String duration, List<dynamic> lessons) {
    return {
      'title': title,
      'duration': duration,
      'lessons': lessons,
    };
  }

  Future<void> updateCourseDuration(String courseId) async {
    try {
      final document = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: courseId,
      );

      List<String> durations = List<String>.from(document.data['section_durations'] ?? []);

      int totalMinutes = durations.fold(0, (sum, duration) {
        final match = RegExp(r"(\d+)\s+mins").firstMatch(duration);
        return sum + (match != null ? int.parse(match.group(1)!) : 0);
      });

      await Appwrite_service.databases.updateDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: courseId,
        data: {
          'courseDuration_inMins': totalMinutes,
        },
      );
    } catch (e) {
      print("❌ Failed to update course total duration: $e");
    }
  }




  Future<void> handleDeleteVideo({
    required String courseId,
    required String videoPath,
    required int sectionIndex,
    required String fileId,
    required int lessonIndex,
    required int? videoDuration,
  }) async {
    try {
      // 1. Get current course document
      final doc = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: courseId,
      );

      // 2. Extract all arrays we need to modify
      List<dynamic> videos = List.from(doc.data['videos'] ?? []);
      List<dynamic> videoDurations = List.from(doc.data['video_durations'] ?? []);
      List<dynamic> sectionDurations = List.from(doc.data['section_durations'] ?? []);

      // 3. Convert video path to match the format in videos array
      // Storage path format: courseName/01-sectionName/01-videoName.mp4
      // Videos array format: "01- videoName" (with space after dash)
      final pathParts = videoPath.split('/');
      final videoFileName = pathParts.last.replaceAll('.mp4', '');
      final videoNumber = videoFileName.split('-').first.padLeft(2, '0');
      final videoName = videoFileName.substring(videoNumber.length + 1).replaceAll('_', ' ').trim();
      final videoTitleInArray = '$videoNumber- $videoName';

      // Debug prints to verify the matching
      print('Looking for video in array: $videoTitleInArray');
      print('Available videos in array: $videos');

      // 4. Find the video in the array (case insensitive and trim whitespace)
      var videoIndex = videos.indexWhere((v) =>
      v.toString().trim().toLowerCase() == videoTitleInArray.trim().toLowerCase());

      if (videoIndex == -1) {
        // Try alternative matching if exact match fails
        final alternativeMatch = videos.indexWhere((v) =>
            v.toString().trim().toLowerCase().contains(videoName.toLowerCase()));

        if (alternativeMatch == -1) {
          print('Could not find video in array. Full path: $videoPath');
          print('Processed title: $videoTitleInArray');
          print('Available videos: $videos');
          throw Exception('Video not found in database array. Please check the video title format.');
        }
        videoIndex = alternativeMatch;
      }

      // Store the duration before removing for section calculation
      final durationToRemove = videoDurations.length > videoIndex
          ? (videoDurations[videoIndex] is int)
          ? videoDurations[videoIndex]
          : int.tryParse(videoDurations[videoIndex].toString()) ?? 0
              : videoDuration ?? 0;

          // Remove from arrays
          videos.removeAt(videoIndex);
      if (videoIndex < videoDurations.length) {
        videoDurations.removeAt(videoIndex);
      }

      // 5. Update section duration
      if (sectionIndex < sectionDurations.length) {
        final currentDurationStr = sectionDurations[sectionIndex].toString();
        final currentDuration = int.tryParse(currentDurationStr.split(' ')[0]) ?? 0;
        final newDuration = currentDuration - durationToRemove;
        sectionDurations[sectionIndex] = '${newDuration > 0 ? newDuration : 0} mins';
      }

      // 6. Calculate new total course duration
      int totalCourseDuration = 0;
      for (var duration in sectionDurations) {
        final mins = int.tryParse(duration.toString().split(' ')[0]) ?? 0;
        totalCourseDuration += mins;
      }

      // 7. Update the document in database
      await Appwrite_service.databases.updateDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: courseId,
        data: {
          'videos': videos,
          'video_durations': videoDurations,
          'section_durations': sectionDurations,
          'courseDuration_inMins': totalCourseDuration,
        },
      );

      // 8. Update UI state before storage operation
      if (mounted) {
        setState(() {
          sections[sectionIndex]['lessons'].removeAt(lessonIndex);
          sections[sectionIndex]['duration'] = sectionDurations[sectionIndex];
        });
      }

      // 9. Only after all DB updates succeed, delete from storage
      await Appwrite_service.storage.deleteFile(
        bucketId: '67ac838900066b15fc99',
        fileId: fileId,
      );

      // 10. Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Video deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error deleting video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete video: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Re-throw to allow calling code to handle the error
      rethrow;
    }
  }


}
