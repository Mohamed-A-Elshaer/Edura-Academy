import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mashrooa_takharog/auth/auth_service.dart';
import 'package:mashrooa_takharog/auth/supaAuth_service.dart';
import 'package:mashrooa_takharog/screens/EditProfileScreen.dart';
import 'package:mashrooa_takharog/screens/HomeScreen.dart';
import 'package:mashrooa_takharog/screens/SignInScreen.dart';
import 'package:mashrooa_takharog/screens/ThemeModePage.dart';
import 'package:mashrooa_takharog/screens/splashScreen.dart';
import 'package:mashrooa_takharog/widgets/CustomProfileElement.dart';
import 'package:mashrooa_takharog/widgets/ProfileAvatar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget{
  String? userType;
   ProfileScreen({super.key, this.userType});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? nickname = "Loading...";
  String? email = "Loading...";
  String? _imageUrl;
  final supabase = Supabase.instance.client;
final supaAuth=SupaAuthService();


  @override
  void initState() {
    super.initState();
    _fetchUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProfileAvatar();
    });
  }
  Future<void> _fetchUserData() async {
    String collection = widget.userType == 'student' ? 'students' : 'instructors';
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('Current User ID: ${user.uid}');
        print('Fetching data from collection: $collection');

        final doc = await FirebaseFirestore.instance.collection(collection).doc(user.uid).get();
        if (doc.exists) {
          print('Document data: ${doc.data()}');
          setState(() {
            nickname = doc.data()?['nickName'] ?? "No Nickname";
            email = user.email ?? "No Email";
          });
        } else {
          print('Document does not exist in $collection');
          setState(() {
            nickname = "No Nickname Found";
            email = "No Email Found";
          });
        }
      } else {
        print('No user currently signed in');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        nickname = "Error loading data";
        email = "Error loading data";
      });
    }
  }


  Future<void> _fetchProfileAvatar() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final imagePath = '$userId/profile'; // Remove leading "/"

    try {
      // Check if the file exists in Supabase Storage
      final files = await supabase.storage.from('profiles').list(path: userId);
      final fileExists = files.any((file) => file.name == 'profile');

      if (!fileExists) {
        print("No avatar found, using default.");
        setState(() {
          _imageUrl = null; // Ensure it falls back to default
        });
        return;
      }

      // If file exists, generate the URL
      String imageUrl = supabase.storage.from('profiles').getPublicUrl(imagePath);
      imageUrl = Uri.parse(imageUrl).replace(queryParameters: {
        't': DateTime.now().millisecondsSinceEpoch.toString()
      }).toString();

      setState(() {
        _imageUrl = imageUrl;
      });

      print("Avatar loaded successfully: $imageUrl");
    } catch (e) {
      print("Error fetching avatar: $e");
      setState(() {
        _imageUrl = null;
      });
    }
  }




  void logout(BuildContext context) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final auth=AuthService();
    auth.signOut();
   await supaAuth.signOut();
Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SplashScreen()));
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F9FF),
      appBar: AppBar(

        title: Text('Profile',style: TextStyle(color: Color(0xff202244),fontFamily: 'Jost',fontSize: 21,fontWeight: FontWeight.w600),),
        backgroundColor:Color(0xffF5F9FF) ,

      ),
      body: Center(
        child: Container(
          height: double.infinity,
          width: 330,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],

          ),
          child: SingleChildScrollView(
            child: Column(
              children: [


                ProfileAvatar(imageUrl: _imageUrl,
                    onUpload: (imageUrl) async{
               setState(() {
                 _imageUrl=imageUrl;
               });
               final userId=supabase.auth.currentUser!.id;
await supabase.from('profiles').update({'avatar_url':imageUrl}).eq('id', userId);
             }),
               Text(nickname ?? "Loading...",style: TextStyle(fontFamily: 'Jost',fontSize: 24,fontWeight: FontWeight.w600,color: Color(0xff202244)),),
                Text(email ?? "Loading...",style: TextStyle(fontFamily: 'Mulish',fontSize: 13,fontWeight: FontWeight.w700,color: Color(0xff545454)),),
              SizedBox(height: 25,),
CustomProfileElement(text: 'Edit Profile', icon: Icons.person_2_outlined,onTap: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EditProfileScreen()));},),
                SizedBox(height: 25,),
                CustomProfileElement(text: 'Payment Option', icon: Icons.payment,onTap: (){},),
                SizedBox(height: 25,),
                CustomProfileElement(text: 'Notification', icon: Icons.notifications,onTap: (){},),
                SizedBox(height: 25,),
                CustomProfileElement(text: 'Security', icon: Icons.security,onTap: (){},),
                SizedBox(height: 25,),
                CustomProfileElement(text: 'Language', icon: Icons.language,onTap: (){},),
                SizedBox(height: 25,),
                CustomProfileElement(text: 'Dark mode', icon: Icons.dark_mode,onTap: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ThemeModePage()));}),
                SizedBox(height: 25,),
                CustomProfileElement(text: 'Help Center', icon: Icons.help_center,onTap: (){},),
                SizedBox(height: 25,),
                CustomProfileElement(text: 'Logout', icon: Icons.power_settings_new,onTap: (){logout(context);},),

              ],

            ),
          ),
        ),
      ),

     /* bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 0) { // If "Profile" tab is tapped
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Homepage(), // Navigate to ProfileScreen
              ),
            );
          }
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'My Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border_outlined), label: 'Bookmarks'),
          BottomNavigationBarItem(
              icon: Icon(Icons.payment), label: 'Transaction'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile',),
        ],
      ),*/
    );
  }
}