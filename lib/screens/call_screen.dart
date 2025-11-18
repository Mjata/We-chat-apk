
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:myapp/services/api_service.dart';
import 'dart:developer' as developer;

class CallScreen extends StatefulWidget {
  final String roomName;
  final String token;
  final String calleeName;

  const CallScreen({
    super.key,
    required this.roomName,
    required this.token,
    required this.calleeName,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final ApiService _apiService = ApiService();
  final Stopwatch _callStopwatch = Stopwatch();
  Room? _room;
  EventsListener? _listener;
  bool _isConnected = false;
  Timer? _durationTimer;
  String _callDuration = "00:00";

  @override
  void initState() {
    super.initState();
    _connectToRoom();
  }

  Future<void> _connectToRoom() async {
    _room = Room();
    _listener = _room!.createListener();

    _listener!
      ..on<RoomDisconnectedEvent>(_onDisconnected)
      ..on<RoomConnectedEvent>(_onConnected)
      ..on<ParticipantConnectedEvent>(_onParticipantConnected)
      ..on<ParticipantDisconnectedEvent>(_onParticipantDisconnected);

    try {
      await _room!.connect(
        'wss://we-chat-k0bb5qx2.livekit.cloud',
        widget.token,
      );
    } catch (e) {
      developer.log("Failed to connect to room", error: e);
      _handleCallEnd();
    }
  }

  void _onConnected(RoomConnectedEvent event) async {
    developer.log("Successfully connected to room: ${event.room.name}");
    setState(() {
      _isConnected = true;
    });
    _callStopwatch.start();
    _startDurationTimer();
    // Publish audio track immediately
    await _room!.localParticipant?.publishAudioTrack(await LocalAudioTrack.create());
  }

  void _onParticipantConnected(ParticipantConnectedEvent event) {
    developer.log("Remote participant connected: ${event.participant.identity}");
    // We don't need to store the remote participant for this simple screen
  }

  void _onParticipantDisconnected(ParticipantDisconnectedEvent event) {
    developer.log("Remote participant disconnected");
    _handleCallEnd();
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final minutes = _callStopwatch.elapsed.inMinutes.toString().padLeft(2, '0');
      final seconds = (_callStopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
      if (mounted) {
        setState(() {
          _callDuration = "$minutes:$seconds";
        });
      }
    });
  }

  Future<void> _onDisconnected(RoomDisconnectedEvent? event) async {
    developer.log("Disconnected from room. Reason: ${event?.reason}");
    await _handleCallEnd();
  }

  Future<void> _handleCallEnd() async {
    if (!_isConnected && mounted) return;

    _callStopwatch.stop();
    _durationTimer?.cancel();
    final int durationInSeconds = _callStopwatch.elapsed.inSeconds;
    
    if (mounted) {
      setState(() {
        _isConnected = false;
      });
    }

    if (durationInSeconds > 3) { 
      try {
        await _apiService.chargeCallDuration(durationInSeconds: durationInSeconds);
        developer.log("Successfully charged user for $durationInSeconds seconds.");
      } on Exception catch (e) {
        developer.log("Failed to charge for the call", error: e);
      }
    }

    _callStopwatch.reset();
    await _room?.disconnect(); // Ensure disconnect is awaited
    if(mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _listener?.dispose();
    _room?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Text(
                widget.calleeName,
                style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _isConnected ? _callDuration : "Connecting...",
                style: TextStyle(fontSize: 20, color: Colors.white.withAlpha(180)), // Corrected deprecated withOpacity
              ),
              const Spacer(flex: 3),
              FloatingActionButton(
                onPressed: _handleCallEnd,
                backgroundColor: Colors.red,
                heroTag: 'end_call',
                child: const Icon(Icons.call_end, color: Colors.white),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
