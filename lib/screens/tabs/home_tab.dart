
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/widgets/user_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ApiService apiService = ApiService();
  late Future<List<User>> _usersFuture;
  User? _currentUser; // To hold the current user

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<User>> _fetchUsers() async {
    try {
      final data = await apiService.getUsers();
      final users = data.map((json) => User.fromJson(json)).toList();
      
      // For demonstration, we'll assume the first user in the list is the current user.
      // In a real app, you would get this from your auth provider.
      if (users.isNotEmpty) {
        setState(() {
            _currentUser = users.first;
        });
      }
      return users;
    } catch (e) {
      // Rethrow to be caught by FutureBuilder
      throw Exception('Failed to load users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty || _currentUser == null) {
          return const Center(child: Text('No users found or current user not identified.'));
        } else {
          final users = snapshot.data!;
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
                onTap: () => context.go('/profile', extra: {'user': user, 'currentUser': _currentUser!}),
                onMessage: () => context.go('/chat', extra: {'recipient': user}),
                onVoiceCall: () {},
                onVideoCall: () {},
              );
            },
          );
        }
      },
    );
  }
}
