
import 'package:myapp/models/user.dart';

class Conversation {
  final String id;
  final User participant;
  final String lastMessage;
  final DateTime lastMessageTimestamp;

  Conversation({
    required this.id,
    required this.participant,
    required this.lastMessage,
    required this.lastMessageTimestamp,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      participant: User.fromJson(json['participant']),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTimestamp: json['lastMessageTimestamp'] != null
          ? DateTime.parse(json['lastMessageTimestamp'])
          : DateTime.now(),
    );
  }
}
