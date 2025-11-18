
import 'package:flutter/material.dart';
import 'package:myapp/models/conversation.dart';
import 'package:myapp/screens/chat_screen.dart';
import 'package:myapp/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageTab extends StatefulWidget {
  const MessageTab({super.key});

  @override
  State<MessageTab> createState() => _MessageTabState();
}

class _MessageTabState extends State<MessageTab> {
  final ApiService apiService = ApiService();
  late Future<List<Conversation>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _conversationsFuture = _fetchConversations();
  }

  Future<List<Conversation>> _fetchConversations() async {
    try {
      final data = await apiService.getConversations();
      return data.map((json) => Conversation.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load conversations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Conversation>>(
      future: _conversationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No conversations found.'));
        } else {
          final conversations = snapshot.data!;
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final participant = conversation.participant;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(participant.profilePictureUrl),
                ),
                title: Text(participant.name),
                subtitle: Text(conversation.lastMessage),
                trailing: Text(
                  timeago.format(conversation.lastMessageTimestamp),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        name: participant.name,
                        profilePictureUrl: participant.profilePictureUrl,
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
