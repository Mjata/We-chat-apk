
import 'package:flutter/material.dart';

class MessageTab extends StatelessWidget {
  const MessageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5, // Let's show 5 dummy conversations
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage('https://picsum.photos/200/300?random=${index + 10}'), // Offset the random seed
          ),
          title: Text('User ${index + 10}'),
          subtitle: const Text('This was the last message...'),
          trailing: const Text('10:30 AM'),
          onTap: () {},
        );
      },
    );
  }
}
