import 'package:dio/dio.dart';
import '../../data/models/pin_model.dart';
import '../../services/network_service.dart';
import '../../core/constants/api_constants.dart';

/// Remote data source: fetches images from Pexels API (primary)
/// with Unsplash fallback if quota exceeded.
class PexelsApiService {
  final NetworkService _networkService;

  PexelsApiService(this._networkService);

  /// Fetch curated (trending) photos for feed.
  Future<List<PinModel>> getCuratedPhotos({
    required int page,
    int perPage = ApiConstants.pexelsPerPage,
  }) async {
    try {
      final response = await _networkService.pexels.get(
        '/curated',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parsePexelsResponse(response);
    } on DioException catch (e) {
      if (_isQuotaExceeded(e)) {
        return _fallbackCurated(page: page, perPage: perPage);
      }
      rethrow;
    }
  }

  /// Search photos by query.
  Future<List<PinModel>> searchPhotos({
    required String query,
    required int page,
    int perPage = ApiConstants.pexelsPerPage,
  }) async {
    try {
      final response = await _networkService.pexels.get(
        '/search',
        queryParameters: {
          'query': query,
          'page': page,
          'per_page': perPage,
        },
      );
      return _parsePexelsResponse(response);
    } on DioException catch (e) {
      if (_isQuotaExceeded(e)) {
        return _fallbackSearch(query: query, page: page, perPage: perPage);
      }
      rethrow;
    }
  }

  /// Get a single photo by ID.
  Future<PinModel> getPhotoById(String id) async {
    try {
      final response = await _networkService.pexels.get('/photos/$id');
      return PinModel.fromPexelsJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (_isQuotaExceeded(e)) {
        return _fallbackPhotoById(id);
      }
      rethrow;
    }
  }

  // ── Fallback to Unsplash ──

  Future<List<PinModel>> _fallbackCurated({
    required int page,
    required int perPage,
  }) async {
    final response = await _networkService.unsplash.get(
      '/photos',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        'order_by': 'popular',
      },
    );
    final list = response.data as List<dynamic>;
    return list
        .map((json) => PinModel.fromUnsplashJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<PinModel>> _fallbackSearch({
    required String query,
    required int page,
    required int perPage,
  }) async {
    final response = await _networkService.unsplash.get(
      '/search/photos',
      queryParameters: {
        'query': query,
        'page': page,
        'per_page': perPage,
      },
    );
    final results = (response.data as Map<String, dynamic>)['results'] as List<dynamic>;
    return results
        .map((json) => PinModel.fromUnsplashJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PinModel> _fallbackPhotoById(String id) async {
    final response = await _networkService.unsplash.get('/photos/$id');
    return PinModel.fromUnsplashJson(response.data as Map<String, dynamic>);
  }

  // ── Helpers ──

  List<PinModel> _parsePexelsResponse(Response<dynamic> response) {
    final data = response.data as Map<String, dynamic>;
    final photos = data['photos'] as List<dynamic>? ?? [];
    return photos
        .map((json) => PinModel.fromPexelsJson(json as Map<String, dynamic>))
        .toList();
  }

  bool _isQuotaExceeded(DioException e) {
    return e.response?.statusCode == 429;
  }
}
