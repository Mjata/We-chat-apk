import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance'),
          _buildThemeChanger(context, themeProvider),
          _buildColorChanger(context, themeProvider),
          const Divider(),
          _buildSectionHeader('Account'),
          _buildDeleteAccount(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildThemeChanger(BuildContext context, ThemeProvider themeProvider) {
    return ListTile(
      leading: const Icon(Icons.palette),
      title: const Text('Theme'),
      subtitle: Text('Current: ${themeProvider.themeMode.name.capitalize()}'),
      onTap: () => _showThemeDialog(context, themeProvider),
    );
  }

  Widget _buildColorChanger(BuildContext context, ThemeProvider themeProvider) {
    return ListTile(
      leading: const Icon(Icons.color_lens),
      title: const Text('App Color'),
      subtitle: const Text('Change the primary color scheme'),
      trailing: CircleAvatar(
        backgroundColor: themeProvider.seedColor,
        radius: 14,
      ),
      onTap: () => _showColorDialog(context, themeProvider),
    );
  }

  Widget _buildDeleteAccount(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.delete_forever, color: Colors.red),
      title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
      onTap: () => _showDeleteConfirmationDialog(context),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              // ignore: deprecated_member_use
              groupValue: themeProvider.themeMode,
              // ignore: deprecated_member_use
              onChanged: (value) {
                if (value != null) themeProvider.setThemeMode(value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              // ignore: deprecated_member_use
              groupValue: themeProvider.themeMode,
              // ignore: deprecated_member_use
              onChanged: (value) {
                if (value != null) themeProvider.setThemeMode(value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              value: ThemeMode.system,
              // ignore: deprecated_member_use
              groupValue: themeProvider.themeMode,
              // ignore: deprecated_member_use
              onChanged: (value) {
                if (value != null) themeProvider.setThemeMode(value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showColorDialog(BuildContext context, ThemeProvider themeProvider) {
    final List<Color> colorOptions = [
      Colors.deepPurple,
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.amber,
      Colors.red,
      Colors.pink,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose App Color'),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colorOptions.map((color) {
            return GestureDetector(
              onTap: () {
                themeProvider.setSeedColor(color);
                Navigator.pop(context);
              },
              child: CircleAvatar(
                backgroundColor: color,
                radius: 20,
                child: themeProvider.seedColor == color
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This is a permanent action. Are you sure you want to delete your account?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(context); // Close confirmation
              _showReasonDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showReasonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reason for Deletion'),
        content: TextField(
          controller: _reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Please tell us why you are leaving...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              _reasonController.clear();
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('Submit & Delete'),
            onPressed: () {
              _reasonController.clear();
              Navigator.pop(context); // Close reason dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion request sent.')),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1)}";
    }
}
