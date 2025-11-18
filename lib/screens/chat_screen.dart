
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/chat_message.dart';
import 'package:myapp/widgets/message_bubble.dart';
import 'package:myapp/widgets/message_composer.dart';

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
  final ImagePicker _picker = ImagePicker();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hey, how are you?',
      type: MessageType.text,
      isSentByMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    ChatMessage(
      text: 'I\'m good, thanks! How about you?',
      type: MessageType.text,
      isSentByMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
    ),
    ChatMessage(
      text: 'Doing great! Ready for our call?',
      type: MessageType.text,
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
          type: MessageType.text,
          isSentByMe: true,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _pickAndSendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            image: File(image.path),
            type: MessageType.image,
            isSentByMe: true,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
  }

  void _startCall(String callType) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video and voice calls can only be initiated from the user\'s profile.')),
      );
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
          MessageComposer(
            onSend: _sendMessage,
            onAttach: _pickAndSendImage,
          ),
        ],
      ),
    );
  }
}
