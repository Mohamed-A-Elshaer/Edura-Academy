import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/auth/Appwrite_service.dart';
import 'package:mashrooa_takharog/auth/supaAuth_service.dart';
import 'package:mashrooa_takharog/screens/SignInScreen.dart';
import 'package:mashrooa_takharog/screens/DisplayCourseLessons.dart';
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
  Map<String, bool> expandedDescriptions = {};

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

      // Get all pending courses
      final pendingCourses = result.documents.map((doc) => doc.data).toList();

      // For each pending course, check if it was previously approved
      for (var course in pendingCourses) {
        try {
          // Get the course history to check if it was previously approved
          final courseDoc = await Appwrite_service.databases.getDocument(
            databaseId: '67c029ce002c2d1ce046',
            collectionId: '67c1c87c00009d84c6ff',
            documentId: course['\$id'],
          );

          // Check if the course was previously approved
          course['approved'] = courseDoc.data['upload_status'] == 'approved' ||
              courseDoc.data['upload_status'] == 'pending';
        } catch (e) {
          print('Error checking course approval status: $e');
          course['approved'] = false;
        }
      }

      setState(() {
        this.pendingCourses = pendingCourses;
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

  Future<void> rejectCourse(String courseId, String courseTitle) async {
    try {
      await Appwrite_service.performCourseDeletion(
          courseId, courseTitle, context);

      setState(() {
        pendingCourses.removeWhere((course) => course['\$id'] == courseId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course rejected and deleted successfully'),
            backgroundColor: Color(0xffD50000),
          ),
        );
      }
    } catch (e) {
      print('Error rejecting course: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reject course'),
            backgroundColor: Color(0xffD50000),
          ),
        );
      }
    }
  }

  Future<void> approveDeletionRequest(
      String courseId, String courseTitle) async {
    try {
      // Just perform the deletion
      await Appwrite_service.performCourseDeletion(
          courseId, courseTitle, context);

      setState(() {
        pendingCourses.removeWhere((course) => course['\$id'] == courseId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Course deletion request approved - course has been deleted'),
            backgroundColor: Color(0xff00C853),
          ),
        );
      }
    } catch (e) {
      print('Error approving deletion request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to approve deletion request'),
            backgroundColor: Color(0xffD50000),
          ),
        );
      }
    }
  }

  Future<void> declineDeletionRequest(String courseId) async {
    try {
      // Set status back to approved to keep the course
      await Appwrite_service.databases.updateDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: courseId,
        data: {
          'upload_status': 'approved',
          'request_type': 'uploading_request' // Reset request type
        },
      );

      setState(() {
        pendingCourses.removeWhere((course) => course['\$id'] == courseId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Course deletion request declined - course remains available'),
            backgroundColor: Color(0xffD50000),
          ),
        );
      }
    } catch (e) {
      print('Error declining deletion request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to decline deletion request'),
            backgroundColor: Color(0xffD50000),
          ),
        );
      }
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
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Pending: ${pendingCourses.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff202244),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : pendingCourses.isEmpty
                        ? const Center(
                            child: Text(
                              'No pending courses for approval',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xff545454),
                                fontFamily: 'Mulish',
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: pendingCourses.length,
                            itemBuilder: (context, index) {
                              final course = pendingCourses[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FutureBuilder<String>(
                                        future: SupaAuthService
                                            .getCourseCoverImageUrl(
                                                course['title']),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              snapshot.data ?? '',
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 200,
                                                  width: double.infinity,
                                                  color: Colors.grey[200],
                                                  child: const Icon(Icons.image,
                                                      size: 50,
                                                      color: Colors.grey),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if ((course['title']?.length ?? 0) > 26) {
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) => AlertDialog(
                                                                title: const Text('Course Title'),
                                                                content: Text(
                                                                  course['title'] ?? 'Untitled Course',
                                                                  style: const TextStyle(
                                                                    fontSize: 16,
                                                                  ),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () => Navigator.pop(context),
                                                                    child: const Text('Close'),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                course['title'] ??
                                                                    'Untitled Course',
                                                                style: const TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 2,
                                                              ),
                                                            ),
                                                            if ((course['title']?.length ?? 0) > 26)
                                                              const Padding(
                                                                padding: EdgeInsets.only(left: 4),
                                                                child: Icon(
                                                                  Icons.expand_more,
                                                                  size: 20,
                                                                  color: Colors.grey,
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            course['approved'] ==
                                                                    true
                                                                ? Colors
                                                                    .red[100]
                                                                : Colors
                                                                    .blue[100],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        course['request_type'] ==
                                                                'deletion_request'
                                                            ? 'Deletion Request'
                                                            : 'Approval Request',
                                                        style: TextStyle(
                                                          color: course[
                                                                      'request_type'] ==
                                                                  'deletion_request'
                                                              ? Colors.red[800]
                                                              : Colors
                                                                  .blue[800],
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
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
                                                icon: const Icon(
                                                    Icons.video_library,
                                                    color: Colors.blue),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AdminCoursePreviewScreen(
                                                        title: course['title'],
                                                        courseId:
                                                            course['\$id'],
                                                        courseCategory:
                                                            course['category'],
                                                        courseImagePath: course[
                                                                'imagePath'] ??
                                                            'assets/images/mediahandler.png',
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              if (course['request_type'] ==
                                                  'deletion_request') ...[
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green),
                                                  onPressed: () =>
                                                      approveDeletionRequest(
                                                          course['\$id'],
                                                          course['title']),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.cancel,
                                                      color: Colors.red),
                                                  onPressed: () =>
                                                      declineDeletionRequest(
                                                          course['\$id']),
                                                ),
                                              ] else ...[
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green),
                                                  onPressed: () =>
                                                      approveCourse(
                                                          course['\$id']),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.cancel,
                                                      color: Colors.red),
                                                  onPressed: () => rejectCourse(
                                                      course['\$id'],
                                                      course['title']),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            course['description'] ??
                                                'No description available',
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                            ),
                                            maxLines: expandedDescriptions[
                                                        course['\$id']] ??
                                                    false
                                                ? null
                                                : 2,
                                          ),
                                          if ((course['description']?.length ??
                                                  0) >
                                              100)
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  expandedDescriptions[
                                                          course['\$id']] =
                                                      !(expandedDescriptions[
                                                              course['\$id']] ??
                                                          false);
                                                });
                                              },
                                              child: Text(
                                                expandedDescriptions[
                                                            course['\$id']] ??
                                                        false
                                                    ? 'See Less'
                                                    : 'See More',
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ), /*
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
          ),*/
        ],
      ),
    );
  }
}
