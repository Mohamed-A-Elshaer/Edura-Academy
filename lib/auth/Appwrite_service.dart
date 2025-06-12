import 'dart:typed_data';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite;
import 'package:flutter/material.dart';

import 'package:mashrooa_takharog/auth/supaAuth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../screens/instructor_courses_screen.dart';

class Appwrite_service{


  static Client client = Client()
      .setEndpoint("https://cloud.appwrite.io/v1")
      .setProject("67ac8356002648e5b7e9");

  static final Account _account = Account(client);
  static Account get account => _account;
  static Databases databases = Databases(client);
  static Storage storage = Storage(client);


  static Future<appwrite.User> getCurrentUser() async {
    try {
      return await _account.get();
    } catch (e) {
      print("Error fetching user: $e");
      throw e;
    }
  }

  // Get instructor name by email
  static Future<String?> getInstructorNameByEmail(String email) async {
    try {
      final response = await databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        queries: [Query.equal("email", email)], // Search by email
      );

      if (response.documents.isEmpty) return null; // No user found

      return response.documents.first.data["name"]; // Return instructor name
    } catch (e) {
      print("Error fetching instructor name: $e");
      return null;
    }
  }


  /// Fetch courses for the logged-in instructor
  static Future<List<Course>> getInstructorCourses(String instructorName) async {
    final response = await databases.listDocuments(
      databaseId: "67c029ce002c2d1ce046",
      collectionId: "67c1c87c00009d84c6ff",
      queries: [
        Query.equal("instructor_name", instructorName),
      ],
    );

    return await Future.wait(response.documents.map((doc) => Course.fromMap(doc.data)));  }



  




  static Future<List<appwrite.File>> getAllRelatedFiles(String oldName) async {
    try {
      String formattedOldTitle = oldName.replaceAll(' ', '_').toLowerCase();

      final result = await storage.listFiles(bucketId: '67ac838900066b15fc99');

      // Find all files that contain the old course title in their name
      return result.files.where((file) => file.name.contains(formattedOldTitle)).toList();
    } catch (e) {
      print("❌ Error fetching related files: $e");
      return [];
    }
  }

  /// Rename all files that contain the old course name
  static Future<void> renameAllCourseFiles(String oldName, String newName) async {
    try {
      String formattedOldTitle = oldName.replaceAll(' ', '_');
      String formattedNewTitle = newName.replaceAll(' ', '_');

      print("🔄 Starting file rename process");
      print("Old name: $formattedOldTitle");
      print("New name: $formattedNewTitle");

      // Get all files from the bucket
      final result = await storage.listFiles(bucketId: '67ac838900066b15fc99');
      
      // Filter files that belong to this course
      final filesToRename = result.files.where((file) => 
        file.name.toLowerCase().startsWith('${formattedOldTitle.toLowerCase()}/')
      ).toList();

      print("📁 Found ${filesToRename.length} files to rename");

      for (var file in filesToRename) {
        try {
          // Download the file - Appwrite returns Uint8List directly
          final Uint8List fileBytes = await storage.getFileDownload(
            bucketId: '67ac838900066b15fc99',
            fileId: file.$id,
          );

          // Create new file path by replacing the old course name with the new one
          // Use case-insensitive replacement for the course title part
          String newFilePath = file.name.replaceFirst(
            RegExp(formattedOldTitle, caseSensitive: false),
            formattedNewTitle.toLowerCase()
          );
          
          print("📝 Renaming: ${file.name} -> $newFilePath");

          // Upload the file with the new path
          await storage.createFile(
            bucketId: '67ac838900066b15fc99',
            fileId: ID.unique(),
            file: InputFile.fromBytes(
              bytes: fileBytes,
              filename: newFilePath,
            ),
          );

          // Delete the old file
          await storage.deleteFile(
            bucketId: '67ac838900066b15fc99',
            fileId: file.$id,
          );

          print("✅ Successfully renamed: ${file.name}");
        } catch (e) {
          print("❌ Error processing file ${file.name}: $e");
        }
      }

      // Handle Supabase storage files
      final oldFolderName = formattedOldTitle;
      final newFolderName = formattedNewTitle;

      try {
        // List all files in the old folder
        final oldFiles = await SupaAuthService.supabase.storage
            .from('profiles')
            .list(path: oldFolderName);

        // Move each file to the new folder
        for (var file in oldFiles) {
          final oldFilePath = '$oldFolderName/${file.name}';
          final newFilePath = '$newFolderName/${file.name}';

          // Download the file
          final fileBytes = await SupaAuthService.supabase.storage
              .from('profiles')
              .download(oldFilePath);

          // Upload to new location
          await SupaAuthService.supabase.storage
              .from('profiles')
              .uploadBinary(
                newFilePath,
                fileBytes,
                fileOptions: const FileOptions(upsert: true),
              );

          // Delete old file
          await SupaAuthService.supabase.storage
              .from('profiles')
              .remove([oldFilePath]);
        }

        print("✅ Supabase files renamed successfully");
      } catch (e) {
        print("❌ Error renaming Supabase files: $e");
      }

      print("✅ All course files renamed successfully");
    } catch (e) {
      print("❌ Error in renameAllCourseFiles: $e");
      throw e;
    }
  }

  /// Update course information and rename all associated files
  static Future<void> updateCourse(
      String courseId,
      String oldName,
      String newName,
      String desc,
      String category,
      double price,
      BuildContext context) async {
    try {
      String formattedNewTitle = newName.replaceAll(' ', '_').toLowerCase();

      // Step 1: Update course data in Appwrite DB
      await databases.updateDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: courseId,
        data: {
          'title': newName,
          'description': desc,
          'category': category,
          'price': price,
          'video_folder_id': formattedNewTitle,
          'upload_status': "pending"
        },
      );



      // Step 2: Rename all related files
      await renameAllCourseFiles(oldName, newName);
      await _updateCourseNameInUserLists(oldName, newName);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Course updated successfully!", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update course!", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      print("❌ Error updating course: $e");
    }
  }


  static Future<void> _updateCourseNameInUserLists(String oldName, String newName) async {
    try {
      // Fetch all user documents
      var response = await databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
      );

      for (var document in response.documents) {
        bool updated = false;

        // Check and update purchased_courses
        List<dynamic> purchasedCourses = document.data['purchased_courses'] ?? [];
        if (purchasedCourses.contains(oldName)) {
          int index = purchasedCourses.indexOf(oldName);
          purchasedCourses[index] = newName;
          updated = true;
        }

        // Check and update completed_courses
        List<dynamic> completedCourses = document.data['completed_courses'] ?? [];
        if (completedCourses.contains(oldName)) {
          int index = completedCourses.indexOf(oldName);
          completedCourses[index] = newName;
          updated = true;
        }

        // Check and update ongoing_courses
        List<dynamic> ongoingCourses = document.data['ongoing_courses'] ?? [];
        if (ongoingCourses.contains(oldName)) {
          int index = ongoingCourses.indexOf(oldName);
          ongoingCourses[index] = newName;
          updated = true;
        }

        // Check and update ratedCourseIds
        List<dynamic> ratedCourseIds = document.data['ratedCourseIds'] ?? [];
        if (ratedCourseIds.contains(oldName)) {
          int index = ratedCourseIds.indexOf(oldName);
          ratedCourseIds[index] = newName;
          updated = true;
        }

        // Update the user document if any list was changed
        if (updated) {
          await databases.updateDocument(
            databaseId: '67c029ce002c2d1ce046',
            collectionId: '67c0cc3600114e71d658', // Replace with your actual users collection ID
            documentId: document.$id,
            data: {
              'purchased_courses': purchasedCourses,
              'completed_courses': completedCourses,
              'ongoing_courses': ongoingCourses,
              'ratedCourseIds': ratedCourseIds,
            },
          );
        }
      }
    } catch (e) {
      print("❌ Error updating course names in user lists: $e");
    }
  }

  /// Delete course from DB & Storage
  static Future<void> deleteCourse(String courseId, String courseName, BuildContext context) async {
    try {
      // First get the current course status
      final course = await databases.getDocument(
        databaseId: "67c029ce002c2d1ce046",
        collectionId: "67c1c87c00009d84c6ff",
        documentId: courseId,
      );

      // If the course was previously approved, set status to pending for admin review
      if (course.data['upload_status'] == 'approved') {
        await databases.updateDocument(
          databaseId: "67c029ce002c2d1ce046",
          collectionId: "67c1c87c00009d84c6ff",
          documentId: courseId,
          data: {
            'upload_status': 'pending',
            'request_type': 'deletion_request'  // Set request type for deletion
          },
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
           const     SnackBar(
              content: Text("Course deletion request submitted. Waiting for admin approval.",
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // If course wasn't approved, just delete it directly
        await performCourseDeletion(courseId, courseName, context);
      }
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
      const  SnackBar(
          content: Text("Failed to submit deletion request!",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      print("Error submitting deletion request: $e");
    }
  }

  /// Actually delete the course after admin approval
  static Future<void> performCourseDeletion(String courseId, String courseName, BuildContext context) async {
    try {
      String formattedTitle = courseName.replaceAll(' ', '_').toLowerCase();
      
      // 1. Delete course from Appwrite DB
      await databases.deleteDocument(
        databaseId: "67c029ce002c2d1ce046",
        collectionId: "67c1c87c00009d84c6ff",
        documentId: courseId,
      );

      // 2. Delete all course files from Appwrite Storage
      final response = await storage.listFiles(
          bucketId: "67ac838900066b15fc99");

      for (var file in response.files) {
        if (file.name.startsWith("$formattedTitle/")) {
          await storage.deleteFile(
              bucketId: "67ac838900066b15fc99", fileId: file.$id);
          print("Deleted Appwrite file: ${file.name}");
        }
      }

      // 3. Delete course folder from Supabase Storage
      await SupaAuthService.deleteCourseFolderFromSupabase(courseName);

      // 4. Remove course from users' purchased_courses, completed_courses, and ongoing_courses
      final usersResponse = await databases.listDocuments(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
      );

      for (var userDoc in usersResponse.documents) {
        List<dynamic> purchasedCourses = List.from(userDoc.data['purchased_courses'] ?? []);
        List<dynamic> completedCourses = List.from(userDoc.data['completed_courses'] ?? []);
        List<dynamic> ongoingCourses = List.from(userDoc.data['ongoing_courses'] ?? []);
        List<dynamic> ratedCourseIds = List.from(userDoc.data['ratedCourseIds'] ?? []);

        bool updated = false;

        if (purchasedCourses.contains(courseName)) {
          purchasedCourses.remove(courseName);
          updated = true;
        }
        if (completedCourses.contains(courseName)) {
          completedCourses.remove(courseName);
          updated = true;
        }
        if (ongoingCourses.contains(courseName)) {
          ongoingCourses.remove(courseName);
          updated = true;
        }
        if (ratedCourseIds.contains(courseName)) {
          ratedCourseIds.remove(courseName);
          updated = true;
        }

        if (updated) {
          await databases.updateDocument(
            databaseId: '67c029ce002c2d1ce046',
            collectionId: '67c0cc3600114e71d658',
            documentId: userDoc.$id,
            data: {
              'purchased_courses': purchasedCourses,
              'completed_courses': completedCourses,
              'ongoing_courses': ongoingCourses,
              'ratedCourseIds': ratedCourseIds,
            },
          );
        }
      }

      print("Course and associated files deleted successfully.");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
            content: Text("Course deleted successfully!",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
          content: Text("Failed to delete course!",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      print("Error deleting course: $e");
    }
  }

  /// Fetches the number of videos for a course by counting files in `courseName/` folder.
  static Future<int> getVideosCount(String courseId) async {
    try {
      final response = await databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: courseId,
      );

      final videosArray = response.data['videos'] as List<dynamic>?;

      return videosArray?.length ?? 0;
    } catch (e) {
      print("Error fetching video count from DB: $e");
      return 0;
    }
  }




  static Future<void> appwriteForceLogout() async{
    final client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('67ac8356002648e5b7e9')
        .setSelfSigned(status: true);
    final account=Account(client);
    try {
      // Check if there is an active session before deleting it
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
  }

  static Future<String?> getCurrentAppwriteUserId() async {
    try {
      final user = await account.get();
      return user.$id;
    } catch (e) {
      print('Error fetching current Appwrite user: $e');
      return null;
    }
  }


  Future<void> sendAppwritePasswordRecoveryEmail(String email) async {
    try {

      await account.createRecovery(
        email: email,
        url: 'https://yourapp.com/recovery', // URL to redirect after recovery
      );

      print('Password recovery email sent via Appwrite');
    } catch (e) {
      print('Error sending Appwrite password recovery email: $e');
    }
  }




}