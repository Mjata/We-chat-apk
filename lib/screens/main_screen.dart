
import 'package:flutter/material.dart';
import 'package:myapp/screens/tabs/calls_tab.dart';
import 'package:myapp/screens/tabs/home_tab.dart';
import 'package:myapp/screens/tabs/message_tab.dart';
import 'package:myapp/screens/settings_screen.dart';
import 'package:myapp/widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeTab(),
    CallsTab(),
    MessageTab(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('We Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 2 // Show FAB only on MessageTab
          ? FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.chat),
            )
          : null,
    );
  }
}
