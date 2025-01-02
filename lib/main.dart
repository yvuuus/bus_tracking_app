import 'package:bus_tracking_app/infoHandler/app_info.dart'; // Importation de choice_page.dart
import 'package:bus_tracking_app/screens/splash_page.dart';
import 'package:bus_tracking_app/themeProvider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart'; // Make sure to import firebase_database for Realtime Database

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDULR1PxZjlXxdnV4-Btx_ZF3WFf1ocsYw", // Your API key
      authDomain: "hafilaty-caf68.firebaseapp.com", // Use the project name
      databaseURL:
          "https://hafilaty-caf68.firebaseio.com", // Firebase Realtime Database URL (if used)
      projectId: "hafilaty-caf68", // Your Firebase project ID
      storageBucket:
          "hafilaty-caf68.appspot.com", // Your Firebase storage bucket
      messagingSenderId: "826481171173", // Sender ID
      appId: "1:826481171173:android:4c3385f6d9d95e28e0d20c", // Your app ID
      measurementId: "",
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'Flutter Demo',
        themeMode: ThemeMode.system,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(), // Définition de la page d'accueil
      ),
    );
  }
}
