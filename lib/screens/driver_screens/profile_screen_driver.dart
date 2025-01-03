import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver Profile',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const ProfileScreenDriver(),
    );
  }
}

class ProfileScreenDriver extends StatefulWidget {
  const ProfileScreenDriver({super.key});

  @override
  State<ProfileScreenDriver> createState() => _ProfileScreenDriverState();
}

class _ProfileScreenDriverState extends State<ProfileScreenDriver> {
  late DatabaseReference _databaseRef;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _databaseRef =
          FirebaseDatabase.instance.ref("drivers/${_currentUser!.uid}");
    } else {
      // Handle the case where there is no authenticated user
      print("No user is currently signed in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          width: size.width,
          height: size.height,
          child: _currentUser == null
              ? Center(child: Text("No user is currently signed in."))
              : StreamBuilder(
                  stream: _databaseRef.onValue,
                  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      print("Loading data...");
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      print("Error loading data: ${snapshot.error}");
                      return const Center(child: Text("Error loading data"));
                    }
                    if (!snapshot.hasData || !snapshot.data!.snapshot.exists) {
                      print("Driver data not found.");
                      return const Center(
                          child: Text("Driver data not found."));
                    }

                    final data =
                        snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    final driverId = data['id']?.toString() ?? "Driver ID";
                    final email =
                        data['email']?.toString() ?? "driver.email@example.com";
                    final carName =
                        data['carName']?.toString() ?? "Vehicle Name";
                    final carPlateNum =
                        data['carPlateNum']?.toString() ?? "Plate Number";
                    final carType = data['carType']?.toString() ?? "Car Type";

                    print("Driver data loaded: $data");

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top Section: Profile Picture and Email
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.purple.shade100,
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.purple,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Work Details Section
                        Expanded(
                          child: ListView(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            children: [
                              ProfileDetailCard(
                                title: "Driver ID",
                                value: driverId,
                              ),
                              ProfileDetailCard(
                                title: "Vehicle",
                                value: carName,
                              ),
                              ProfileDetailCard(
                                title: "Plate Number",
                                value: carPlateNum,
                              ),
                              ProfileDetailCard(
                                title: "Car Type",
                                value: carType,
                              ),
                            ],
                          ),
                        ),

                        // Logout Section
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Perform any necessary local logout action, such as clearing local storage
                                  Navigator.pushReplacementNamed(context,
                                      '/login'); // Navigate to the login screen
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14.0,
                                    horizontal: 20.0,
                                  ),
                                  shadowColor: Colors.grey.withOpacity(0.5),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  "Logout",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "App Version: 1.0.0",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class ProfileDetailCard extends StatelessWidget {
  final String title;
  final String value;

  const ProfileDetailCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.purple.shade100,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
