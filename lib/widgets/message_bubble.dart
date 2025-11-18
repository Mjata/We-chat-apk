
import 'package:flutter/material.dart';
import 'package:myapp/models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isSentByMe = message.isSentByMe;
    final alignment = isSentByMe ? Alignment.centerRight : Alignment.centerLeft;
    final color = isSentByMe ? Colors.blue : Colors.grey[300];
    final textColor = isSentByMe ? Colors.white : Colors.black;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: _buildMessageContent(textColor),
      ),
    );
  }

  Widget _buildMessageContent(Color textColor) {
    if (message.type == MessageType.image && message.image != null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 200,
          maxHeight: 200,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.file(
            message.image!,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (message.text != null) {
      return Text(
        message.text!,
        style: TextStyle(color: textColor),
      );
    } else {
      return const SizedBox.shrink(); // Should not happen
    }
  }
}
