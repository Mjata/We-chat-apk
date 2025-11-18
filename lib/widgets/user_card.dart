
import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const UserCard({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap, // Added onTap to the whole card
        child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Stack(
            children: [
            // Background Image
            Positioned.fill(
                child: Image.network(
                user.profilePictureUrl,
                fit: BoxFit.cover,
                ),
            ),
            // Gradient Overlay
            Positioned.fill(
                child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withAlpha(178)], // ~70% opacity
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    ),
                ),
                ),
            ),
            // User Info
            Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                    user.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                    ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                    user.bio,
                    maxLines: 2, // Prevent long bios from overflowing
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                    ),
                    ),
                ],
                ),
            ),
            // Online/In-Call Indicator
            Positioned(
                top: 8,
                left: 8,
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: user.isInCall ? Colors.red : (user.isOnline ? Colors.green : Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                    user.isInCall ? 'In Call' : (user.isOnline ? 'Online' : 'Offline'),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                ),
            ),
            ],
        ),
        ),
    );
  }
}
