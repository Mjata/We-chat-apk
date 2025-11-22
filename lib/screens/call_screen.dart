
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/services/api_service.dart';

// Define CancelListenFunc if it's not exposed or you need a local definition
typedef CancelListenFunc = Future<void> Function();

class CallScreen extends StatefulWidget {
  final String roomName;
  final String liveKitToken;
  final User localUser;
  final User remoteUser;
  final bool isVideoCall;

  const CallScreen({
    super.key,
    required this.roomName,
    required this.liveKitToken,
    required this.localUser,
    required this.remoteUser,
    required this.isVideoCall,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Room? _room;
  CancelListenFunc? _cancelListenFunc;
  final List<ParticipantTrack> _videoTracks = [];
  bool _isCameraOn = true;
  bool _isMicOn = true;
  int _callDurationInSeconds = 0;
  Timer? _callTimer;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _connectToRoom();
    _startCallTimer();
  }

  Future<void> _connectToRoom() async {
    _room = Room();
    // Use the CancelListenFunc to hold the subscription
    _cancelListenFunc = _room!.events.listen(_onRoomEvent) as CancelListenFunc?;

    try {
      await _room!.connect(
        'wss://we-chat-1-flwd.onrender.com', // Your LiveKit server URL
        widget.liveKitToken,
      );

      if (widget.isVideoCall) {
        await _room!.localParticipant?.setCameraEnabled(true);
      }
      await _room!.localParticipant?.setMicrophoneEnabled(true);

    } catch (e) {
      debugPrint('Could not connect to room: $e');
      _leaveCall();
    }
  }

  void _onRoomEvent(RoomEvent event) {
    if (event is TrackSubscribedEvent) {
        if (event.track is VideoTrack) {
            setState(() {
                _videoTracks.add(ParticipantTrack(event.participant, event.track));
            });
        }
    } else if (event is TrackUnsubscribedEvent) {
        setState(() {
            _videoTracks.removeWhere((track) => track.track?.sid == event.track.sid);
        });
    } else if (event is ParticipantDisconnectedEvent) {
        // Remote user disconnected, we can leave the call
        _leaveCall();
    }
  }

    void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDurationInSeconds++;
      });
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }


  Future<void> _leaveCall() async {
    _callTimer?.cancel();

    try {
        await _apiService.chargeCallDuration(widget.roomName, _callDurationInSeconds);
    } catch(e) {
        debugPrint('Error charging for call: $e');
        // Even if charging fails, we should still leave the call
    }

    await _room?.disconnect();

    if (mounted) {
        Navigator.of(context).pop();
    }
  }

  void _toggleCamera() async {
      if (_room?.localParticipant != null) {
          final isEnabled = _room!.localParticipant!.isCameraEnabled();
          await _room!.localParticipant!.setCameraEnabled(!isEnabled);
          setState(() {
              _isCameraOn = !isEnabled;
          });
      }
  }

    void _toggleMic() async {
      if (_room?.localParticipant != null) {
          final isEnabled = _room!.localParticipant!.isMicrophoneEnabled();
          await _room!.localParticipant!.setMicrophoneEnabled(!isEnabled);
          setState(() {
              _isMicOn = !isEnabled;
          });
      }
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    // Call the cancel function to unsubscribe
    _cancelListenFunc?.call();
    _room?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote user's video (or profile pic)
          _buildRemoteView(),

          // Local user's video preview
          if (widget.isVideoCall && _isCameraOn)
            Positioned(
              top: 40,
              right: 20,
              child: _buildLocalView(),
            ),

          // Call controls and user info
          _buildOverlayControls(),
        ],
      ),
    );
  }

  Widget _buildRemoteView() {
    final remoteVideo = _videoTracks.firstWhere(
        (track) => track.participant is RemoteParticipant,
        orElse: () => ParticipantTrack(null, null), // Placeholder
    );

    if (remoteVideo.track != null && widget.isVideoCall) {
        // Use VideoViewFit here as required by VideoTrackRenderer
        return VideoTrackRenderer(remoteVideo.track as VideoTrack, fit: VideoViewFit.cover);
    } else {
        // Fallback for voice call or if video is not available yet
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    CircleAvatar(radius: 60, backgroundImage: NetworkImage(widget.remoteUser.profilePictureUrl)),
                    const SizedBox(height: 20),
                    Text(widget.remoteUser.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(_formatDuration(_callDurationInSeconds), style: const TextStyle(color: Colors.white70, fontSize: 18)),
                ],
            ),
        );
    }
  }

  Widget _buildLocalView() {
    final localVideo = _room?.localParticipant?.trackPublications.values.firstWhere((pub) => pub.kind == TrackType.VIDEO).track;
    if (localVideo != null) {
        return SizedBox(
            width: 120,
            height: 180,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                // Use VideoViewFit here
                child: VideoTrackRenderer(localVideo as VideoTrack, fit: VideoViewFit.cover),
            ),
        );
    }
    return Container(width: 120, height: 180, color: Colors.grey[800]); // Placeholder
  }

  Widget _buildOverlayControls() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
            padding: const EdgeInsets.only(bottom: 40.0, left: 20, right: 20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    if(widget.isVideoCall) // Show remote user name if it's a video call
                        Text(widget.remoteUser.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 3)])),
                    const SizedBox(height: 20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                            if(widget.isVideoCall)
                                _buildControlButton( _isCameraOn ? Icons.videocam : Icons.videocam_off, _toggleCamera),
                            _buildControlButton(_isMicOn ? Icons.mic : Icons.mic_off, _toggleMic),
                            _buildControlButton(Icons.call_end, _leaveCall, color: Colors.red),
                        ],
                    ),
                ],
            ),
        ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed, {Color color = Colors.blue}) {
    return FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: color,
        heroTag: null, // Important to have unique or null heroTags for multiple FABs
        child: Icon(icon, color: Colors.white),
    );
  }
}

// Helper class to associate a track with its participant
class ParticipantTrack {
    final Participant? participant;
    final Track? track;
    ParticipantTrack(this.participant, this.track);
}
