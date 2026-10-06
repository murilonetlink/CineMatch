class Review {
  final String id;
  final String matchId;
  final String userId;
  final int? rating;
  final String? comment;
  final String userName;

  Review({
    required this.id,
    required this.matchId,
    required this.userId,
    this.rating,
    this.comment,
    required this.userName,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      matchId: map['match_id'],
      userId: map['user_id'],
      rating: map['rating'],
      comment: map['comment'],
      userName: map['users']['name'],
    );
  }
}
