
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GenderSelectionScreen extends StatelessWidget {
  const GenderSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Gender'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'I am a',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGenderCard(context, 'Male', Icons.male),
                const SizedBox(width: 20),
                _buildGenderCard(context, 'Female', Icons.female),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderCard(BuildContext context, String gender, IconData icon) {
    return GestureDetector(
      onTap: () => context.go('/interest'),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: SizedBox(
          width: 140,
          height: 140,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: gender == 'Male' ? Colors.blue : Colors.pink,
              ),
              const SizedBox(height: 10),
              Text(
                gender,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
