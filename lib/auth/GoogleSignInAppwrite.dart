import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:mashrooa_takharog/auth/Appwrite_service.dart';

class GoogleSignInAppwrite {
  static Future<String?> appWriteGoogleSignIn(String email) async {
    const defaultPassword = 'Default_Password_123'; // Using specified password

    try {
      // First try to sign in with email/password
      try {
        await Appwrite_service.account.createEmailPasswordSession(
          email: email,
          password: defaultPassword,
        );
        User user = await Appwrite_service.account.get();
        print("User logged in to Appwrite: ${user.$id}");
        return user.$id;
      } catch (signInError) {
        print("Login attempt failed, may be new user: $signInError");
      }

      // If login fails, create new account
      User newUser = await Appwrite_service.account.create(
        userId: ID.unique(),
        email: email,
        password: defaultPassword,
      );

      // Create session for new user
      await Appwrite_service.account.createEmailPasswordSession(
        email: email,
        password: defaultPassword,
      );

      print("New user created in Appwrite: ${newUser.$id}");
      return newUser.$id;
    } catch (e) {
      print("Appwrite authentication failed: ${e.toString()}");
      return null;
    }
  }
}