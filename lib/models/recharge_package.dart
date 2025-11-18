
import 'package:flutter/material.dart';

class RechargePackage {
  final String id;
  final String name;
  final int coins;
  final double price;
  final String benefits;
  final bool isPopular;

  RechargePackage({
    required this.id,
    required this.name,
    required this.coins,
    required this.price,
    required this.benefits,
    this.isPopular = false,
  });

  factory RechargePackage.fromJson(Map<String, dynamic> json) {
    return RechargePackage(
      id: json['_id'],
      name: json['name'],
      coins: json['coins'],
      price: json['price'].toDouble(),
      benefits: json['benefits'],
      isPopular: json['isPopular'] ?? false,
    );
  }
  
  // Helper to get icon based on package name or other properties
  IconData get icon {
    if (name.toLowerCase().contains('gold')) return Icons.star;
    if (name.toLowerCase().contains('diamond')) return Icons.diamond;
    if (name.toLowerCase().contains('vip')) return Icons.verified_user;
    return Icons.monetization_on; // Default icon
  }

  // Helper to get gradient based on package name
  List<Color> get gradientColors {
    if (name.toLowerCase().contains('gold')) {
      return [Colors.amber.shade400, Colors.orange.shade600];
    } else if (name.toLowerCase().contains('diamond')) {
      return [Colors.blue.shade300, Colors.purple.shade300];
    } else if (name.toLowerCase().contains('vip')) {
      return [Colors.purple.shade700, Colors.pink.shade400];
    } else {
      return [Colors.grey.shade600, Colors.grey.shade800]; // Default gradient
    }
  }

}
