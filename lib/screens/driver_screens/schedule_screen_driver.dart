import 'package:flutter/material.dart';

class ScheduleScreenDriver extends StatefulWidget {
  const ScheduleScreenDriver({super.key});

  @override
  State<ScheduleScreenDriver> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreenDriver> {
  // Initialize the schedule with your provided data
  final List<Map<String, dynamic>> schedule = [
    {
      "departure": "Oued Romane",
      "destination": "Baba Hassen",
      "timing": "08:00 - 08:30",
      "done": false
    },
    {
      "departure": "Baba Hassen",
      "destination": "Douera",
      "timing": "09:00 - 09:40",
      "done": false
    },
    {
      "departure": "Douera",
      "destination": "Mahemla",
      "timing": "10:00 - 10:40",
      "done": false
    },
    {
      "departure": "Mahemla",
      "destination": "Sidi Abdellah",
      "timing": "11:00 - 11:45",
      "done": false
    },
    {
      "departure": "Sidi Abdellah",
      "destination": "Zeralda",
      "timing": "12:00 - 12:30",
      "done": false
    },
    {
      "departure": "Zralda",
      "destination": "Staoueli",
      "timing": "13:00 - 13:35",
      "done": false
    },
    {
      "departure": "Staoueli",
      "destination": "Ain Benian",
      "timing": "14:00 - 14:45",
      "done": false
    },
    {
      "departure": "Ain Benian",
      "destination": "El Hammamet",
      "timing": "15:00 - 15:40",
      "done": false
    },
    {
      "departure": "El Hammamet",
      "destination": "Rais Hamidou",
      "timing": "16:00 - 16:30",
      "done": false
    },
    {
      "departure": "Rais Hamidou",
      "destination": "Bouzereah",
      "timing": "17:00 - 17:45",
      "done": false
    },
    {
      "departure": "Bouzereah",
      "destination": "Ben Aknoun",
      "timing": "09:00 - 09:30",
      "done": false
    },
    {
      "departure": "Ben Aknoun",
      "destination": "Baba Hassen",
      "timing": "10:00 - 10:40",
      "done": false
    },
  ];

  // Initial selected day
  String selectedDay = "Sunday";

  @override
  Widget build(BuildContext context) {
    // Get the size of the screen
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      // AppBar with title
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: Colors.purple.shade600, // AppBar background color
      ),
      body: SafeArea(
        child: Container(
          color: const Color.fromARGB(
              255, 255, 254, 255), // Background color of the main container
          width: size.width,
          height: size.height,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0), // Padding for spacing
              ),
              // DropdownButton to select the day of the week
              DropdownButton<String>(
                value: selectedDay,
                dropdownColor: Colors
                    .purple.shade100, // Background color of the dropdown menu
                style: const TextStyle(
                    color: Color.fromARGB(
                        255, 0, 0, 0)), // Text style for dropdown items
                items: [
                  "Sunday",
                  "Monday",
                  "Tuesday",
                  "Wednesday",
                  "Thursday",
                  "Friday",
                  "Saturday"
                ].map<DropdownMenuItem<String>>((String day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDay = newValue!;
                  });
                },
              ),
              // Display "Rest day" text for Friday and Saturday
              if (selectedDay == "Friday" || selectedDay == "Saturday") ...[
                Expanded(
                  child: Center(
                    child: const Text(
                      'Rest day',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ] else ...[
                // Expanded widget to hold the list of schedule items
                Expanded(
                  child: ListView.builder(
                    itemCount: schedule.length,
                    itemBuilder: (context, index) {
                      final spot = schedule[index];
                      // Hide the done items
                      if (spot['done']) {
                        return SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.purple
                                .shade100, // Background color of the container
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            // Display departure, destination, and timing
                            title: Text(
                              'Departure: ${spot['departure']}\nDestination: ${spot['destination']}\nTiming: ${spot['timing']}',
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16),
                            ),
                            // Checkbox to mark the item as done
                            trailing: Checkbox(
                              value: spot['done'],
                              onChanged: (bool? value) {
                                setState(() {
                                  spot['done'] = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
