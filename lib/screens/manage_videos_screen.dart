import 'package:flutter/material.dart';

class ManageVideosScreen extends StatefulWidget {
  final String courseId;

  const ManageVideosScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<ManageVideosScreen> createState() => _ManageVideosScreenState();
}

class _ManageVideosScreenState extends State<ManageVideosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Videos'),
      ),
      body: const Center(
        child: Text('Video management coming soon...'),
      ),
    );
  }
}
