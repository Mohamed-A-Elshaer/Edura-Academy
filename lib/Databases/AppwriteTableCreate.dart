import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:mashrooa_takharog/auth/Appwrite_service.dart';

class AppwriteTableCreate{

 static Future<void> insertAppwriteUserDatabase(String? name, String? email, String? userType, String? userId) async {


    try {


      await Appwrite_service.databases.createDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        documentId: userId!, // Linking Auth ID
        data: {
          'name': name,
          'email': email,
          'user_type': userType,
          'id':userId
        },
      );

      print('User registered in Appwrite DB and linked to auth successfully');
    } catch (e) {
      print('Appwrite DB registration failed: $e');
    }
  }

 static Future<String?> getCurrentUserId() async {
   try {

     final client = Client()
         .setEndpoint('https://cloud.appwrite.io/v1')
         .setProject('67ac8356002648e5b7e9')
         .setSelfSigned(status: true);
     final account=Account(client);
     User user = await account.get();
     return user.$id;
   } catch (e) {
     print("Error getting Appwrite user ID: $e");
     return null;
   }
 }


 static Future<void> updateUserInAppwriteDB(String userId,  String newEmail,  String name) async {
   try {
     final client = Client()
         .setEndpoint('https://cloud.appwrite.io/v1')
         .setProject('67ac8356002648e5b7e9')
         .setSelfSigned(status: true);

     final databases = Databases(client);
     final appwriteResponse = await Appwrite_service.databases.getDocument(
       databaseId: '67c029ce002c2d1ce046',
       collectionId: '67c0cc3600114e71d658',
       documentId: userId,
     );

     String appwriteCurrentEmail = appwriteResponse.data['email'];
     String appwriteCurrentFullName = appwriteResponse.data['name'];

     // 🔹 Step 5: Ensure only changed fields are updated in Appwrite
     Map<String, dynamic> appwriteUpdateData = {};

     if (newEmail != null && newEmail.isNotEmpty && newEmail != appwriteCurrentEmail) {
       appwriteUpdateData['email'] = newEmail;  // ✅ Prevent empty email updates
     }

     if (name != null && name.isNotEmpty && name != appwriteCurrentFullName) {
       appwriteUpdateData['name'] = name;  // ✅ Prevent unnecessary updates
     }

     if (appwriteUpdateData.isNotEmpty) {
       // ✅ Step 6: Update Appwrite only if there are changes
       await Appwrite_service.databases.updateDocument(
         databaseId: '67c029ce002c2d1ce046',
         collectionId: '67c0cc3600114e71d658',
         documentId: userId,
         data: appwriteUpdateData,
       );
     }

     print('Appwrite DB is updated successfully!');
   } catch (e) {
     throw Exception("Failed to update Appwrite DB: $e");
   }
 }


}