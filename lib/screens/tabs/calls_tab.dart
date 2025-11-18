
import 'package:flutter/material.dart';
import 'package:myapp/screens/go_live_screen.dart';

class CallsTab extends StatelessWidget {
  const CallsTab({super.key});

  // Dummy data for call history
  final List<Map<String, dynamic>> callHistory = const [
    {
      'name': 'Alice',
      'type': 'Incoming',
      'time': '11:45 AM',
      'profilePictureUrl': 'https://picsum.photos/200/300?random=4',
      'callTypeIcon': Icons.call_received,
      'color': Colors.green,
    },
    {
      'name': 'Bob',
      'type': 'Outgoing',
      'time': 'Yesterday',
      'profilePictureUrl': 'https://picsum.photos/200/300?random=5',
      'callTypeIcon': Icons.call_made,
      'color': Colors.blue,
    },
    {
      'name': 'Charlie',
      'type': 'Missed',
      'time': '2 days ago',
      'profilePictureUrl': 'https://picsum.photos/200/300?random=6',
      'callTypeIcon': Icons.call_missed,
      'color': Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: callHistory.length,
        itemBuilder: (context, index) {
          final call = callHistory[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(call['profilePictureUrl']!),
            ),
            title: Text(call['name']!),
            subtitle: Row(
              children: [
                Icon(
                  call['callTypeIcon']!,
                  color: call['color']!,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(call['type']!),
              ],
            ),
            trailing: Text(call['time']!),
            onTap: () {
              // Handle call tap
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GoLiveScreen()),
              );
        },
        child: const Icon(Icons.video_call),
      ),
    );
  }
}
