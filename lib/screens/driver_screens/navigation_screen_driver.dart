import 'package:flutter/material.dart';
import 'package:bus_tracking_app/screens/driver_screens/profile_screen_driver.dart';
import 'package:bus_tracking_app/screens/driver_screens/inbox_screen_driver.dart';
import 'package:bus_tracking_app/screens/driver_screens/schedule_screen_driver.dart';
import 'package:bus_tracking_app/screens/main_page.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  // State to manage the index of the selected screen
  int _selectedIndex = 0;

  // List of screens to navigate between
  List<Widget> screens = [
    const MainScreen(),
    const ScheduleScreenDriver(),
    const InboxScreenDriver(),
    const ProfileScreenDriver(),
  ];

  // Method to handle the navigation state update
  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            indicatorColor: Colors
                .white, // Set the background color of the selected item to white
          ),
        ),
        child: NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.white),
              label: "",
              selectedIcon: Icon(Icons.home, color: Colors.purpleAccent),
            ),
            NavigationDestination(
              icon: Icon(Icons.schedule_outlined, color: Colors.white),
              label: "",
              selectedIcon: Icon(Icons.schedule, color: Colors.purpleAccent),
            ),
            NavigationDestination(
              icon: Icon(Icons.inbox_outlined, color: Colors.white),
              label: "",
              selectedIcon: Icon(Icons.inbox, color: Colors.purpleAccent),
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined, color: Colors.white),
              label: "",
              selectedIcon: Icon(Icons.person, color: Colors.purpleAccent),
            ),
          ],
          onDestinationSelected:
              _onDestinationSelected, // Use the method to update the selected index
          backgroundColor: Colors.purple.shade700,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          selectedIndex: _selectedIndex,
        ),
      ),
    );
  }
}
