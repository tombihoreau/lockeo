class Review {
  final int id;
  final int ownerId;
  final int authorId;
  final int rating;
  final String title;
  final String comment;
  final String date;

  Review({
    required this.id,
    required this.ownerId,
    required this.authorId,
    required this.rating,
    required this.title,
    required this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      ownerId: json['owner_id'],
      authorId: json['author_id'],
      rating: json['rating'],
      title: json['title'],
      comment: json['comment'],
      date: json['date'],
    );
  }
}
