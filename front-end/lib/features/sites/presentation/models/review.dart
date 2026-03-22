class Review {
  final String id;
  final String author;
  final String? title;
  final String comment;
  final int rating; // 1-5
  final DateTime date;
  final String? profilePicture;

  const Review({
    required this.id,
    required this.author,
    this.title,
    required this.comment,
    required this.rating,
    required this.date,
    this.profilePicture,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final dynamic rawRating = json['overall_rating'] ?? json['rating'];
    final firstName = json['first_name'] as String? ?? '';
    final lastName = json['last_name'] as String? ?? '';
    final author = '$firstName $lastName'.trim();

    return Review(
      id: '${json['id']}',
      author: author.isNotEmpty
          ? author
          : (json['author'] as String? ?? 'Utilisateur'),
      title: json['title'] as String?,
      comment: json['content'] as String? ?? json['comment'] as String? ?? '',
      rating: rawRating is int ? rawRating : int.tryParse('$rawRating') ?? 0,
      date:
          DateTime.tryParse(
            json['created_at'] as String? ?? json['date'] as String? ?? '',
          ) ??
          DateTime.now(),
      profilePicture: json['profile_picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      if (title != null) 'title': title,
      'comment': comment,
      'rating': rating,
      'date': date.toIso8601String(),
      if (profilePicture != null) 'profile_picture': profilePicture,
    };
  }

  /// Format date to relative time (e.g., "Il y a 2 jours")
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'À l\'instant';
        }
        return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
      }
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years an${years > 1 ? 's' : ''}';
    }
  }
}
