
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  final Dio _dio = Dio();
  // Using the new production backend URL
  final String _baseUrl = 'https://we-chat-1-flwd.onrender.com/api';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper to get auth token
  Future<Options> _getAuthHeaders() async {
    final user = _auth.currentUser;
    if (user == null) {
      // In a real app, you might want to trigger a logout/login flow
      throw Exception('User not logged in');
    }
    final token = await user.getIdToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // --- User & Auth ---
  Future<List<dynamic>> getUsers() async {
    // This should fetch users from your actual backend
    try {
      final options = await _getAuthHeaders();
      final response = await _dio.get('$_baseUrl/users', options: options);
      return response.data; 
    } catch (e) {
       // Fallback to random users if your backend fails for demonstration
      final response = await _dio.get('https://randomuser.me/api/?results=20');
      return response.data['results'];
    }
  }

  Future<void> syncUser(Map<String, dynamic> userData) async {
    try {
      final options = await _getAuthHeaders();
      await _dio.post('$_baseUrl/users/sync', data: userData, options: options);
    } catch (e) {
      throw Exception('Failed to sync user: $e');
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final options = await _getAuthHeaders();
      await _dio.put('$_baseUrl/users/profile', data: profileData, options: options);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // --- LiveKit ---
  Future<String> getLiveKitToken(String roomName, String participantName) async {
    try {
      final options = await _getAuthHeaders();
      final response = await _dio.post(
        '$_baseUrl/livekit/token',
        data: {'roomName': roomName, 'participantName': participantName},
        options: options,
      );
      return response.data['token'];
    } catch (e) {
      throw Exception('Failed to get LiveKit token: $e');
    }
  }

  // --- Calls ---
  Future<List<dynamic>> getCallHistory() async {
    try {
      final options = await _getAuthHeaders();
      final response = await _dio.get('$_baseUrl/calls/history', options: options);
      return response.data; // Assuming it returns a list
    } catch (e) {
      throw Exception('Failed to get call history: $e');
    }
  }

  Future<void> chargeCallDuration(String callId, int durationInSeconds) async {
    try {
      final options = await _getAuthHeaders();
      await _dio.post(
        '$_baseUrl/calls/charge',
        data: {'callId': callId, 'duration': durationInSeconds},
        options: options,
      );
    } catch (e) {
      throw Exception('Failed to charge for call: $e');
    }
  }

  // --- Messaging ---
  Future<List<dynamic>> getConversations() async {
    try {
      final options = await _getAuthHeaders();
      final response = await _dio.get('$_baseUrl/conversations', options: options);
      return response.data; // Assuming it returns a list
    } catch (e) {
      throw Exception('Failed to get conversations: $e');
    }
  }

  // --- Livestreaming ---
  Future<List<dynamic>> getLiveStreams() async {
    try {
      final options = await _getAuthHeaders();
      final response = await _dio.get('$_baseUrl/livestreams', options: options);
      return response.data;
    } catch (e) {
      throw Exception('Failed to get live streams: $e');
    }
  }

  Future<void> startLiveStream(String streamImageUrl) async {
    try {
      final options = await _getAuthHeaders();
      await _dio.post(
        '$_baseUrl/livestreams/start',
        data: {'liveStreamImageUrl': streamImageUrl},
        options: options,
      );
    } catch (e) {
      throw Exception('Failed to start live stream: $e');
    }
  }

  Future<void> stopLiveStream() async {
    try {
      final options = await _getAuthHeaders();
      await _dio.post('$_baseUrl/livestreams/stop', options: options);
    } catch (e) {
      throw Exception('Failed to stop live stream: $e');
    }
  }

  // --- Payments & Recharge ---
  Future<List<dynamic>> getRechargePackages() async {
    try {
      final options = await _getAuthHeaders();
      final response = await _dio.get('$_baseUrl/payments/packages', options: options);
      return response.data; // Assuming it returns a list of packages
    } catch (e) {
      throw Exception('Failed to get recharge packages: $e');
    }
  }

  Future<String?> initiateMpesaPayment(String packageId, String phoneNumber) async {
     try {
      final options = await _getAuthHeaders();
      final response = await _dio.post(
        '$_baseUrl/payments/mpesa/initiate', 
        data: {
          'packageId': packageId,
          'phoneNumber': phoneNumber,
        },
        options: options,
      );
      return response.data['redirectUrl'];
    } catch (e) {
      throw Exception('Failed to initiate M-Pesa payment: $e');
    }
  }
}
