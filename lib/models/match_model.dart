import 'media.dart';

class MatchModel {
  final String id;
  final int mediaId;
  final String mediaType;
  bool watched;
  final DateTime createdAt;
  Media? mediaDetails;

  MatchModel({
    required this.id,
    required this.mediaId,
    required this.mediaType,
    required this.watched,
    required this.createdAt,
    this.mediaDetails,
  });

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'],
      mediaId: map['media_id'],
      mediaType: map['media_type'],
      watched: map['watched'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
