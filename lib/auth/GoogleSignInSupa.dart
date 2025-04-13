
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleSignInSupa {

  static Future<String> addGoogleUserToSupabase(String email, String password) async {
    final supabase = Supabase.instance.client;

    try {
      // Check if the user already exists
      final existingUser = await supabase.auth.signInWithPassword(
        email: email,
        password: password, // Default password, since Supabase requires it
      );

      if (existingUser.user != null) {
        print("User already exists in Supabase, returning user ID.");
        return existingUser.user!.id;
      }
    } catch (e) {
      // User does not exist, so we proceed to create a new one
      print("User not found in Supabase, creating a new one...");
    }

    // If the user does not exist, create a new account
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      print("New user created in Supabase.");
      return response.user!.id;
    } else {
      throw Exception('Failed to create Supabase account');
    }
  }
}