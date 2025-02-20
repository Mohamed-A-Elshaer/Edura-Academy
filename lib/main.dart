import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mashrooa_takharog/firebase_options.dart';
import 'package:mashrooa_takharog/providers/ThemeProvider.dart';
import 'package:mashrooa_takharog/screens/splashScreen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


const supabaseUrl = 'https://svexcgcxhvauionpnyxx.supabase.co';
const supabaseKey = String.fromEnvironment('SUPABASE_KEY');

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
      url: supabaseUrl,
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN2ZXhjZ2N4aHZhdWlvbnBueXh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkxMTIxMTAsImV4cCI6MjA1NDY4ODExMH0.8DGmOsov_xqhXqxNF9QlVLJn2k0L-vxOr-IBlSnRepI"
  );
  runApp(ChangeNotifierProvider(create: (BuildContext context) { return ThemeProvider(); },
  child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GetMaterialApp(
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white, // Ensures light mode background
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
        ),

        dialogTheme: DialogTheme(
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          contentTextStyle: TextStyle(color: Colors.black),
        ),
      ),
    darkTheme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black, // Ensures dark mode background
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
      dialogTheme: DialogTheme(
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    ),
    themeMode: themeProvider.themeMode,
    debugShowCheckedModeBanner: false,
home: SplashScreen(),
    );
  }
}
