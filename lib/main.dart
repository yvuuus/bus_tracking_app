import 'package:bus_tracking_app/infoHandler/app_info.dart'; // Importation de choice_page.dart
import 'package:bus_tracking_app/screens/splash_page.dart';
import 'package:bus_tracking_app/themeProvider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart'; // Make sure to import firebase_database
import 'firebase_options.dart'; // Import the generated firebase_options.dart file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Firebase with the generated options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions
          .currentPlatform, // Automatically uses the right options based on platform
    );
    print("Firebase Initialized Successfully");
    runApp(MyApp());
  } catch (e) {
    print("Firebase Initialization Error: $e"); // Log any errors
  }
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
        home: SplashScreen(), // Define the home page here
      ),
    );
  }
}
