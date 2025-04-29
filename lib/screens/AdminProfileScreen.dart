import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appwrite/appwrite.dart';
import 'package:mashrooa_takharog/screens/StudentOrInstructor.dart';
import 'package:mashrooa_takharog/auth/Appwrite_service.dart';
import 'package:mashrooa_takharog/Databases/AppwriteTableCreate.dart';
import 'package:mashrooa_takharog/auth/auth_service.dart';
import 'package:mashrooa_takharog/auth/supaAuth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _adminName = '';

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    try {
      // Get current user from Appwrite
      final user = await Appwrite_service.getCurrentUser();

      if (user != null) {
        // Get user details from the database
        final document = await Appwrite_service.databases.listDocuments(
            databaseId: '67c029ce002c2d1ce046',
            collectionId: '67c0cc3600114e71d658',
            queries: [Query.equal('email', user.email)]);

        if (document.documents.isNotEmpty) {
          if (mounted) {
            setState(() {
              _adminName = document.documents.first.data['name'] ?? 'Admin';
            });
          }
        } else {
          print('No user document found for email: ${user.email}');
        }
      }
    } catch (e) {
      print('Error loading admin data: $e');
      if (mounted) {
        setState(() {
          _adminName = 'Admin';
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Sign out from Firebase
      final auth = AuthService();
      auth.signOut();

      // Sign out from Supabase
      SupaAuthService.signOut();

      // Sign out from Appwrite
      try {
        final account = Appwrite_service.account;
        final sessions = await account.listSessions();
        if (sessions.sessions.isNotEmpty) {
          await account.deleteSession(sessionId: 'current');
          print("Appwrite session deleted successfully");
        } else {
          print("No active Appwrite session found");
        }
      } catch (e) {
        print("Error deleting Appwrite session: $e");
      }

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => StudentOrInstructor()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error signing out')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xff0961F5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _adminName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                _adminName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xff0961F5)),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: _signOut,
            ),
          ],
        ),
      ),
    );
  }
}
