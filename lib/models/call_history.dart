
import 'package:myapp/models/user.dart';

enum CallType { incoming, outgoing, missed }

class CallHistory {
  final String id;
  final User user;
  final DateTime timestamp;
  final CallType type;
  final int durationInSeconds;

  CallHistory({
    required this.id,
    required this.user,
    required this.timestamp,
    required this.type,
    required this.durationInSeconds,
  });

  factory CallHistory.fromJson(Map<String, dynamic> json) {
    return CallHistory(
      id: json['_id'] ?? '',
      user: User.fromJson(json['user']), // Assuming 'user' field is populated
      timestamp: DateTime.parse(json['timestamp']),
      type: _parseCallType(json['type']),
      durationInSeconds: json['durationInSeconds'] ?? 0,
    );
  }

  static CallType _parseCallType(String? type) {
    switch (type) {
      case 'incoming':
        return CallType.incoming;
      case 'outgoing':
        return CallType.outgoing;
      case 'missed':
        return CallType.missed;
      default:
        return CallType.missed; // Default to missed if unknown
    }
  }
}
