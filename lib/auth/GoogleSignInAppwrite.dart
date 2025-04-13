import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class GoogleSignInAppwrite {
  static Future<void> appWriteGoogleSignIn(String email, String name, String userId) async {
    final client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('67ac8356002648e5b7e9')
        .setSelfSigned(status: true);

    final account = Account(client);

    try {
      // Check if user already exists
      User user = await account.get();
      print("User already exists in Appwrite: ${user.$id}");
    } catch (e) {
      print("User does not exist in Appwrite, creating a new one...");

      try {
        // Create a new Appwrite user using Firebase's Google info
        await account.create(
          userId: userId,
          email: email,
          password: 'secure-random-password',  // Appwrite requires a password, generate a random one
          name: name,
        );
        print("User successfully created in Appwrite!");
      } catch (e) {
        print("Appwrite user creation failed: ${e.toString()}");
      }
    }
  }
}
