import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/auth/supaAuth_service.dart';
import 'package:mashrooa_takharog/screens/StudentOrInstructor.dart';

import '../auth/Appwrite_service.dart';

class NewPass extends StatefulWidget {
  final String phoneNumber;
  final String uid;

  const NewPass({super.key, required this.phoneNumber, required this.uid});

  @override
  _NewPassState createState() => _NewPassState();
}

class _NewPassState extends State<NewPass> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _isPasswordHidden = true;

  String? getCurrentUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    print(user?.email);
    return user?.email;
  }


  Future<String?> getOldPasswordFromSupabase(String email) async {
    try {
      final response = await SupaAuthService.supabase
          .from('users')
          .select('word')
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        print('No user found with this email.');
        return null;
      }

      final word = response['word'] as String?;
      return word;
    } catch (e) {
      print('Error retrieving old password: $e');
      return null;
    }
  }

  Future<bool> loginToSupabase(String email, String oldPassword) async {
    try {
      final supabase = SupaAuthService.supabase;

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );

      if (response.session == null || response.user == null) {
        print('Error: No session or user returned.');
        return false;
      }

      print('Successfully signed in to Supabase.');
      return true;
    } catch (e) {
      print('Error signing in to Supabase: $e');
      return false;
    }
  }


  Future<bool> loginToAppwrite(String email, String oldPassword) async {
    print(email);
    print(oldPassword);
    try {
      await Appwrite_service.account.createEmailPasswordSession(
        email: email,
        password: oldPassword,
      );
      return true;
    } catch (e) {
      print('Error signing in to Appwrite: $e');
      return false;
    }
  }





  Future<void> changePasswordInAppwrite(String email ,String oldPassword ,String newPassword) async {
    try {
      await Appwrite_service.account.createEmailPasswordSession(
        email: email,
        password: oldPassword,
      );
      await Appwrite_service.account.updatePassword(
        password: newPassword,
      );

      print('Password updated successfully in Appwrite');
    } catch (e) {
      print('Error updating password in Appwrite: $e');
    }
  }

  Future<void> changePassword() async {
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    RegExp passwordRegExp = RegExp(r'^(?=.*[A-Z])[A-Za-z0-9]{8,}$');

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill both password fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    if (!passwordRegExp.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Password must be at least 8 characters long, contain at least one uppercase letter, and include only letters and numbers')),
      );
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      String? email = getCurrentUserEmail();

      if (email == null) {
        print('No Firebase user email found.');
        return;
      }

      String? oldPassword = await getOldPasswordFromSupabase(email);

      if (oldPassword == null) {
        print('Failed to retrieve old password from Supabase.');
        return;
      }

      /// Step 1: Log in to Supabase
      bool supabaseLoggedIn = await loginToSupabase(email, oldPassword);
      if (!supabaseLoggedIn) {
        print('Failed to login to Supabase.');
        return;
      }
      /// Step 4: Change password in Firebase
      if (user != null && user.uid == widget.uid) {
        await user.updatePassword(password);
        print('Password updated successfully in Firebase.');
      } else {
        print('Firebase user mismatch or null.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found or UID mismatch.')),
        );
        return;
      }
changePasswordInAppwrite(email, oldPassword, password);
      SupaAuthService.changePasswordInSupabase(password);

      /// Step 5: Update password in Supabase DB (custom users table)
      await SupaAuthService.supabase
          .from('users')
          .update({'word': password})
          .eq('email', email);
      print('Password updated successfully in Supabase DB.');

      /// Step 6: Sign out from all services
      await FirebaseAuth.instance.signOut();
      await SupaAuthService.signOut();

      try {
        final sessions = await Appwrite_service.account.listSessions();
        if (sessions.sessions.isNotEmpty) {
          await Appwrite_service.account.deleteSession(sessionId: 'current');
          print('Appwrite session deleted successfully.');
        }
      } catch (e) {
        print('Error deleting Appwrite session: $e');
      }

      /// Step 7: Show success and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentOrInstructor()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Password',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Create Your New Password',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: 320,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 1,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordHidden = !_isPasswordHidden;
                      });
                    },
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                ),
                obscureText: _isPasswordHidden,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: 320,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 1,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  hintText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordHidden = !_isPasswordHidden;
                      });
                    },
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                ),
                obscureText: _isPasswordHidden,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24)),
                      child: Icon(
                        size: 30,
                        Icons.arrow_forward,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}