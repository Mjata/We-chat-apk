
import 'package:flutter/material.dart';

class CallsTab extends StatelessWidget {
  const CallsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        CallHistoryItem(
          name: 'User 20',
          callType: CallType.outgoing,
          time: 'Today, 11:05 AM',
        ),
        CallHistoryItem(
          name: 'User 21',
          callType: CallType.incoming,
          time: 'Yesterday, 8:30 PM',
        ),
        CallHistoryItem(
          name: 'User 22',
          callType: CallType.missed,
          time: '2 days ago',
        ),
      ],
    );
  }
}

enum CallType { incoming, outgoing, missed }

class CallHistoryItem extends StatelessWidget {
  const CallHistoryItem({
    super.key,
    required this.name,
    required this.callType,
    required this.time,
  });

  final String name;
  final CallType callType;
  final String time;

  IconData get callIcon {
    switch (callType) {
      case CallType.incoming:
        return Icons.call_received;
      case CallType.outgoing:
        return Icons.call_made;
      case CallType.missed:
        return Icons.call_missed;
    }
  }

  Color get callColor {
    switch (callType) {
      case CallType.incoming:
        return Colors.green;
      case CallType.outgoing:
        return Colors.blue;
      case CallType.missed:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage('https://picsum.photos/200/300?random=${name.hashCode}'),
      ),
      title: Text(name),
      subtitle: Row(
        children: [
          Icon(
            callIcon,
            color: callColor,
            size: 16,
          ),
          const SizedBox(width: 5),
          Text(time),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.call),
        onPressed: () {},
      ),
    );
  }
}
