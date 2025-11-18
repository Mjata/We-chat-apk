
import 'package:flutter/material.dart';
import 'package:myapp/screens/payment_screen.dart'; // It will be our WebView screen
import 'package:myapp/services/api_service.dart'; // Import ApiService

// Updated data model to include a packageId for the API
class RechargePackage {
  final String packageId; // e.g., 'pack1', 'pack2'
  final String name;
  final String price;
  final String benefits;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isPopular;

  RechargePackage({
    required this.packageId,
    required this.name,
    required this.price,
    required this.benefits,
    required this.icon,
    required this.gradientColors,
    this.isPopular = false,
  });
}

class RechargeListScreen extends StatefulWidget {
  const RechargeListScreen({super.key});

  @override
  State<RechargeListScreen> createState() => _RechargeListScreenState();
}

class _RechargeListScreenState extends State<RechargeListScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  // Updated list with packageId
  final List<RechargePackage> packages = [
    RechargePackage(
      packageId: 'pack1',
      name: 'Gold',
      price: '100 Coins',
      benefits: '+1,500 Coins & Gold Frame',
      icon: Icons.star,
      gradientColors: [Colors.amber.shade400, Colors.orange.shade600],
      isPopular: true,
    ),
    RechargePackage(
      packageId: 'pack2',
      name: 'Diamond',
      price: '550 Coins',
      benefits: '+3,200 Coins & Diamond Frame',
      icon: Icons.diamond,
      gradientColors: [Colors.blue.shade300, Colors.purple.shade300],
    ),
    RechargePackage(
      packageId: 'pack3',
      name: 'VIP',
      price: '1200 Coins',
      benefits: '+5,000 Coins & VIP Frame',
      icon: Icons.verified_user,
      gradientColors: [Colors.purple.shade700, Colors.pink.shade400],
    ),
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initiatePaymentFlow(RechargePackage package, String phoneNumber) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final redirectUrl = await _apiService.initiateRecharge(package.packageId, phoneNumber);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(url: redirectUrl!),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPaymentDialog(BuildContext context, RechargePackage package) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Pay with M-Pesa for ${package.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your M-Pesa phone number to pay.'),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '2547...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final phoneNumber = _phoneController.text;
                if (!RegExp(r'^(254)\d{9}$').hasMatch(phoneNumber)) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid number, e.g., 254712345678')),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop();
                _initiatePaymentFlow(package, phoneNumber);
              },
              child: const Text('Proceed to Pay'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recharge Coins'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final package = packages[index];
                return _buildPackageCard(context, package);
              },
            ),
    );
  }

  Widget _buildPackageCard(BuildContext context, RechargePackage package) {
    return GestureDetector(
      onTap: () => _showPaymentDialog(context, package),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: package.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: package.gradientColors.last.withAlpha(102),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(package.icon, size: 45, color: Colors.white.withAlpha(230)),
                  Column(
                    children: [
                      Text(
                        package.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        package.benefits,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(204)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(51),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      package.price,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (package.isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
