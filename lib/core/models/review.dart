/// Model representing a devotee review received by a Poojari.
class Review {
  final String id;
  final String bookingId;
  final String customerFirstName;
  final int stars; // 1 to 5
  final String? comment;
  final String poojaName;
  final String date;
  final DateTime createdAt;
  final String? poojariReply;
  final DateTime? repliedAt;

  const Review({
    required this.id,
    required this.bookingId,
    required this.customerFirstName,
    required this.stars,
    this.comment,
    required this.poojaName,
    required this.date,
    required this.createdAt,
    this.poojariReply,
    this.repliedAt,
  });

  bool get hasReply => poojariReply != null && poojariReply!.trim().isNotEmpty;

  /// Returns a human-friendly relative time string (e.g. 'Just now', '2d ago')
  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return date;
  }

  /// Relative time for the Poojari's reply
  String get replyRelativeTime {
    if (repliedAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(repliedAt!);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${repliedAt!.day}/${repliedAt!.month}/${repliedAt!.year}';
  }

  Review copyWith({
    String? id,
    String? bookingId,
    String? customerFirstName,
    int? stars,
    String? comment,
    String? poojaName,
    String? date,
    DateTime? createdAt,
    String? poojariReply,
    DateTime? repliedAt,
  }) {
    return Review(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      customerFirstName: customerFirstName ?? this.customerFirstName,
      stars: stars ?? this.stars,
      comment: comment ?? this.comment,
      poojaName: poojaName ?? this.poojaName,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      poojariReply: poojariReply ?? this.poojariReply,
      repliedAt: repliedAt ?? this.repliedAt,
    );
  }
}
