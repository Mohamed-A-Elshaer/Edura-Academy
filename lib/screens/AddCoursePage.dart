import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/InstructorNavigatorScreen.dart';

class VideoItem {
  final String title;
  final String videoUrl;

  VideoItem({required this.title, required this.videoUrl});
}

class AddCoursePage extends StatefulWidget {
  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();
  List<VideoItem> videos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>InstructorNavigatorScreen()));

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
                    title: 'Course Information',
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: _inputDecoration(
                            'Course Title',
                            'Enter course title',
                            Icons.title,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: _inputDecoration(
                                  'Price (\$)',
                                  'Enter price',
                                  Icons.attach_money,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                decoration: _inputDecoration(
                                  'Category',
                                  'Select category',
                                  Icons.category,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          decoration: _inputDecoration(
                            'Description',
                            'Enter course description',
                            Icons.description,
                          ),
                          maxLines: 3,
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
                        ...videos
                            .map((video) => VideoItemWidget(
                                  video: video,
                                  onDelete: () {
                                    setState(() {
                                      videos.remove(video);
                                    });
                                  },
                                ))
                            .toList(),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _addNewVideo,
                          icon: Icon(Icons.add_circle_outline,color: Colors.white,),
                          label: Text('Add New Video',style: TextStyle(color: Colors.white),),
                          style: ElevatedButton.styleFrom(
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
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
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

  void _addNewVideo() {
    showDialog(
      context: context,
      builder: (context) => AddVideoDialog(
        onAdd: (videoItem) {
          setState(() {
            videos.add(videoItem);
          });
        },
      ),
    );
  }
}

class VideoItemWidget extends StatelessWidget {
  final VideoItem video;
  final VoidCallback onDelete;

  const VideoItemWidget({
    required this.video,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(Icons.play_circle_outline, color: Colors.blue),
        title: Text(
          video.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(video.videoUrl),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class AddVideoDialog extends StatelessWidget {
  final Function(VideoItem) onAdd;

  const AddVideoDialog({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    return AlertDialog(
      title: Text('Add New Video'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Video Title'),
          ),
          TextField(
            controller: urlController,
            decoration: InputDecoration(labelText: 'Video URL'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (titleController.text.isNotEmpty &&
                urlController.text.isNotEmpty) {
              onAdd(VideoItem(
                title: titleController.text,
                videoUrl: urlController.text,
              ));
              Navigator.pop(context);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
