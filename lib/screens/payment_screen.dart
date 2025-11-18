
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer' as developer;

class PaymentScreen extends StatefulWidget {
  final String url; // The PesaPal redirect URL
  const PaymentScreen({super.key, required this.url});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            developer.log('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            developer.log('Page started loading: $url');
          },
          onPageFinished: (String url) {
            developer.log('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
             developer.log('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            // You can add logic here to close the webview on certain URLs
            if (request.url.contains('pesapal.com/failed')) {
                _handlePaymentCompletion(isSuccess: false);
                return NavigationDecision.prevent; // Prevent navigation
            }
            if (request.url.contains('pesapal.com/success')) {
                _handlePaymentCompletion(isSuccess: true);
                return NavigationDecision.prevent; // Prevent navigation
            }
            return NavigationDecision.navigate; // Allow other navigations
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

   void _handlePaymentCompletion({required bool isSuccess}) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Close the WebView
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSuccess
              ? 'Payment processing. Your coins will be updated shortly.'
              : 'Payment failed. Please try again.'),
          backgroundColor: isSuccess ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Secure Payment'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
         leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
             // Show a confirmation dialog before closing
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Are you sure?'),
                content: const Text('Are you sure you want to cancel the payment?'),
                actions: [
                  TextButton(
                    child: const Text('No'),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                  TextButton(
                    child: const Text('Yes, Cancel'),
                    onPressed: () {
                       Navigator.of(ctx).pop();
                       Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
