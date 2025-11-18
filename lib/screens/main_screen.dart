
import 'package:flutter/material.dart';
import 'package:myapp/screens/tabs/calls_tab.dart';
import 'package:myapp/screens/tabs/home_tab.dart';
import 'package:myapp/screens/tabs/live_tab.dart';
import 'package:myapp/screens/tabs/message_tab.dart';
import 'package:myapp/screens/tabs/profile_tab.dart';
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
    LiveTab(),
    ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
