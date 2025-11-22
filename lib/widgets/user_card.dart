
import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  final VoidCallback onMessage;
  final VoidCallback onVoiceCall;
  final VoidCallback onVideoCall;

  const UserCard({
    super.key,
    required this.user,
    required this.onTap,
    required this.onMessage,
    required this.onVoiceCall,
    required this.onVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap, // This handles the tap on the whole card
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
                    colors: [Colors.transparent, Colors.black.withAlpha(200)], // Increased opacity
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0], // Gradient starts lower
                    ),
                ),
                ),
            ),
            // User Info and Action Buttons
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
                        shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
                    ),
                    ),
                    const SizedBox(height: 4),
                    // Action Buttons Row
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Use Expanded to give text more space
                        Expanded(
                          child: Text(
                            user.bio,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                            ),
                          ),
                        ),
                        // Wrap buttons in a row
                        Row(
                          children: [
                            SizedBox(
                              height: 36, // Constrain button size
                              width: 36,
                              child: IconButton(
                                icon: const Icon(Icons.message, color: Colors.white, size: 20),
                                onPressed: onMessage,
                                tooltip: 'Message',
                              ),
                            ),
                            SizedBox(
                              height: 36,
                              width: 36,
                              child: IconButton(
                                icon: const Icon(Icons.call, color: Colors.white, size: 20),
                                onPressed: onVoiceCall,
                                tooltip: 'Voice Call',
                              ),
                            ),
                            SizedBox(
                              height: 36,
                              width: 36,
                              child: IconButton(
                                icon: const Icon(Icons.videocam, color: Colors.white, size: 22),
                                onPressed: onVideoCall,
                                tooltip: 'Video Call',
                              ),
                            ),
                          ],
                        ),
                      ],
                     )
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
                    border: Border.all(color: Colors.black26),
                ),
                child: Text(
                    user.isInCall ? 'In Call' : (user.isOnline ? 'Online' : 'Offline'),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                ),
            ),
            ],
        ),
        ),
    );
  }
}
