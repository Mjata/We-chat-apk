
import 'package:myapp/models/user.dart';

class LiveStream {
  final String id;
  final User host;
  final String title;
  final int viewerCount;

  LiveStream({
    required this.id,
    required this.host,
    required this.title,
    required this.viewerCount,
  });

  factory LiveStream.fromJson(Map<String, dynamic> json) {
    return LiveStream(
      id: json['_id'] ?? '',
      host: User.fromJson(json['host']),
      title: json['title'] ?? 'Live Stream',
      viewerCount: json['viewerCount'] ?? 0,
    );
  }
}
