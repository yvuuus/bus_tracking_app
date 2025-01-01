import 'package:flutter/material.dart';

class ScheduleScreenDriver extends StatefulWidget {
  const ScheduleScreenDriver({super.key});

  @override
  State<ScheduleScreenDriver> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreenDriver> {
  final List<Map<String, dynamic>> schedule = [
    {"spot": "Draria", "timing": "8:00 - 10:00 - 14:20 - 16:00 - 18:20"},
    {"spot": "Ben Aknoun", "timing": "8:30 - 10:10 - 14:10 - 16:30 - 18:30"},
    {"spot": "Dely Brahim", "timing": "8:05 - 10:40 - 14:40 - 16:05 - 18:40"},
    {"spot": "Didouch", "timing": "8:00 - 10:00 - 14:20 - 16:00 - 18:20"},
    {"spot": "Alger centre", "timing": "8:00 - 10:00 - 14:20 - 16:00 - 18:20"},
    {"spot": "Rahmania", "timing": "8:00 - 10:00 - 14:20 - 16:00 - 18:20"},
    {"spot": "Sidi Abdallah", "timing": "8:00 - 10:00 - 14:20 - 16:00 - 18:20"},
  ];

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
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Schedule",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: schedule.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey.shade400,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    final spot = schedule[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  spot['spot'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  spot['timing'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
