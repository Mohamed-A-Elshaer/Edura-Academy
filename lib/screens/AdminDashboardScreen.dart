import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/AdminCourseApprovalScreen.dart';
import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:mashrooa_takharog/auth/appwrite_service.dart';



class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int totalCourses = 0;
  int totalInstructors = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTotalCourses();
    fetchTotalInstructors();
  }

  Future<void> fetchTotalCourses() async {
    try {
      final result = await Appwrite_service.databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
      );
      setState(() {
        totalCourses = result.total;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching total courses: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchTotalInstructors() async {
    try {
      final result = await Appwrite_service.databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        queries: [
          appwrite.Query.equal('user_type', 'instructor'),
        ],
      );
      setState(() {
        totalInstructors = result.total;
      });
    } catch (e) {
      print('Error fetching total instructors: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w600,
                color: Color(0xff202244),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Courses: $totalCourses'),
               // Text('Pending: ${pendingCourses.length}'),
              ],
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('students').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final studentCount = snapshot.data!.docs.length;
                return _buildStatCard(
                  'Total Students',
                  studentCount.toString(),
                  Icons.people,
                  const Color(0xff0961F5),
                );
              },
            ),
            const SizedBox(height: 16),
            isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildStatCard(
                  'Total Instructors',
                  totalInstructors.toString(),
                  Icons.person,
                  const Color(0xff00C853),
                ),
            const SizedBox(height: 16),
            isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildStatCard(
                  'Total Courses',
                  totalCourses.toString(),
                  Icons.book,
                  const Color(0xffFF6D00),
                ),
            const SizedBox(height: 30),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w600,
                color: Color(0xff202244),
              ),
            ),
            const SizedBox(height: 16),
          /*  _buildQuickActionCard(
              context,
              'Approve Courses',
              'Review and approve new courses',
              Icons.approval,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminCourseApprovalScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildQuickActionCard(
              context,
              'Manage Users',
              'View and manage user accounts',
              Icons.people,
              () {
                // Navigate to user management screen
              },
            ),*/
            const SizedBox(height: 16),
         /*   _buildQuickActionCard(
              context,
              'View Reports',
              'View platform statistics and reports',
              Icons.analytics,
              () {
                // Navigate to reports screen
              },
            )*/
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xff545454),
                  fontFamily: 'Mulish',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff202244),
                  fontFamily: 'Jost',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff0961F5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xff0961F5), size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff202244),
                      fontFamily: 'Jost',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff545454),
                      fontFamily: 'Mulish',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xff0961F5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
} 