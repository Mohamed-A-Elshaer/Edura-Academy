import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleSignInSupa {
  static Future<String> addGoogleUserToSupabase(String email) async {
    final supabase = Supabase.instance.client;
    const defaultPassword = 'Default_Password_123'; // Using same password as Appwrite

    try {
      // First try to sign in
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: defaultPassword,
      );

      if (authResponse.user != null) {
        print("User logged in to Supabase: ${authResponse.user!.id}");
        return authResponse.user!.id;
      }
    } catch (signInError) {
      print("Login attempt failed, may be new user: $signInError");
    }

    // If sign in fails, create new account
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: defaultPassword,
      );

      if (response.user != null) {
        print("New user created in Supabase: ${response.user!.id}");
        return response.user!.id;
      } else {
        throw Exception('Supabase account creation failed - no user returned');
      }
    } catch (e) {
      print("Supabase account creation failed: $e");
      rethrow;
    }
  }
}