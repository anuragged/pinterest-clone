import '../../domain/entities/pin.dart';
import '../../domain/repositories/pin_repository_interface.dart';
import '../sources/pexels_api_service.dart';
import '../sources/local_cache_service.dart';

/// Concrete implementation of PinRepositoryInterface.
/// Coordinates between remote API and local cache.
class PinRepositoryImpl implements PinRepositoryInterface {
  final PexelsApiService _apiService;
  final LocalCacheService _cacheService;

  // In-memory pin cache for quick lookups
  final Map<String, Pin> _pinCache = {};

  PinRepositoryImpl(this._apiService, this._cacheService);

  @override
  Future<List<Pin>> getFeedPins({required int page, required int perPage}) async {
    final pins = await _apiService.getCuratedPhotos(page: page, perPage: perPage);
    final enriched = pins.map((pin) {
      final enrichedPin = _cacheService.enrichPin(pin);
      _pinCache[enrichedPin.id] = enrichedPin;
      return enrichedPin;
    }).toList();
    return enriched;
  }

  @override
  Future<Pin> getPinById(String id) async {
    // Check local cache first
    if (_pinCache.containsKey(id)) {
      return _cacheService.enrichPin(_pinCache[id]!);
    }
    final pin = await _apiService.getPhotoById(id);
    final enriched = _cacheService.enrichPin(pin);
    _pinCache[enriched.id] = enriched;
    return enriched;
  }

  @override
  Future<List<Pin>> getRelatedPins(String pinId, {required int page, required int perPage}) async {
    // Pexels doesn't have a "related" endpoint, so we use curated with offset
    // to simulate related content. In production, this would use visual similarity.
    final offset = pinId.hashCode.abs() % 50 + page;
    final pins = await _apiService.getCuratedPhotos(page: offset, perPage: perPage);
    return pins.map((pin) {
      final enriched = _cacheService.enrichPin(pin);
      _pinCache[enriched.id] = enriched;
      return enriched;
    }).toList();
  }

  @override
  Future<Pin> savePin(String pinId, {String? boardId}) async {
    final pin = _pinCache[pinId];
    if (pin == null) throw Exception('Pin not found in cache');

    final savedPin = pin.copyWith(isSaved: true, savedToBoardId: boardId);
    _cacheService.savePin(savedPin);
    _pinCache[pinId] = savedPin;
    return savedPin;
  }

  @override
  Future<Pin> unsavePin(String pinId) async {
    final pin = _pinCache[pinId];
    if (pin == null) throw Exception('Pin not found in cache');

    final unsavedPin = pin.copyWith(isSaved: false, savedToBoardId: null);
    _cacheService.unsavePin(pinId);
    _pinCache[pinId] = unsavedPin;
    return unsavedPin;
  }

  @override
  Future<void> recordClick(String pinId) async {
    _cacheService.recordClick(pinId);
    if (_pinCache.containsKey(pinId)) {
      _pinCache[pinId] = _cacheService.enrichPin(_pinCache[pinId]!);
    }
  }

  @override
  Future<List<Pin>> getSavedPins() async {
    return _cacheService.savedPins;
  }
}
