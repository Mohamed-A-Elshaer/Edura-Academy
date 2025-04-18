
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';

import '../screens/instructor_courses_screen.dart';

class Appwrite_service{


  static Client client = Client()
      .setEndpoint("https://cloud.appwrite.io/v1")
      .setProject("67ac8356002648e5b7e9");

  static final Account _account = Account(client);
  static Account get account => _account;
  static Databases databases = Databases(client);
  static Storage storage = Storage(client);


  static Future<User> getCurrentUser() async {
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



  static Future<void> renameFileInStorage(String oldFileId, String newFileName) async {
    try {
      print("🔄 Renaming file: $oldFileId → $newFileName");

      String bucketId = '67ac838900066b15fc99'; // Replace with your actual bucket ID

      // Step 1: Get the existing file
      final fileList = await storage.listFiles(bucketId: bucketId);
      final file = fileList.files.firstWhere(
            (f) => f.$id == oldFileId,
        orElse: () => throw Exception("File not found: $oldFileId"),
      );

      // Step 2: Download file bytes
      final fileBytes = await storage.getFileView(
        bucketId: bucketId,
        fileId: oldFileId,
      );

      print("✅ File downloaded successfully: ${fileBytes.length} bytes");

      // Step 3: Upload file with new name
      final newFile = await storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(), // Generate a new unique ID
        file: InputFile.fromBytes(
          bytes: fileBytes,
          filename: newFileName,
        ),
      );

      print("✅ File uploaded with new name: ${newFile.$id}");

      // Step 4: Delete old file
      await storage.deleteFile(bucketId: bucketId, fileId: oldFileId);
      print("🗑️ Old file deleted: $oldFileId");

    } catch (e) {
      print("❌ Error renaming file: $e");
    }
  }




  static Future<List<File>> getAllRelatedFiles(String oldName) async {
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
      String formattedOldTitle = oldName.replaceAll(' ', '_').toLowerCase();
      String formattedNewTitle = newName.replaceAll(' ', '_').toLowerCase();

      List<File> filesToRename = await getAllRelatedFiles(oldName);

      for (File file in filesToRename) {
        String oldFileName = file.name;
        String newFileName = oldFileName.replaceAll(formattedOldTitle, formattedNewTitle);

        await renameFileInStorage(file.$id, newFileName);
      }

      print("✅ All course files renamed successfully.");
    } catch (e) {
      print("❌ Error renaming course files: $e");
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
          'video_folder_id': formattedNewTitle, // Update video_folder_id
        },
      );

      // Step 2: Rename all related files
      await renameAllCourseFiles(oldName, newName);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
          SnackBar(
            content: Text("Failed to update course!", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      print("❌ Error updating course: $e");
    }
  }

  /// Delete course from DB & Storage
  static Future<void> deleteCourse(String courseId, String courseName, BuildContext context) async {

    try {
      String formattedTitle = courseName.replaceAll(' ', '_').toLowerCase();
      // Delete course from DB
      await databases.deleteDocument(
        databaseId: "67c029ce002c2d1ce046",
        collectionId: "67c1c87c00009d84c6ff",
        documentId: courseId,
      );

      // Delete all course files from Storage
      final response = await storage.listFiles(
          bucketId: "67ac838900066b15fc99");

      for (var file in response.files) {
        // ✅ Ensure correct path match
        if (file.name.startsWith("$formattedTitle/")) {
          await storage.deleteFile(
              bucketId: "67ac838900066b15fc99", fileId: file.$id);
          print("Deleted file: ${file.name}");
        }
      }
      print("Course and associated files deleted successfully.");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Course deleted successfully!",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("failed to delete course!",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      print("Error deleting course: $e");}
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


  /*static Future<String> getCoverImageUrl(String courseName) async {
   try {
     final storage = Storage(Appwrite_service.client);
     String formattedTitle = courseName.replaceAll(' ', '_');
     // Fetch the cover image file details
     final coverFiles = await storage.listFiles(
       bucketId: "67ac838900066b15fc99",
       queries: [Query.equal("name", "$formattedTitle/course_cover.jpg")],
     );

     // Check if the cover image exists
     if (coverFiles.files.isNotEmpty) {
       final fileId = coverFiles.files.first.$id;

       // Construct the preview URL manually
       return "https://cloud.appwrite.io/v1/storage/buckets/67ac838900066b15fc99/files/$fileId/preview?project=67ac8356002648e5b7e9";
     } else {
       return "https://via.placeholder.com/300"; // Default placeholder if no cover found
     }
   } catch (e) {
     print("Error retrieving cover image: $e");
     return "https://via.placeholder.com/300"; // Return placeholder on error
   }
 }*/





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






}