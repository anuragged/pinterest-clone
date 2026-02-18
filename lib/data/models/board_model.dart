import '../../domain/entities/board.dart';

/// Data model for Board with serialization.
class BoardModel extends Board {
  const BoardModel({
    required super.id,
    required super.name,
    super.description,
    super.pinIds,
    super.coverImageUrls,
    super.isSecret,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    return BoardModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      pinIds: (json['pinIds'] as List<dynamic>?)?.cast<String>() ?? [],
      coverImageUrls: (json['coverImageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      isSecret: (json['isSecret'] as bool?) ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pinIds': pinIds,
      'coverImageUrls': coverImageUrls,
      'isSecret': isSecret,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from domain entity.
  factory BoardModel.fromEntity(Board board) {
    return BoardModel(
      id: board.id,
      name: board.name,
      description: board.description,
      pinIds: board.pinIds,
      coverImageUrls: board.coverImageUrls,
      isSecret: board.isSecret,
      createdAt: board.createdAt,
      updatedAt: board.updatedAt,
    );
  }
}
