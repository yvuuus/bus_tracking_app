import 'package:bus_tracking_app/infoHandler/app_info.dart'; // Importation de choice_page.dart
import 'package:bus_tracking_app/screens/splash_page.dart';
import 'package:bus_tracking_app/themeProvider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  debugPrint = (String? message, {int? wrapWidth}) {};
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
