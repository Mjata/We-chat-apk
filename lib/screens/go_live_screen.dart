
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:myapp/services/api_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

class GoLiveScreen extends StatefulWidget {
  const GoLiveScreen({super.key});

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Room? _room;
  LocalTrack? _videoTrack;
  bool _isStreaming = false;
  bool _isLoading = false;
  String _streamStatus = 'Not Live';

  @override
  void initState() {
    super.initState();
    _initializePreview();
  }

  Future<void> _initializePreview() async {
    await [Permission.camera, Permission.microphone].request();
    try {
      final videoTrack = await LocalVideoTrack.createCameraTrack();
      setState(() {
        _videoTrack = videoTrack;
      });
    } catch (e) {
      developer.log('Failed to create video track: $e');
      if (!mounted) return;
      _showErrorDialog('Error', 'Could not access your camera. Please ensure you have granted permission.');
    }
  }

  Future<void> _startStreaming() async {
    if (_isLoading) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showErrorDialog('Authentication Error', 'You must be logged in to start a stream.');
      return;
    }

    setState(() {
      _isLoading = true;
      _streamStatus = 'Connecting...';
    });

    try {
      final String roomName = currentUser.uid;
      final String participantIdentity = currentUser.uid;

      await _apiService.startLiveStream();

      final token = await _apiService.getLiveKitToken(roomName, participantIdentity);
      if (token == null) {
        throw Exception('Failed to get a valid token from the backend.');
      }

      _room = Room();
      final listener = _room!.createListener();
      listener.on<RoomDisconnectedEvent>((event) {
        _handleStreamEnd(isInitiatedByUser: false, reason: event.reason?.name);
      });
      listener.on<LocalTrackPublishedEvent>((event) {
        developer.log('Local track published: ${event.publication.kind}');
      });

      await _room!.connect('wss://we-chat-k0bb5qx2.livekit.cloud', token);

      if (_videoTrack == null || _videoTrack!.isDisposed) {
        await _initializePreview();
        if (_videoTrack == null) throw Exception("Camera could not be started.");
      }

      await _room!.localParticipant!.publishVideoTrack(_videoTrack as LocalVideoTrack);
      await _room!.localParticipant!.publishAudioTrack(await LocalAudioTrack.create());

      if (mounted) {
        setState(() {
          _isStreaming = true;
          _isLoading = false;
          _streamStatus = 'Live';
        });
      }
    } on Exception catch (e) {
        final errorMessage = e.toString();
        developer.log('Failed to start stream', error: e);
        if (!mounted) return;
        if (errorMessage.contains('403')) { 
            _showVipPrompt();
             setState(() {
                _isLoading = false;
                _streamStatus = 'VIP Required';
            });
        } else {
            _showErrorDialog('Stream Error', 'Failed to start stream: $errorMessage');
             setState(() {
                _isLoading = false;
                _streamStatus = 'Failed';
            });
        }
    }
  }

  void _showVipPrompt() {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('VIP Subscription Required'),
          content: const Text('You need to be a VIP member to start a live stream. Please subscribe to a VIP package to continue.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Become a VIP'),
            ),
          ],
        ),
      );
  }


  void _handleStreamEnd({bool isInitiatedByUser = true, String? reason}) {
    if (isInitiatedByUser) {
      _apiService.stopLiveStream();
      developer.log("User ended the stream manually.");
    } else {
      developer.log("Stream ended due to disconnection. Reason: $reason");
    }

    _room?.disconnect();

    if (mounted) {
      setState(() {
        _isStreaming = false;
        _isLoading = false;
        _streamStatus = 'Stream Ended';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  void _showErrorDialog(String title, String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _videoTrack?.stop();
    _videoTrack?.dispose();
    _room?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Live'),
        backgroundColor: Colors.redAccent,
        actions: [
          if (_isStreaming)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 20),
                    SizedBox(width: 4),
                    Text("0", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildPreview(),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Expanded(
      child: Container(
        color: Colors.black87,
        alignment: Alignment.center,
        child: _videoTrack != null && !_videoTrack!.isDisposed
            ? VideoTrackRenderer(_videoTrack as VideoTrack)
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Initializing Camera...", style: TextStyle(color: Colors.white)),
                ],
              ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _streamStatus,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isStreaming ? Colors.green : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            if (!_isStreaming)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_isLoading || _videoTrack == null) ? null : _startStreaming,
                  icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.stream),
                  label: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Go Live Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleStreamEnd(isInitiatedByUser: true),
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('End Stream'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
