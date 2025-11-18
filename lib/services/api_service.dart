
import 'package:dio/dio.dart';
import 'auth_interceptor.dart'; // Import interceptor
import 'dart:developer' as developer;


class ApiService {
  final Dio _dio;
  
  // Tumia URL yako ya Render hapa kwa production
  static const String _baseUrl = 'https://we-chat-1-flwd.onrender.com/api'; 

  ApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        )) {
    // Sajili Interceptor
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          developer.log(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          return handler.next(response); // Continue with the response
        },
        onError: (DioException e, handler) {
          developer.log(
            'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
            error: e.response?.data,
          );
          return handler.next(e); // Continue with the error
        },
      ),
    );
  }

  // Helper function for error handling
  Exception _handleError(DioException e) {
    String errorMessage = "An unknown error occurred";
    if (e.response != null) {
        // Use the error message from the backend if available
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('error')) {
            errorMessage = responseData['error'];
        } else {
            errorMessage = "Server error: ${e.response?.statusCode} ${e.response?.statusMessage}";
        }
    } else {
      errorMessage = "Network error: Please check your connection.";
    }
    return Exception(errorMessage);
  }


  /// 1. User & Account
  Future<void> setupNewUser() async {
    try {
      await _dio.post('/setupNewUser');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 2. Payments & Recharge (Pesapal)
  Future<String?> initiateRecharge(String packageId, String phoneNumber) async {
    try {
      final response = await _dio.post(
        '/recharge/initiate',
        data: {'packageId': packageId, 'phoneNumber': phoneNumber},
      );
      return response.data['redirectUrl'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 3. Live Streaming
  Future<void> startLiveStream() async {
    try {
      await _dio.post('/livestreams/start');
    } on DioException catch (e) {
        // The interceptor logs the error, just re-throw it for the UI to handle
        throw _handleError(e);
    }
  }

  Future<void> stopLiveStream() async {
    try {
      await _dio.post('/livestreams/stop');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getLiveStreams() async {
    try {
      final response = await _dio.get('/livestreams');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 4. Video & Voice Calls
  
  /// [DEPRECATED] This is no longer used. See chargeCallDuration.
  // Future<bool> chargeCall(String callId) async { ... }

  /// NEW: Charges the user's coins based on the call duration after it ends.
  Future<void> chargeCallDuration({required int durationInSeconds}) async {
    try {
      await _dio.post('/calls/charge-duration', data: {
        'durationInSeconds': durationInSeconds,
      });
      developer.log('Successfully charged for call duration: $durationInSeconds seconds');
    } on DioException catch (e) {
        developer.log('Error in chargeCallDuration', error: e);
        throw _handleError(e);
    }
  }


  Future<void> endCall(String callId, int durationInSeconds) async {
    try {
      await _dio.post(
        '/calls/end',
        data: {'callId': callId, 'duration': durationInSeconds},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 5. AdMob Rewards
  Future<void> grantAdReward() async {
    try {
      await _dio.post('/rewards/grant-ad-reward');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 6. LiveKit Token
  Future<String?> getLiveKitToken(String roomName, String participantIdentity) async {
    try {
      final response = await _dio.post(
        '/calls/livekit-token',
        data: {
          'roomName': roomName,
          'participantIdentity': participantIdentity,
        },
      );
        return response.data['token'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
