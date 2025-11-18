
import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/screens/call_screen.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/widgets/user_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ApiService apiService = ApiService();

  // Dummy data for users
  final List<User> users = [
    User(
      name: 'Angel',
      bio: 'Life is a beautiful journey.',
      profilePictureUrl: 'https://picsum.photos/seed/picsum/200/300',
      isOnline: true,
      isInCall: false,
    ),
    User(
      name: 'Brenda',
      bio: 'Chasing my dreams.',
      profilePictureUrl: 'https://picsum.photos/200/300?random=1',
      isOnline: false,
      isInCall: false,
    ),
    User(
      name: 'Candy',
      bio: 'Lover of art and music.',
      profilePictureUrl: 'https://picsum.photos/200/300?random=2',
      isOnline: true,
      isInCall: true,
    ),
    User(
        name: 'Diana',
        bio: 'Exploring the world, one city at a time.',
        profilePictureUrl: 'https://picsum.photos/200/300?random=3',
        isOnline: true,
        isInCall: false),
    User(
        name: 'Eva',
        bio: 'Fitness enthusiast and healthy food lover.',
        profilePictureUrl: 'https://picsum.photos/200/300?random=4',
        isOnline: false,
        isInCall: false),
  ];

  Future<void> _makeCall(User user) async {
    try {
      final roomName = 'call_${DateTime.now().millisecondsSinceEpoch}';
      final token = await apiService.getLiveKitToken(roomName, user.name);

      if (!mounted) return;

      if (token != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CallScreen(
              roomName: roomName,
              token: token,
              calleeName: user.name,
            ),
          ),
        );
      } else {
        _showErrorDialog('Failed to get call token.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('An error occurred: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.75,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return UserCard(
          user: user,
          onVideoCall: () => _makeCall(user),
          onVoiceCall: () => _makeCall(user),
        );
      },
    );
  }
}
