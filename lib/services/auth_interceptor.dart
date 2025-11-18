import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer; // Import for structured logging

// Hii Interceptor itaongeza Firebase ID token kwenye kila request
class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Pata ID Token ya sasa. Hii itarefresh token ikiwa imekwisha muda.
        final idToken = await user.getIdToken(true);
        // Weka token kwenye header
        options.headers['Authorization'] = 'Bearer $idToken';
        developer.log('Authorization token added to header: Bearer $idToken', name: 'AuthInterceptor');
      } catch (e) {
        developer.log('Error getting ID token: $e', name: 'AuthInterceptor', error: e);
        // Unaweza kushughulikia error hapa, k.m., kumwondoa mtumiaji
        // Kwa sasa, tunaendelea na ombi bila token
      }
    } else {
      developer.log('No active Firebase user found. Request proceeding without Authorization header.', name: 'AuthInterceptor');
    }
    
    // Ruhusu request iendelee
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log('AuthInterceptor - Request Error: ${err.message}', name: 'AuthInterceptor', error: err);
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      developer.log('AuthInterceptor - Unauthorized or Forbidden. User might need to re-authenticate.', name: 'AuthInterceptor');
      // Hapa unaweza kuongeza logic ya ku-redirect mtumiaji kwenye login screen
      // au ku-refresh token manually ikiwa inahitajika
    }
    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log('AuthInterceptor - Response received: ${response.statusCode}', name: 'AuthInterceptor');
    super.onResponse(response, handler);
  }
}