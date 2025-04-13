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
      final response = await supabase.storage.from('profiles').list(path: courseName);

      final files = response.map((item) => '$courseName/${item.name}').toList();

      if (files.isNotEmpty) {
        await supabase.storage.from('profiles').remove(files);
        print('Deleted files from Supabase: $files');
      } else {
        print('No files found in Supabase folder: $courseName');
      }
    } catch (e) {
      print('Error deleting Supabase folder for $courseName: $e');
    }
  }


}