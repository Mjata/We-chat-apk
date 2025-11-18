
import 'package:flutter/material.dart';
import 'package:myapp/screens/chat_screen.dart';

class MessageTab extends StatelessWidget {
  const MessageTab({super.key});

  // Dummy data for chat list
  final List<Map<String, dynamic>> chats = const [
    {
      'name': 'Alice',
      'lastMessage': 'Hey, how are you?',
      'time': '10:30 AM',
      'profilePictureUrl': 'https://picsum.photos/200/300?random=1',
    },
    {
      'name': 'Bob',
      'lastMessage': 'See you tomorrow!',
      'time': 'Yesterday',
      'profilePictureUrl': 'https://picsum.photos/200/300?random=2',
    },
    {
      'name': 'Charlie',
      'lastMessage': 'Thanks for the help!',
      'time': '2 days ago',
      'profilePictureUrl': 'https://picsum.photos/200/300?random=3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(chat['profilePictureUrl']!),
          ),
          title: Text(chat['name']!),
          subtitle: Text(chat['lastMessage']!),
          trailing: Text(chat['time']!),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  name: chat['name']!,
                  profilePictureUrl: chat['profilePictureUrl']!,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
