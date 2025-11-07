
import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage('https://picsum.photos/id/237/200/300'), // A specific image for the profile
          ),
          const SizedBox(height: 10),
          const Text(
            'Your Name',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'This is your bio. You can write a short description about yourself here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          const Divider(),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // To disable GridView's scrolling
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return Image.network(
                'https://picsum.photos/200/200?random=${index + 30}',
                fit: BoxFit.cover,
              );
            },
          ),
        ],
      ),
    );
  }
}
