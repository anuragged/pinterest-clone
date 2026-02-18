import '../entities/pin.dart';

/// Abstract contract for pin data operations.
/// Implemented by data layer — domain layer stays pure.
abstract class PinRepositoryInterface {
  /// Fetch curated/trending pins for the feed.
  Future<List<Pin>> getFeedPins({required int page, required int perPage});

  /// Fetch a single pin by ID.
  Future<Pin> getPinById(String id);

  /// Fetch pins related to a given pin.
  Future<List<Pin>> getRelatedPins(String pinId, {required int page, required int perPage});

  /// Save a pin to a board (local + optimistic).
  Future<Pin> savePin(String pinId, {String? boardId});

  /// Unsave a pin.
  Future<Pin> unsavePin(String pinId);

  /// Record a click/view on a pin.
  Future<void> recordClick(String pinId);

  /// Get all locally saved pins.
  Future<List<Pin>> getSavedPins();
}
