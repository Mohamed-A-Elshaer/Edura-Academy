import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:appwrite/appwrite.dart';


class SupabaseAppwriteEmailUpdate {



 static Future<void> updateSupabaseEmail(String newEmail) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.auth.updateUser(UserAttributes(email: newEmail));

      if (response.user != null) {
        print("✅ Supabase Email updated successfully: ${response.user!.email}");
      } else {
        print("❌ Failed to update email in Supabase.");
      }
    } on AuthException catch (e) {
      print("❌ Supabase Auth Error: ${e.message}");
    } catch (e) {
      print("❌ Unexpected error in Supabase: $e");
    }
  }



 static Future<void> updateAppwriteEmail(String newEmail,String? password) async {
   final client = Client()
     .setEndpoint('https://cloud.appwrite.io/v1')
     .setProject('67ac8356002648e5b7e9')
   .setSelfSigned(status: true);
   final account = Account(client);

   try {


     await account.updateEmail(
       email: newEmail,
       password: password!,
     );
     print("✅ تم تحديث البريد الإلكتروني بنجاح: $newEmail");
   } catch (e) {
     print("❌ خطأ أثناء التحديث: $e");
   }
 }
 }





