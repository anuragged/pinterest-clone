/// Domain entity — no Flutter imports allowed.
/// Represents a collection/board of saved pins.
class Board {
  final String id;
  final String name;
  final String? description;
  final List<String> pinIds;
  final List<String> coverImageUrls;
  final bool isSecret;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Board({
    required this.id,
    required this.name,
    this.description,
    this.pinIds = const [],
    this.coverImageUrls = const [],
    this.isSecret = false,
    required this.createdAt,
    required this.updatedAt,
  });

  int get pinCount => pinIds.length;

  /// Cover is auto-generated from last 4 pins
  List<String> get coverImages =>
      coverImageUrls.length > 4 ? coverImageUrls.sublist(0, 4) : coverImageUrls;

  Board copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? pinIds,
    List<String>? coverImageUrls,
    bool? isSecret,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Board(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pinIds: pinIds ?? this.pinIds,
      coverImageUrls: coverImageUrls ?? this.coverImageUrls,
      isSecret: isSecret ?? this.isSecret,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Board && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
