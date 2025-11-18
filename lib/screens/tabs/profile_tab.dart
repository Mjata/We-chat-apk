
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/screens/recharge_list_screen.dart';
import 'package:myapp/screens/settings_screen.dart';
import 'package:myapp/services/user_profile_service.dart';
import 'package:myapp/widgets/profile_frame.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage(BuildContext context) async {
    final profileService = context.read<UserProfileService>();
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileService.setImage(File(image.path));
    }
  }

  Future<void> _pickUserPhoto(BuildContext context) async {
    final profileService = context.read<UserProfileService>();
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileService.addUserPhoto(File(image.path));
    }
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final profileService = context.read<UserProfileService>();
    _nameController.text = profileService.username;
    _ageController.text = profileService.age;
    _locationController.text = profileService.location;

    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Age"),
                ),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: "Location"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _ageController.text.isNotEmpty &&
                    _locationController.text.isNotEmpty) {
                  profileService.setProfile(
                    _nameController.text,
                    _ageController.text,
                    _locationController.text,
                  );
                  Navigator.pop(dialogContext);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileService>(
      builder: (context, userProfileService, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfileHeader(context, userProfileService),
                const SizedBox(height: 10),
                _buildProfileInfo(context, userProfileService),
                const SizedBox(height: 8),
                const Text(
                  'This is your bio. You can write a short description about yourself here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                _buildCoinBalance(context, userProfileService),
                const SizedBox(height: 16),
                _buildActionButtons(context),
                const SizedBox(height: 24),
                const Divider(),
                _buildPhotoGrid(context, userProfileService),
                const SizedBox(height: 24),
                const Divider(),
                _buildSettingsMenu(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfileService userProfileService) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ProfileFrame(
          radius: 60,
          tier: userProfileService.subscriptionTier,
          imageProvider: userProfileService.image != null
              ? FileImage(userProfileService.image!)
              : const NetworkImage('https://picsum.photos/id/237/200/300') as ImageProvider,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.primary,
            child: IconButton(
              onPressed: () => _pickProfileImage(context),
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(BuildContext context, UserProfileService userProfileService) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              userProfileService.username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
              onPressed: () => _showEditProfileDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cake, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '${userProfileService.age} years',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              userProfileService.location,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoinBalance(BuildContext context, UserProfileService userProfileService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(75),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Coins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(userProfileService.coins.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.credit_card,
            label: 'Recharge',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RechargeListScreen()),
              );
            },
            color: Colors.blue.shade400,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            context,
            icon: Icons.monetization_on,
            label: 'Get Coins',
            onPressed: () {},
            color: Colors.green.shade400,
          ),
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        elevation: 5,
        shadowColor: color.withAlpha(102),
      ),
    );
  }

  Widget _buildPhotoGrid(BuildContext context, UserProfileService userProfileService) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: userProfileService.userPhotos.length + (userProfileService.userPhotos.length < 3 ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < userProfileService.userPhotos.length) {
          // Display user photo
          return ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.file(
              userProfileService.userPhotos[index],
              fit: BoxFit.cover,
            ),
          );
        } else {
          // Display 'Add Photo' button
          return GestureDetector(
            onTap: () => _pickUserPhoto(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.add_a_photo, color: Colors.grey, size: 40),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildSettingsMenu(BuildContext context) {
    return Column(
      children: [
        _buildSettingsItem(context, icon: Icons.settings, title: 'Settings', onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        }),
        _buildSettingsItem(context, icon: Icons.headset_mic, title: 'Customer Care', onTap: () {}),
        const SizedBox(height: 10),
        _buildSettingsItem(context, icon: Icons.logout, title: 'Logout', color: Colors.red, onTap: () {}),
      ],
    );
  }

  Widget _buildSettingsItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).iconTheme.color),
      title: Text(title, style: TextStyle(color: color ?? Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w500)),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
