import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfileScreenDriver extends StatefulWidget {
  const ProfileScreenDriver({super.key});

  @override
  State<ProfileScreenDriver> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreenDriver> {
  String? email;
  String driverName = "Driver Name";
  String carName = "Vehicle Name";
  String carPlateNum = "Plate Number";
  String carType = "Car Type";

  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref("drivers/driverId1");

  @override
  void initState() {
    super.initState();
    _fetchDriverData();
  }

  void _fetchDriverData() async {
    final snapshot = await _databaseRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        driverName = data['name'];
        email = data['email'];
        carName = data['carName'];
        carPlateNum = data['carPlateNum'];
        carType = data['carType'];
      });
    } else {
      debugPrint("Driver data not found.");
    }
  }

  void _updateDriverData(String field, String value) async {
    await _databaseRef.update({field: value});
  }

  void _editName() {
    TextEditingController nameController =
        TextEditingController(text: driverName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Name"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  driverName = nameController.text.trim();
                });
                _updateDriverData("name", driverName);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          width: size.width,
          height: size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Section: Profile Picture and Name
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          driverName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.purple,
                          ),
                          onPressed: _editName,
                        ),
                      ],
                    ),
                    Text(
                      email ?? "driver.email@example.com",
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
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
                        Navigator.pushReplacementNamed(
                            context, '/login'); // Navigate to the login screen
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
                        style: TextStyle(color: Colors.white, fontSize: 16),
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
