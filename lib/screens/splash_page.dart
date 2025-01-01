import 'package:flutter/material.dart';
import 'package:bus_tracking_app/screens/driver_screens/login_screen_driver.dart';// Import de RoleSelectionScreen

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dégradé violet en fond
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 199, 97, 219),
                  const Color.fromARGB(255, 56, 53, 216),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Image centrée
          Center(
            child: Image.asset(
              'images/first-page-app.png', // Remplacez par le chemin de votre image
              height: 350,
              fit: BoxFit.contain,
            ),
          ),
          // Bouton pour naviguer vers RoleSelectionScreen
          Positioned(
            bottom: 50,
            left: 50,
            right: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 138, 17, 194),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginScreenDriver()),
                );
              },
              child: const Text(
                'Start',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
