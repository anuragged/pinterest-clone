import '../../domain/entities/pin.dart';

/// Data model: Maps Pexels API JSON → domain Pin entity.
/// Handles aspect ratio preservation.
class PinModel extends Pin {
  const PinModel({
    required super.id,
    required super.imageUrl,
    required super.thumbnailUrl,
    super.mediumUrl,
    required super.width,
    required super.height,
    super.title,
    super.description,
    super.sourceUrl,
    required super.photographerName,
    super.photographerUrl,
    required super.photographerId,
    required super.avgColor,
    required super.createdAt,
    super.saves,
    super.clicks,
    super.tags,
    super.isSaved,
    super.savedToBoardId,
  });

  /// Parse from Pexels API response.
  factory PinModel.fromPexelsJson(Map<String, dynamic> json) {
    final src = json['src'] as Map<String, dynamic>? ?? {};
    return PinModel(
      id: json['id'].toString(),
      imageUrl: (src['large2x'] as String?) ?? (src['original'] as String?) ?? '',
      thumbnailUrl: (src['medium'] as String?) ?? (src['small'] as String?) ?? '',
      mediumUrl: src['large'] as String?,
      width: (json['width'] as int?) ?? 1,
      height: (json['height'] as int?) ?? 1,
      title: json['alt'] as String?,
      description: json['alt'] as String?,
      sourceUrl: json['url'] as String?,
      photographerName: (json['photographer'] as String?) ?? 'Unknown',
      photographerUrl: json['photographer_url'] as String?,
      photographerId: (json['photographer_id'] as int?) ?? 0,
      avgColor: (json['avg_color'] as String?) ?? '#E8E8E8',
      createdAt: DateTime.now(),
      saves: 0,
      clicks: 0,
      tags: const [],
      isSaved: false,
    );
  }

  /// Parse from Unsplash API response (fallback).
  factory PinModel.fromUnsplashJson(Map<String, dynamic> json) {
    final urls = json['urls'] as Map<String, dynamic>? ?? {};
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return PinModel(
      id: (json['id'] as String?) ?? '',
      imageUrl: (urls['regular'] as String?) ?? '',
      thumbnailUrl: (urls['thumb'] as String?) ?? '',
      mediumUrl: urls['small'] as String?,
      width: (json['width'] as int?) ?? 1,
      height: (json['height'] as int?) ?? 1,
      title: json['description'] as String? ?? json['alt_description'] as String?,
      description: json['description'] as String?,
      sourceUrl: json['links']?['html'] as String?,
      photographerName: (user['name'] as String?) ?? 'Unknown',
      photographerUrl: user['links']?['html'] as String?,
      photographerId: user['id'].hashCode,
      avgColor: (json['color'] as String?) ?? '#E8E8E8',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      saves: (json['likes'] as int?) ?? 0,
      clicks: 0,
      tags: const [],
      isSaved: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'mediumUrl': mediumUrl,
      'width': width,
      'height': height,
      'title': title,
      'description': description,
      'sourceUrl': sourceUrl,
      'photographerName': photographerName,
      'photographerUrl': photographerUrl,
      'photographerId': photographerId,
      'avgColor': avgColor,
      'createdAt': createdAt.toIso8601String(),
      'saves': saves,
      'clicks': clicks,
      'tags': tags,
      'isSaved': isSaved,
      'savedToBoardId': savedToBoardId,
    };
  }
}
