import 'package:flutter/cupertino.dart';
import 'package:mashrooa_takharog/Databases/AppwriteTableCreate.dart';
import 'package:mashrooa_takharog/auth/Appwrite_service.dart';
import 'package:mashrooa_takharog/auth/supaAuth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:appwrite/appwrite.dart';


class SupabaseAppwriteEmailUpdate {



 static Future<void> updateSupabaseEmail(String newEmail) async {

    try {
      final response = await SupaAuthService.supabase.auth.updateUser(UserAttributes(email: newEmail));

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


   try {


     await Appwrite_service.account.updateEmail(
       email: newEmail,
       password: password!,
     );
     print("✅ تم تحديث البريد الإلكتروني بنجاح: $newEmail");
   } catch (e) {
     print("❌ خطأ أثناء التحديث: $e");
   }
 }
 }





