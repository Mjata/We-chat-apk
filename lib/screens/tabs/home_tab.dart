
import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10, // Let's show 10 dummy users
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage('https://picsum.photos/200/300?random=$index'),
            ),
            title: Text('User $index'),
            subtitle: const Text('This is a short bio of the user.'),
            trailing: IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }
}
