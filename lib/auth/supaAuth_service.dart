import 'package:supabase_flutter/supabase_flutter.dart';

class SupaAuthService{

  final SupabaseClient _supabase=Supabase.instance.client;

  Future<AuthResponse> signInWithEmailPasswordSupabase(String email,String password) async{
    return await _supabase.auth.signInWithPassword(email: email,password: password);

  }

  Future<AuthResponse> signUpWithEmailPasswordSupabase(String email,String password) async{
return await _supabase.auth.signUp(email: email,password: password);

  }

  Future<void> signOut() async{
 await _supabase.auth.signOut();

  }

}