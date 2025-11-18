
import 'package:flutter/material.dart';
import 'package:myapp/services/user_profile_service.dart';

class ProfileFrame extends StatelessWidget {
  final ImageProvider? imageProvider;
  final SubscriptionTier tier;
  final double radius;

  const ProfileFrame({
    super.key,
    this.imageProvider,
    required this.tier,
    this.radius = 50,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> frameColors = _getFrameColors(tier);

    if (tier == SubscriptionTier.none) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
        backgroundColor: Colors.grey.shade300,
        child: imageProvider == null ? Icon(Icons.person, size: radius, color: Colors.grey.shade600) : null,
      );
    }

    return Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: frameColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: frameColors.first.withAlpha(153),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: CircleAvatar(
          radius: radius - 3.5,
          backgroundImage: imageProvider,
          backgroundColor: Colors.grey.shade300,
           child: imageProvider == null ? Icon(Icons.person, size: radius - 10, color: Colors.grey.shade600) : null,
        ),
      ),
    );
  }

  List<Color> _getFrameColors(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.gold:
        return [Colors.amber.shade600, Colors.orange.shade400];
      case SubscriptionTier.diamond:
        return [Colors.lightBlue.shade400, Colors.cyan.shade300];
      case SubscriptionTier.vip:
        return [Colors.purple.shade600, Colors.pink.shade500];
      case SubscriptionTier.none:
        return [Colors.transparent, Colors.transparent];
    }
  }
}
