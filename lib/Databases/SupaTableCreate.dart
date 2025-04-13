import 'package:supabase_flutter/supabase_flutter.dart';

class SupaTableCreate{


 static Future<void> insertSupaUserDatabase(String? name, String? email, String? userType,String? userId) async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('users').insert({
      'id': userId,
      'name': name,
      'email': email,
      'user_type': userType,
    });

    if (response.error != null) {
      print('Error inserting user into supabase DB: ${response.error!.message}');
    } else {
      print('User added to supabase DB successfully');
    }
  }



static Future<String?> getCurrentUserId() async {
   final SupabaseClient supabase = Supabase.instance.client;
   try {
     final user = supabase.auth.currentUser;
     return user?.id; // إرجاع الـ userId
   } catch (e) {
     print("Error getting Supabase user ID: $e");
     return null;
   }
 }



 static Future<void> updateUserInSupabaseDB(String userId,  String? newEmail, String? name) async {
   final supabase = Supabase.instance.client;
try {
  // 🔹 Step 1: Fetch current user data from Supabase
  final supabaseResponse = await supabase
      .from('users')
      .select('email, name') // ✅ Fetch only needed fields
      .eq('id', userId)
      .single();

  String currentEmail = supabaseResponse['email'];
  String currentFullName = supabaseResponse['name'];

  // 🔹 Step 2: Ensure only changed fields are updated in Supabase
  Map<String, dynamic> updateData = {};

  if (newEmail != null && newEmail.isNotEmpty && newEmail != currentEmail) {
    updateData['email'] = newEmail; // ✅ Update only if changed
  }

  if (name != null && name.isNotEmpty && name != currentFullName) {
    updateData['name'] = name; // ✅ Update only if changed
  }

  if (updateData.isNotEmpty) {
    // ✅ Step 3: Update Supabase only if there are changes
    await supabase.from('users').update(updateData).eq('id', userId);
  }

  print('Supabase\'s DB updated Succesfully!');
}
catch (e) {
     throw Exception("Failed to update Supabase DB: $e");
   }
 }

}