import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/AddCoursePage.dart';
import '../auth/Appwrite_service.dart';
import '../auth/supaAuth_service.dart';
import 'manage_videos_screen.dart';

class InstructorCoursesScreen extends StatefulWidget {
  const InstructorCoursesScreen({super.key});

  @override
  _InstructorCoursesScreenState createState() => _InstructorCoursesScreenState();
}

class _InstructorCoursesScreenState extends State<InstructorCoursesScreen> {
  List<Course> courses = [];
  bool isLoading = true;
  Map<String, bool> _expandedStates = {};

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  /// Fetch courses from Appwrite DB & their video counts from Storage
  Future<void> _fetchCourses() async {
    try {
      // Step 1: Get the currently logged-in user's email
      final user = await Appwrite_service.getCurrentUser();
      final email = user.email; // Extract the email

      // Step 2: Fetch instructor name from "users" collection using email
      final instructorName = await Appwrite_service.getInstructorNameByEmail(email);

      if (instructorName == null) {
        print("Instructor name not found!");
        setState(() => isLoading = false);
        return;
      }

      // Step 3: Get courses for this instructor
      List<Course> fetchedCourses = await Appwrite_service.getInstructorCourses(instructorName);

      // Step 4: Fetch video count for each course
      for (var course in fetchedCourses) {
        course.videosCount = await Appwrite_service.getVideosCount(course.id);
        course.coverImage = await SupaAuthService.getCourseCoverImageUrl(course.title);
      }

      setState(() {
        courses = fetchedCourses;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching courses: $e");
      setState(() => isLoading = false);
    }
  }


  /// Show edit course dialog
  void _showEditDialog(Course course) {
    TextEditingController nameController = TextEditingController(text: course.title);
    TextEditingController descController = TextEditingController(text: course.description);
    TextEditingController categoryController = TextEditingController(text: course.category);
    TextEditingController priceController = TextEditingController(text: course.price.toString());
    List<String> categories = [
      "Graphic Design",
      "Arts & Humanities",
      "Cooking",
      "SEO & Marketing",
      "Programming",
      "Finance and Accounting",
      "Personal Development",
      "Office Productivity",
    ];
    String selectedCategory = course.category;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Course Information"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nameController, "Course Name"),
            _buildTextField(descController, "Description"),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category,style: TextStyle(color: Colors.black),),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  selectedCategory = newValue;
                  categoryController.text = newValue;
                }
              },
            ),
            _buildTextField(priceController, "Price", isNumeric: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () async {
              double? parsedPrice = double.tryParse(priceController.text);
              if (parsedPrice == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid price format")));
                return;
              }
              await Appwrite_service.updateCourse(
                course.id,
                course.title,
                nameController.text,
                descController.text,
                  selectedCategory,
                  parsedPrice,
                context
               );
              Navigator.pop(context);
              _fetchCourses();
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }

  /// Delete course function
  void _deleteCourse(String courseId, String courseName,BuildContext context) async {
    await Appwrite_service.deleteCourse(courseId, courseName,context);
    await SupaAuthService.deleteCourseFolderFromSupabase(courseName);
    _fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('My Courses', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.blue),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddCoursePage())),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())  // Loading indicator
          : courses.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) => _buildCourseCard(courses[index]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text('No courses yet', style: TextStyle(fontSize: 20, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddCoursePage())),
            icon: Icon(Icons.add),
            label: Text('Add Your First Course'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    bool isExpanded = _expandedStates[course.id] ?? false;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(course.coverImage, fit: BoxFit.cover, height: 180, width: double.infinity),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.category,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange[800])),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(course.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      onSelected: (value) => _handleMenuSelection(value, course),
                      itemBuilder: (context) => [
                        _buildPopupMenuItem('edit', Icons.edit, Colors.blue, 'Edit Course'),
                        _buildPopupMenuItem('videos', Icons.video_library, Colors.green, 'Manage Videos'),
                        _buildPopupMenuItem('delete', Icons.delete, Colors.red, 'Delete Course', isRed: true),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final span = TextSpan(
                      text: course.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    );
                    final tp = TextPainter(
                      text: span,
                      maxLines: 3,
                      textDirection: TextDirection.ltr,
                    )..layout(maxWidth: constraints.maxWidth);

                    final isOverflowing = tp.didExceedMaxLines;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.description,
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          maxLines: isExpanded ? null : 3,
                          overflow: TextOverflow.fade,
                        ),
                        if (isOverflowing)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _expandedStates[course.id] = !isExpanded;
                                });
                              },
                              child: Text(isExpanded ? 'See less' : 'See more'),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(Icons.access_time, "${course.duration} mins", Colors.blue),
                    SizedBox(width: 16),
                    _buildInfoChip(Icons.video_library, "${course.videosCount} videos", Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(hintText: hint,labelText:hint , border: OutlineInputBorder()),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16, color: color), SizedBox(width: 4), Text(label, style: TextStyle(color: color))],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, IconData icon, Color color, String text, {bool isRed = false}) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [Icon(icon, color: color), SizedBox(width: 8), Text(text, style: TextStyle(color: isRed ? Colors.red : Colors.black))]),
    );
  }

  void _handleMenuSelection(String value, Course course) {
    if (value == 'edit') _showEditDialog(course);
    if (value == 'videos') Navigator.push(context, MaterialPageRoute(builder: (context) => ManageVideosScreen(courseId: course.id,courseTitle: course.title,)));
    if (value == 'delete') _deleteCourse(course.id, course.title,context);
  }
}




class Course {
  final String id;
  final String title;
  final String category;
  final String description;
  final int duration;
   int videosCount;
   String coverImage;
  final double price;

  Course({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.duration,
    required this.videosCount,
    required this.coverImage,
    required this.price
  });
  /// Convert Appwrite document data into a `Course` object
  static Future<Course> fromMap(Map<String, dynamic> data) async {
    String coverUrl = await SupaAuthService.getCourseCoverImageUrl(data['title']);
    return Course(
      id: data['\$id'] ?? '',
      title: data['title'] ?? 'Untitled',
      category: data['category'] ?? 'Unknown',
      description: data['description'] ?? 'No description',
      duration: data['courseDuration_inMins'] ?? 0,
      videosCount: 0, // We fetch this separately from Storage
      coverImage: coverUrl, // Now it's assigned correctly
      price: (data['price'] is int) ? (data['price'] as int).toDouble() : (data['price'] ?? 0.0),
    );
  }







}
