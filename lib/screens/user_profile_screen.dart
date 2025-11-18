
import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final int userIndex;

  const UserProfileScreen({super.key, required this.userIndex});

  @override
  Widget build(BuildContext context) {
    // Simulate user data based on index for demonstration
    final String pichaYaWasifu = 'https://picsum.photos/200/300?random=${userIndex + 1}';
    final String jinaLaMtumiaji = 'User ${userIndex + 1}';
    final String age = '${20 + (userIndex % 10)}'; // Simulate age between 20-29
    final String location = 'City ${userIndex % 5}'; // Simulate a few locations
    final String bio = 'This is the bio of $jinaLaMtumiaji. They enjoy Flutter and long walks on the beach.';
    final List<String> userPhotos = List.generate(3, (i) => 'https://picsum.photos/seed/${userIndex}_$i/400/400');

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(jinaLaMtumiaji),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(pichaYaWasifu),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileInfo(jinaLaMtumiaji, age, location),
                  const SizedBox(height: 16),
                  Text(
                    bio,
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
            colors: [Colors.black.withAlpha((255 * 0.6).round()), Colors.transparent],
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
            const SizedBox(width: 24),
            const Icon(Icons.location_on, size: 18, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              location,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

    Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          context,
          icon: Icons.message,
          label: 'Message',
          onPressed: () {
            // Since we don't have the full user object, we can't navigate to chat directly.
            // In a real app, you would pass the user ID and use it to start a chat.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Message button pressed!')),
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
              const SnackBar(content: Text('Follow button pressed!')),
            );
          },
          color: Colors.blue.shade400,
        ),
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
