import 'package:flutter/material.dart';

class InboxScreenDriver extends StatefulWidget {
  const InboxScreenDriver({super.key});

  @override
  State<InboxScreenDriver> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<InboxScreenDriver> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        backgroundColor: Colors.purple.shade600,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          width: size.width,
          height: size.height,
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: 2, // Adjust based on the number of messages
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey.shade400,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: const Offset(0, 2), // Shadow position
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Admin Icon with Shadow
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.purple.shade600,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 6,
                                    offset:
                                        const Offset(0, 2), // Shadow position
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Message Content with Shadow
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Admin',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Good evening Sir we would like to inform you t..',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2, // Limit message to two lines
                                  ),
                                ],
                              ),
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
