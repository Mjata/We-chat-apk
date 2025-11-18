
import 'package:flutter/material.dart';
import 'package:myapp/models/recharge_package.dart';
import 'package:myapp/screens/payment_webview_screen.dart';
import 'package:myapp/services/api_service.dart';

class RechargeListScreen extends StatefulWidget {
  const RechargeListScreen({super.key});

  @override
  State<RechargeListScreen> createState() => _RechargeListScreenState();
}

class _RechargeListScreenState extends State<RechargeListScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _phoneController = TextEditingController();
  late Future<List<RechargePackage>> _packagesFuture;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _packagesFuture = _fetchPackages();
  }

  Future<List<RechargePackage>> _fetchPackages() async {
    try {
      final data = await _apiService.getRechargePackages();
      return data.map((json) => RechargePackage.fromJson(json)).toList();
    } catch (e) {
      // Rethrow to be caught by the FutureBuilder
      throw Exception('Failed to load packages: $e');
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initiatePaymentFlow(RechargePackage package, String phoneNumber) async {
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final redirectUrl = await _apiService.initiateMpesaPayment(package.id, phoneNumber);
      if (!mounted || redirectUrl == null) return;
      
      // Close the dialog before navigating
      Navigator.of(context, rootNavigator: true).pop(); 

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebViewScreen(initialUrl: redirectUrl),
        ),
      );
      // Optionally, you can refresh user's coin balance here after payment screen is closed

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initiating payment: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  void _showPaymentDialog(BuildContext context, RechargePackage package) {
    showDialog(
      context: context,
      barrierDismissible: !_isProcessingPayment, // Prevent closing dialog while loading
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Pay with M-Pesa for ${package.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isProcessingPayment)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children: [
                         Text('Complete the payment for ${package.price} KES to get ${package.coins} coins.'),
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
                ],
              ),
              actions: _isProcessingPayment
                  ? []
                  : [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final phoneNumber = _phoneController.text.trim();
                          if (!RegExp(r'^254\d{9}$').hasMatch(phoneNumber)) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(content: Text('Use format 254712345678')),
                            );
                            return;
                          }
                          // Use the dialog's context to manage its state
                          _initiatePaymentFlow(package, phoneNumber);
                        },
                        child: const Text('Proceed to Pay'),
                      ),
                    ],
            );
          },
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
      body: FutureBuilder<List<RechargePackage>>(
        future: _packagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading packages: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recharge packages available.'));
          } else {
            final packages = snapshot.data!;
            return GridView.builder(
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
            );
          }
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
                      '${package.coins} Coins',
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
