import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mashrooa_takharog/firebase_options.dart';
import 'package:mashrooa_takharog/providers/ThemeProvider.dart';
import 'package:mashrooa_takharog/screens/splashScreen.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
