import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/auth/Appwrite_service.dart';
import 'package:mashrooa_takharog/auth/supaAuth_service.dart';
import 'package:mashrooa_takharog/screens/SignInScreen.dart';
import 'package:mashrooa_takharog/widgets/coursecard.dart';
import 'package:mashrooa_takharog/screens/AdminCoursePreviewScreen.dart';

class AdminCourseApprovalScreen extends StatefulWidget {
  const AdminCourseApprovalScreen({super.key});

  @override
  State<AdminCourseApprovalScreen> createState() =>
      _AdminCourseApprovalScreenState();
}

class _AdminCourseApprovalScreenState extends State<AdminCourseApprovalScreen> {
  List<Map<String, dynamic>> pendingCourses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingCourses();
  }

  Future<void> fetchPendingCourses() async {
    try {
      final result = await Appwrite_service.databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        queries: [
          appwrite.Query.equal('upload_status', 'pending'),
        ],
      );

      setState(() {
        pendingCourses = result.documents.map((doc) => doc.data).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching pending courses: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> approveCourse(String courseId) async {
    try {
      await Appwrite_service.databases.updateDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: courseId,
        data: {
          'upload_status': 'approved',
        },
      );

      setState(() {
        pendingCourses.removeWhere((course) => course['\$id'] == courseId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course approved successfully'),
          backgroundColor: Color(0xff00C853),
        ),
      );
    } catch (e) {
      print('Error approving course: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to approve course'),
          backgroundColor: Color(0xffD50000),
        ),
      );
    }
  }

  Future<void> rejectCourse(String courseId) async {
    try {
      await Appwrite_service.databases.updateDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: courseId,
        data: {
          'upload_status': 'rejected',
        },
      );

      setState(() {
        pendingCourses.removeWhere((course) => course['\$id'] == courseId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course rejected successfully'),
          backgroundColor: Color(0xffD50000),
        ),
      );
    } catch (e) {
      print('Error rejecting course: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reject course'),
          backgroundColor: Color(0xffD50000),
        ),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await SupaAuthService.signOut();

      final account = Appwrite_service.account;
      final sessions = await account.listSessions();
      if (sessions.sessions.isNotEmpty) {
        await account.deleteSession(sessionId: 'current');
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      }
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF),
      appBar: AppBar(
        title: const Text(
          'Course Approval',
          style: TextStyle(
            color: Color(0xff202244),
            fontFamily: 'Jost',
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (pendingCourses.isEmpty)
            const Center(
              child: Text(
                'No pending courses for approval',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff545454),
                  fontFamily: 'Mulish',
                ),
              ),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: pendingCourses.length,
              itemBuilder: (context, index) {
                final course = pendingCourses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course['title'] ?? 'Untitled Course',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Instructor: ${course['instructor_name'] ?? 'Unknown'}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'Category: ${course['category'] ?? 'Uncategorized'}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.video_library,
                                      color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AdminCoursePreviewScreen(
                                          title: course['title'],
                                          courseId: course['\$id'],
                                          courseCategory: course['category'],
                                          courseImagePath: course[
                                                  'imagePath'] ??
                                              'assets/images/mediahandler.png',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  onPressed: () =>
                                      approveCourse(course['\$id']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.red),
                                  onPressed: () => rejectCourse(course['\$id']),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          course['description'] ?? 'No description available',
                          style: TextStyle(
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _signOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0961F5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Mulish',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
