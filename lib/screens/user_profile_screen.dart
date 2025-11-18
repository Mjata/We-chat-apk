
import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/screens/call_screen.dart';
import 'package:myapp/services/api_service.dart';
import 'package:uuid/uuid.dart';

class UserProfileScreen extends StatefulWidget {
  final User user;
  final User currentUser; // We need the current user to initiate the call

  const UserProfileScreen({super.key, required this.user, required this.currentUser});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ApiService _apiService = ApiService();
  bool _isInitiatingCall = false;

  // Generate a unique room name for the call
  final String _roomName = const Uuid().v4();

  Future<void> _initiateCall(BuildContext context, bool isVideoCall) async {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() {
      _isInitiatingCall = true;
    });

    try {
      // The local user (current user) is the one initiating the call
      final token = await _apiService.getLiveKitToken(_roomName, widget.currentUser.id);

      if (token == null) {
        throw Exception('Failed to get a valid token from the server.');
      }
      if (!mounted) return;

      navigator.push(
        MaterialPageRoute(
          builder: (context) => CallScreen(
            roomName: _roomName,
            liveKitToken: token,
            localUser: widget.currentUser,
            remoteUser: widget.user, // The user whose profile we are viewing
            isVideoCall: isVideoCall,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Could not start call: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isInitiatingCall = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Dummy list of photos, in a real app this would come from the user object
    final List<String> userPhotos = List.generate(3, (i) => 'https://picsum.photos/seed/${widget.user.id}_$i/400/400');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(widget.user.profilePictureUrl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildProfileInfo(widget.user.name, widget.user.age.toString(), "Unknown"), // Assuming location is not available
                      const SizedBox(height: 16),
                      Text(
                        widget.user.bio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      _buildActionButtons(context, colorScheme),
                      const SizedBox(height: 24),
                      const Divider(),
                      _buildPhotoGrid(userPhotos),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isInitiatingCall)
            Container(
              color: Colors.black.withAlpha(128),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Starting Call...', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                )
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String imageUrl) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withAlpha(153), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String name, String age, String location) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cake, size: 18, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '$age years',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              context,
              icon: Icons.message,
              label: 'Message',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message feature not implemented yet.')),
                );
              },
              color: colorScheme.primary,
            ),
            const SizedBox(width: 16),
            _buildActionButton(
              context,
              icon: Icons.person_add,
              label: 'Follow',
              onPressed: () { 
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Follow feature not implemented yet.')),
                );
              },
              color: Colors.blue.shade400,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             _buildActionButton(
              context,
              icon: Icons.call,
              label: 'Voice Call',
              onPressed: () => _initiateCall(context, false),
              color: Colors.green,
            ),
            const SizedBox(width: 16),
            _buildActionButton(
              context,
              icon: Icons.videocam,
              label: 'Video Call',
              onPressed: () => _initiateCall(context, true),
              color: Colors.red,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed, required Color color}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        elevation: 5,
        shadowColor: color.withAlpha(102),
      ),
    );
  }

  Widget _buildPhotoGrid(List<String> photos) {
    if (photos.isEmpty) {
      return const Text('No photos yet.', style: TextStyle(color: Colors.grey));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.network(
            photos[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
