
enum CallType { incoming, outgoing, missed }

class Call {
  final String name;
  final String profilePictureUrl;
  final CallType callType;
  final DateTime timestamp;

  Call({
    required this.name,
    required this.profilePictureUrl,
    required this.callType,
    required this.timestamp,
  });
}
