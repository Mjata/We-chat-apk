
import 'package:flutter/material.dart';
import 'package:myapp/models/chat_message.dart';
// Removed old call screen imports
// import 'package:myapp/screens/video_call_screen.dart';
// import 'package:myapp/screens/voice_call_screen.dart';
import 'package:myapp/screens/call_screen.dart'; // Import the unified call screen
import 'package:myapp/services/api_service.dart';
import 'package:myapp/widgets/message_bubble.dart';
import 'package:myapp/widgets/message_composer.dart';
import 'dart:developer' as developer;

class ChatScreen extends StatefulWidget {
  final String name;
  final String profilePictureUrl;

  const ChatScreen({
    super.key,
    required this.name,
    required this.profilePictureUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();

  // Dummy data for chat messages
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hey, how are you?',
      isSentByMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    ChatMessage(
      text: 'I\'m good, thanks! How about you?',
      isSentByMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
    ),
    ChatMessage(
      text: 'Doing great! Ready for our call?',
      isSentByMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  void _sendMessage(String text) {
    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          text: text,
          isSentByMe: true,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _startCall(String callType) async {
    try {
      // Use a placeholder for user IDs for now
      const currentUserId = "current_user_id_placeholder";
      const calleeUserId = "callee_id_placeholder";

      final token = await _apiService.getLiveKitToken(calleeUserId, currentUserId);

      if (token != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(
              roomName: calleeUserId,
              token: token,
              calleeName: widget.name, // Use the name from the chat screen
            ),
          ),
        );
      } else {
        throw Exception("Could not get a valid call token from the server.");
      }
    } on Exception catch (e) {
      developer.log("Failed to start call: ", error: e);
      String errorMessage = "Failed to start call. Please try again.";
      if (e.toString().contains("402")) {
        errorMessage = "You don't have enough coins for this call.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.profilePictureUrl),
            ),
            const SizedBox(width: 10),
            Text(widget.name),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _startCall('video'),
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _startCall('voice'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: _messages[index]);
              },
            ),
          ),
          MessageComposer(onSend: _sendMessage),
        ],
      ),
    );
  }
}
