import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mashrooa_takharog/screens/FillYourProfile.dart';
import 'package:mashrooa_takharog/screens/InstructorNavigatorScreen.dart';

import '../screens/StudentNavigatorScreen.dart';

class AuthService{
final FirebaseAuth auth =FirebaseAuth.instance;


//sign in(firebase)
Future<UserCredential> signInWithEmailPassword(String email,password) async{

  try{
    UserCredential userCredential=await auth.signInWithEmailAndPassword(email: email, password: password);
    return userCredential;
  } on FirebaseAuthException catch(e){

    throw Exception(e.code);
  }


}




  Future<void> signInWithGoogle(BuildContext context, String userType) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In cancelled by user')),
        );
        return;
      }

      final GoogleSignInAuthentication? googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken,
      );

      UserCredential result = await firebaseAuth.signInWithCredential(credential);
      User? userDetails = result.user;

      if (userDetails != null) {
        final FirebaseFirestore firestore = FirebaseFirestore.instance;

        final String studentCollection = 'students';
        final String instructorCollection = 'instructors';

        final DocumentSnapshot studentDoc = await firestore
            .collection(studentCollection)
            .doc(userDetails.uid)
            .get();

        final DocumentSnapshot instructorDoc = await firestore
            .collection(instructorCollection)
            .doc(userDetails.uid)
            .get();

        if (studentDoc.exists && userType == "instructor") {
          _showAccessDeniedDialog(context, "instructor");
        } else if (instructorDoc.exists && userType == "student") {
          _showAccessDeniedDialog(context, "student");
        } else if (studentDoc.exists || instructorDoc.exists) {
          final bool isProfileComplete = (studentDoc.exists
              ? studentDoc.get('isProfileComplete')
              : instructorDoc.get('isProfileComplete')) ??
              false;

          if (isProfileComplete) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => userType == "instructor"
                    ? InstructorNavigatorScreen()
                    : NavigatorScreen(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FillYourProfile(
                  userType: userType,
                  email: userDetails.email,
                ),
              ),
            );
          }
        } else {
          final String collectionName = userType == "instructor"
              ? instructorCollection
              : studentCollection;

          await firestore.collection(collectionName).doc(userDetails.uid).set({
            'Google\'s name': userDetails.displayName,
            'email': userDetails.email,
            'isProfileComplete': false,
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FillYourProfile(
                userType: userType,
                email: userDetails.email,
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showAccessDeniedDialog(BuildContext context, String intendedRole) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Access Denied',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'You are not authorized to log in as a/an $intendedRole.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }




//sign up
Future<UserCredential> signUpWithEmailPassword(String email,password) async{
try{
  UserCredential userCredential=await auth.createUserWithEmailAndPassword(email: email, password: password);
return userCredential;
} on FirebaseAuthException catch(e){
  throw Exception(e.code);

}
}

//sign out

Future<void> signOut() async{
  return await auth.signOut();

}

Future<void> resetPassword(String email)async {
try {
await auth.sendPasswordResetEmail(email: email);

} on FirebaseAuthException catch(e){
  throw Exception(e.code);
}

}
}