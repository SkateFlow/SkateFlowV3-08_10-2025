class Rating {
  final String id;
  final String skateparkId;
  final String userId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.skateparkId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skateparkId': skateparkId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      skateparkId: json['skateparkId'],
      userId: json['userId'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}