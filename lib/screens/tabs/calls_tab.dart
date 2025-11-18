
import 'package:flutter/material.dart';
import 'package:myapp/models/call_history.dart';
import 'package:myapp/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class CallsTab extends StatefulWidget {
  const CallsTab({super.key});

  @override
  State<CallsTab> createState() => _CallsTabState();
}

class _CallsTabState extends State<CallsTab> {
  final ApiService apiService = ApiService();
  late Future<List<CallHistory>> _callHistoryFuture;

  @override
  void initState() {
    super.initState();
    _callHistoryFuture = _fetchCallHistory();
  }

  Future<List<CallHistory>> _fetchCallHistory() async {
    try {
      final data = await apiService.getCallHistory();
      return data.map((json) => CallHistory.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load call history: $e');
    }
  }

  IconData _getCallTypeIcon(CallType type) {
    switch (type) {
      case CallType.incoming:
        return Icons.call_received;
      case CallType.outgoing:
        return Icons.call_made;
      case CallType.missed:
        return Icons.call_missed;
    }
  }

  Color _getCallTypeColor(CallType type) {
    switch (type) {
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
    return FutureBuilder<List<CallHistory>>(
      future: _callHistoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No call history found.'));
        } else {
          final callHistory = snapshot.data!;
          return ListView.builder(
            itemCount: callHistory.length,
            itemBuilder: (context, index) {
              final call = callHistory[index];
              final user = call.user;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePictureUrl),
                ),
                title: Text(user.name),
                subtitle: Row(
                  children: [
                    Icon(
                      _getCallTypeIcon(call.type),
                      color: _getCallTypeColor(call.type),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(call.type.toString().split('.').last),
                  ],
                ),
                trailing: Text(
                  timeago.format(call.timestamp),
                ),
                onTap: () {
                  // Handle call tap
                },
              );
            },
          );
        }
      },
    );
  }
}
