
import 'dart:io';

enum MessageType { text, image }

class ChatMessage {
  final String? text;
  final File? image;
  final MessageType type;
  final bool isSentByMe;
  final DateTime timestamp;

  ChatMessage({
    this.text,
    this.image,
    required this.type,
    required this.isSentByMe,
    required this.timestamp,
  });
}
