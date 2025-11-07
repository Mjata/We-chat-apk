
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InterestSelectionScreen extends StatelessWidget {
  const InterestSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I am interested in'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'I am looking for',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInterestCard(context, 'Relationship', Icons.favorite),
                const SizedBox(width: 20),
                _buildInterestCard(context, 'Friendship', Icons.people),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestCard(BuildContext context, String interest, IconData icon) {
    return GestureDetector(
      onTap: () => context.go('/main'),
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
                color: interest == 'Relationship' ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 10),
              Text(
                interest,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
