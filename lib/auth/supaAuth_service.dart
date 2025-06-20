import 'package:supabase_flutter/supabase_flutter.dart';

class SupaAuthService{

  static SupabaseClient supabase=Supabase.instance.client;

  Future<AuthResponse> signInWithEmailPasswordSupabase(String email,String password) async{
    return await supabase.auth.signInWithPassword(email: email,password: password);

  }

  Future<AuthResponse> signUpWithEmailPasswordSupabase(String email,String password) async{
return await supabase.auth.signUp(email: email,password: password);

  }



  

 static Future<void> signOut() async{
 await supabase.auth.signOut();

  }




  static Future<String> getCourseCoverImageUrl(String courseName) async {
  try {
    String formattedCourseName= courseName.replaceAll(' ', '_');
  final path = '$formattedCourseName/course_cover.jpg';
  final publicUrl = supabase.storage.from('profiles').getPublicUrl(path);
    print(publicUrl);
  return publicUrl;
  } catch (e) {
  print('Error fetching cover image from Supabase: $e');
  return ''; // fallback
  }
  }

  static Future<void> deleteCourseFolderFromSupabase(String courseName) async {
    try {
      String formattedFolderName = courseName.replaceAll(' ', '_');
      
      final response = await supabase.storage.from('profiles').list(path: formattedFolderName);

      final files = response.map((item) => '$formattedFolderName/${item.name}').toList();

      if (files.isNotEmpty) {
        await supabase.storage.from('profiles').remove(files);
        print('Deleted files from Supabase: $files');
      } else {
        print('No files found in Supabase folder: $formattedFolderName');
      }
    } catch (e) {
      print('Error deleting Supabase folder for $courseName: $e');
    }
  }


  static Future<String?> getSupabaseUserId(String email) async {
    try {
      final response = await supabase
          .from('users')
          .select('id')
          .eq('email', email)
          .single();

      return response['id'] as String?;
    } catch (e) {
      print('Error finding user in Supabase: $e');
      return null;
    }
  }




   Future<void> sendSupabasePasswordRecoveryEmail(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);

      print('Password recovery email sent via Supabase');
    } catch (e) {
      print('Error sending Supabase password recovery email: $e');
    }
  }

  static Future<void> changePasswordInSupabase(String newPassword) async {
    try {
      final supabase = SupaAuthService.supabase;

      final response = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        print('Error: user not updated.');
      } else {
        print('Password updated successfully in Supabase');
      }
    } catch (e) {
      print('Error updating password in Supabase: $e');
    }
  }


}