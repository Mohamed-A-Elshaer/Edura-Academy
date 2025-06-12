import 'dart:convert';
import 'dart:io' as file_conflict;
import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mashrooa_takharog/screens/InstructorNavigatorScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:appwrite/models.dart' as appwrite_models;

class AddCoursePage extends StatefulWidget {
  @override
  AddCoursePageState createState() => AddCoursePageState();
}

class AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  static List<Map<String, dynamic>> sections = [];
  List<String> sectionDurations = [];
  List<int> videoDurations = [];
  late Client appwriteClient;
  late Databases databases;
  late Storage storage;
  late Account account;
  String instructorId = "";
  String instructorName = "";
  bool _isPublishing = false;
  String? coverImageUrl;
  final List<String> categories = [
    'Graphic Design',
    'Arts & Humanities',
    'Cooking',
    'SEO & Marketing',
    'Programming',
    'Finance and Accounting',
    'Personal Development',
    'Office Productivity',
  ];

  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _initializeAppwrite();
  }

  void _initializeAppwrite() async {
    appwriteClient = Client()
        .setEndpoint("https://cloud.appwrite.io/v1")
        .setProject("67ac8356002648e5b7e9");

    databases = Databases(appwriteClient);
    storage = Storage(appwriteClient);
    account = Account(appwriteClient);

    await _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      appwrite_models.User user = await account.get();
      String userId = user.$id;

      var response = await databases.getDocument(
        databaseId: "67c029ce002c2d1ce046",
        collectionId: "67c0cc3600114e71d658",
        documentId: userId,
      );

      setState(() {
        instructorId = userId;
        instructorName = response.data['name'];
      });
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  Future<void> _publishCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPublishing = true;
    });
    List<String> existingCourseTitles = await _fetchExistingCourseTitles();

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a course cover image!"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isPublishing = false;
      });
      return;
    }

    if (sections.isEmpty || sections.every((s) => s['videos'].isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add at least one section with videos!")),
      );
      setState(() {
        _isPublishing = false;
      });
      return;
    }

    String courseTitle = _titleController.text.trim();
    String price = _priceController.text.trim();
    String category = _categoryController.text.trim();
    String description = _descriptionController.text.trim();
    String courseFolder =
        courseTitle.replaceAll(" ", "_").toLowerCase(); // Simulated folder
    String bucketId = "67ac838900066b15fc99";

    if (existingCourseTitles.contains(courseTitle)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Course Name is already used!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      setState(() {
        _isPublishing = false;
      });
      return;
    }

    List<String> videoTitles = [];

    // 1️⃣ **احسب عدد الفيديوهات قبل الرفع لترقيمها بشكل صحيح**
    List<Map<String, dynamic>> allVideos = [];
    for (var section in sections) {
      for (var video in section['videos']) {
        allVideos.add({
          'section': section['title'],
          'video': video,
        });
      }
    }

    try {
      // Get temporary directory for file operations
      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;

      // Upload course cover image to Supabase
      try {
        final supabase = Supabase.instance.client;
        final courseTitleFormatted = courseTitle.replaceAll(' ', '_');
        final coverFilePath = "$courseTitleFormatted/course_cover.jpg";

        // Read the image file
        final fileBytes = await _selectedImage!.readAsBytes();
        final fileExtension = _selectedImage!.path.split('.').last.toLowerCase();

        // Upload the image
        await supabase.storage
            .from('profiles')
            .uploadBinary(
              coverFilePath,
              fileBytes,
              fileOptions: FileOptions(
                upsert: true,
                contentType: 'image/$fileExtension',
              ),
            );

        String publicURL = supabase.storage.from('profiles').getPublicUrl(coverFilePath);
        publicURL = Uri.parse(publicURL).replace(queryParameters: {
          't': DateTime.now().millisecondsSinceEpoch.toString()
        }).toString();

        coverImageUrl = publicURL;
      } catch (e) {
        print("❌ Failed to upload image to Supabase: $e");
        throw Exception('Failed to upload course cover image: $e');
      }

      // Upload videos to Appwrite
      for (int i = 0; i < allVideos.length; i++) {
        var sectionTitle = allVideos[i]['section'];
        var video = allVideos[i]['video'];

        String sectionFolder = sectionTitle.replaceAll(" ", "_").toLowerCase();
        String originalVideoPath = video['videoPath'];
        
        // Create a temporary copy of the video file
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${originalVideoPath.split('/').last}';
        final tempVideoPath = '$tempPath/$fileName';
        final tempVideoFile = File(tempVideoPath);
        
        // Copy the video file to our temporary directory
        await tempVideoFile.writeAsBytes(await File(originalVideoPath).readAsBytes());

        String videoFileName = video['title'].replaceAll(" ", "_").toLowerCase();
        String formattedIndex = (i + 1).toString().padLeft(2, '0');
        String formattedTitle = "$formattedIndex- ${video['title']}";
        videoTitles.add(formattedTitle);
        
        String filePath = "$courseFolder/$sectionFolder/${formattedIndex}-_$videoFileName.mp4";

        try {
          var response = await storage.createFile(
            bucketId: bucketId,
            fileId: ID.unique(),
            file: InputFile.fromPath(path: tempVideoPath, filename: filePath),
          );

          video['videoUrl'] = response.$id;
          
          // Clean up the temporary file
          await tempVideoFile.delete();
        } catch (e) {
          print("❌ Failed to upload video: $e");
          throw Exception('Failed to upload video: $e');
        }
      }

      // 3- **Store Course Data in Appwrite Database**
      await databases.createDocument(
          databaseId: "67c029ce002c2d1ce046",
          collectionId: "67c1c87c00009d84c6ff",
          documentId: ID.unique(),
          data: {
            "title": courseTitle,
            "price": double.parse(price),
            "category": selectedCategory,
            "description": description,
            "instructor_id": instructorId,
            "instructor_name": instructorName,
            "courseDuration_inMins": calculateTotalCourseDuration(),
            "video_folder_id": courseFolder,
            "sections": sections.map((s) => s['title']).toList(),
            'section_durations': sectionDurations,
            "videos": videoTitles,
            "video_durations": videoDurations,
            "request_type":"uploading_request",
            "upload_status": "pending",

            

          });

      // ✅ **Success Message**
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(

            content: Text(
                "Course Published Successfully! It is now pending admin approval."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4)),

           
            

      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => InstructorNavigatorScreen()),
      );
    } catch (e) {
      print("Error publishing course: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to Publish Course"),
            backgroundColor: Colors.red),
      );
      setState(() {
        _isPublishing = false;
      });
    }
  }

  Future<List<String>> _fetchExistingCourseTitles() async {
    List<String> titles = [];
    try {
      var response = await databases.listDocuments(
        databaseId: "67c029ce002c2d1ce046",
        collectionId: "67c1c87c00009d84c6ff",
      );

      for (var document in response.documents) {
        titles.add(document.data['title']);
      }
    } catch (e) {
      print("Error fetching course titles: $e");
    }
    return titles;
  }

  static int calculateSectionDuration(List<dynamic> videos) {
    // ✅ Change Here
    int sectionDuration = 0;

    List<Map<String, dynamic>> videosList = videos
        .map((video) => Map<String, dynamic>.from(video))
        .toList(); // ✅ Change Here

    for (var video in videosList) {
      sectionDuration +=
          int.tryParse(video["duration"]?.split(" ")[0] ?? "0") ?? 0;
    }

    return sectionDuration;
  }

  static int calculateTotalCourseDuration() {
    int totalDuration = 0;

    for (var section in sections) {
      int sectionDuration = calculateSectionDuration(
          section["videos"] as List<dynamic>); // ✅ Change Here
      totalDuration += sectionDuration;
    }

    return totalDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => InstructorNavigatorScreen()));
          },
        ),
        title: Text(
          'Create New Course',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCard(
                    title: 'Add a New Course Cover',
                    child: Column(
                      children: [
                        if (_selectedImage != null) // Show image if selected
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImage! as file_conflict.File,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.cancel, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        SizedBox(height: 12),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(Icons.add_a_photo, color: Colors.white),
                            label: Text(
                              'Add a new image',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              // Use MediaQuery to make the size relative to screen width
                              minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.4, // 40% of screen width
                                50, // Fixed height, or adjust as needed
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              backgroundColor: Colors.blue[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildCard(
                    title: 'Course Information',
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: _inputDecoration(
                            'Course Title',
                            'Enter course title',
                            Icons.title,
                          ),
                          validator: (value) => value!.trim().isEmpty
                              ? "Course title is required"
                              : null,
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                decoration: _inputDecoration(
                                  'Price (\$)',
                                  'Enter price',
                                  Icons.attach_money,
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.trim().isEmpty)
                                    return "Price is required";
                                  if (double.tryParse(value) == null)
                                    return "Enter a valid price";
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: selectedCategory,
                                    decoration: InputDecoration(
                                      labelText: 'Category',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons
                                          .category), // 👈 Add your icon here
                                    ),
                                    items: categories.map((category) {
                                      return DropdownMenuItem<String>(
                                        value: category,
                                        child: Text(
                                          category,
                                          style: TextStyle(color: Colors.black),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCategory = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a category';
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: _inputDecoration(
                            'Description',
                            'Enter course description',
                            Icons.description,
                          ),
                          maxLines: 3,
                          validator: (value) => value!.trim().isEmpty
                              ? "Description is required"
                              : null,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildCard(
                    title: 'Course Content',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (sections.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "Please add at least one section with videos!",
                              style: TextStyle(color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ...sections
                            .asMap()
                            .entries
                            .map((entry) =>
                                _buildSectionItem(entry.key, entry.value))
                            .toList(),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showAddSectionDialog,
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Add New Section',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(160, 50),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.blue[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isPublishing ? null : _publishCourse,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isPublishing
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Publish Course',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // Get the temporary directory
        final tempDir = await getTemporaryDirectory();
        final tempPath = tempDir.path;
        
        // Create a unique filename
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
        final savedImage = File('$tempPath/$fileName');
        
        // Copy the picked file to our temporary directory
        await savedImage.writeAsBytes(await pickedFile.readAsBytes());
        
        setState(() {
          _selectedImage = savedImage;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            Divider(),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionItem(int index, Map<String, dynamic> section) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: Colors.green),
                onPressed: () => _showAddVideoDialog(index),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _removeSection(index),
              ),
              Text(
                section['title']!,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Spacer(),
              Text(
                section['duration']!,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
        ..._buildVideoList(section['videos'] ?? [], index),
      ],
    );
  }

  void _showAddSectionDialog() {
    TextEditingController sectionNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Section'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sectionNameController,
                decoration: InputDecoration(
                  hintText: "Enter section name",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String name = sectionNameController.text.trim();

                if (name.isNotEmpty) {
                  String formattedName = _truncateText(name, 13);

                  _addNewSection(formattedName);
                  Navigator.pop(context); // Close dialog
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length > maxLength) {
      return text.substring(0, maxLength - 3) +
          "..."; // Keep part of the text + "..."
    }
    return text;
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  void _addNewSection(String name) {
    setState(() {
      int sectionNumber = sections.length + 1;
      String formattedNumber =
          sectionNumber.toString().padLeft(2, '0'); // Ensures 01, 02, 03...

      sections.add({
        'title': "$formattedNumber- $name",
        'duration': '0 min',
        'videos': [],
      });
    });
  }

  void _removeSection(int index) {
    setState(() {
      sections.removeAt(index);
    });
  }

  void _showAddVideoDialog(int sectionIndex) async {
    TextEditingController videoTitleController = TextEditingController();
    String? selectedVideoPath;
    VideoPlayerController? _videoController;
    int videoDurationInMinutes = 0;

    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null && result.files.single.path != null) {
      selectedVideoPath = result.files.single.path!;
      _videoController =
          VideoPlayerController.file(file_conflict.File(selectedVideoPath));

      await _videoController.initialize();
    }

    // Get duration in minutes
    int durationInSeconds = _videoController!.value.duration.inSeconds;
    videoDurationInMinutes = (durationInSeconds / 60).ceil();

    if (!mounted)
      return; // Ensure dialog is shown only if the widget is still active

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
                TextButton(
                  onPressed: () {
                    if (videoTitleController.text.isNotEmpty &&
                        selectedVideoPath != null) {
                      _addVideoToSection(
                          sectionIndex,
                          videoTitleController.text,
                          selectedVideoPath!,
                          videoDurationInMinutes);
                      _videoController?.dispose();
                      Navigator.pop(context);
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

  void _addVideoToSection(
      int sectionIndex, String title, String videoPath, int videoDuration) {
    setState(() {
      sections[sectionIndex]['videos'] ??= [];
      sections[sectionIndex]['videos'].add({
        'title': title,
        'duration': '$videoDuration min',
        'videoPath': videoPath,
      });
      // Add video duration to the list
      videoDurations.add(videoDuration);
      int totalDuration = sections[sectionIndex]['videos'].fold(
          0, (sum, video) => sum + int.parse(video['duration'].split(' ')[0]));

      sections[sectionIndex]['duration'] = '$totalDuration min';
      _updateSectionDurations();
    });
  }

  List<Widget> _buildVideoList(List<dynamic> videos, int sectionIndex) {
    return videos.asMap().entries.map((entry) {
      int videoIndex = entry.key;
      Map video = entry.value;

      return Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey, width: 1), // Grey border
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          tileColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: () => _removeVideo(sectionIndex, videoIndex),
          ),
          title: Text(_truncateText(video['title'], 13),
              overflow: TextOverflow.ellipsis),
          subtitle: Text(video['duration']),
          trailing: Container(
              width: 40,
              height: 80,
              child: Icon(
                Icons.video_file,
                size: 50,
              )),
        ),
      );
    }).toList();
  }

  void _removeVideo(int sectionIndex, int videoIndex) {
    setState(() {
      List videos = sections[sectionIndex]['videos'];

      // Remove video and its duration
      int removedDuration =
          int.parse(videos[videoIndex]['duration'].split(' ')[0]);
      videoDurations.remove(removedDuration);

      // Remove the video
      videos.removeAt(videoIndex);

      // Recalculate total duration
      int totalDuration = videos.fold(
          0, (sum, video) => sum + int.parse(video['duration'].split(' ')[0]));

      // Update the section's duration
      sections[sectionIndex]['duration'] = '$totalDuration min';
      _updateSectionDurations();
    });
  }

  void _updateSectionDurations() {
    sectionDurations =
        sections.map((section) => section['duration'] as String).toList();
  }
}
