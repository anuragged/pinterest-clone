/// Domain entity — no Flutter imports allowed.
/// Represents a single pin (image post) in the feed.
class Pin {
  final String id;
  final String imageUrl;
  final String thumbnailUrl;
  final String? mediumUrl;
  final int width;
  final int height;
  final String? title;
  final String? description;
  final String? sourceUrl;
  final String photographerName;
  final String? photographerUrl;
  final int photographerId;
  final String avgColor;
  final DateTime createdAt;
  final int saves;
  final int clicks;
  final List<String> tags;
  final bool isSaved;
  final String? savedToBoardId;

  const Pin({
    required this.id,
    required this.imageUrl,
    required this.thumbnailUrl,
    this.mediumUrl,
    required this.width,
    required this.height,
    this.title,
    this.description,
    this.sourceUrl,
    required this.photographerName,
    this.photographerUrl,
    required this.photographerId,
    required this.avgColor,
    required this.createdAt,
    this.saves = 0,
    this.clicks = 0,
    this.tags = const [],
    this.isSaved = false,
    this.savedToBoardId,
  });

  /// Aspect ratio used by masonry grid to determine card height.
  double get aspectRatio => width > 0 && height > 0 ? width / height : 1.0;

  /// Computed recommendation score.
  /// MANDATORY: score = (saves × 3) + (clicks × 2) + recency_decay
  double get recommendationScore {
    final daysSince = DateTime.now().difference(createdAt).inDays;
    final recencyDecay = 1.0 / (1.0 + daysSince * 0.1);
    return (saves * 3) + (clicks * 2) + recencyDecay;
  }

  Pin copyWith({
    String? id,
    String? imageUrl,
    String? thumbnailUrl,
    String? mediumUrl,
    int? width,
    int? height,
    String? title,
    String? description,
    String? sourceUrl,
    String? photographerName,
    String? photographerUrl,
    int? photographerId,
    String? avgColor,
    DateTime? createdAt,
    int? saves,
    int? clicks,
    List<String>? tags,
    bool? isSaved,
    String? savedToBoardId,
  }) {
    return Pin(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mediumUrl: mediumUrl ?? this.mediumUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      title: title ?? this.title,
      description: description ?? this.description,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      photographerName: photographerName ?? this.photographerName,
      photographerUrl: photographerUrl ?? this.photographerUrl,
      photographerId: photographerId ?? this.photographerId,
      avgColor: avgColor ?? this.avgColor,
      createdAt: createdAt ?? this.createdAt,
      saves: saves ?? this.saves,
      clicks: clicks ?? this.clicks,
      tags: tags ?? this.tags,
      isSaved: isSaved ?? this.isSaved,
      savedToBoardId: savedToBoardId ?? this.savedToBoardId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Pin && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
