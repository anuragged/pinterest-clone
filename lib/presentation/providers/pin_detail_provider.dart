import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pin.dart';
import '../../core/constants/api_constants.dart';
import 'feed_provider.dart';

// ── Pin Detail State ──

class PinDetailState {
  final Pin? pin;
  final List<Pin> relatedPins;
  final bool isLoading;
  final bool isLoadingRelated;
  final bool hasMoreRelated;
  final int relatedPage;
  final String? error;

  const PinDetailState({
    this.pin,
    this.relatedPins = const [],
    this.isLoading = false,
    this.isLoadingRelated = false,
    this.hasMoreRelated = true,
    this.relatedPage = 1,
    this.error,
  });

  PinDetailState copyWith({
    Pin? pin,
    List<Pin>? relatedPins,
    bool? isLoading,
    bool? isLoadingRelated,
    bool? hasMoreRelated,
    int? relatedPage,
    String? error,
  }) {
    return PinDetailState(
      pin: pin ?? this.pin,
      relatedPins: relatedPins ?? this.relatedPins,
      isLoading: isLoading ?? this.isLoading,
      isLoadingRelated: isLoadingRelated ?? this.isLoadingRelated,
      hasMoreRelated: hasMoreRelated ?? this.hasMoreRelated,
      relatedPage: relatedPage ?? this.relatedPage,
      error: error,
    );
  }
}

// ── Pin Detail Notifier ──

class PinDetailNotifier extends StateNotifier<PinDetailState> {
  final Ref _ref;

  PinDetailNotifier(this._ref) : super(const PinDetailState());

  Future<void> loadPin(String pinId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = _ref.read(pinRepositoryProvider);
      final pin = await repo.getPinById(pinId);

      // Record click for recommendation scoring
      final recordClick = _ref.read(recordPinClickProvider);
      await recordClick(pinId);

      state = state.copyWith(pin: pin, isLoading: false);

      // Load related pins immediately
      _loadRelatedPins(pinId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Set pin from cached data (for instant display from feed).
  void setPinFromCache(Pin pin) {
    state = state.copyWith(pin: pin, isLoading: false);
    _loadRelatedPins(pin.id);
  }

  Future<void> _loadRelatedPins(String pinId) async {
    state = state.copyWith(isLoadingRelated: true);
    try {
      final repo = _ref.read(pinRepositoryProvider);
      final related = await repo.getRelatedPins(
        pinId,
        page: 1,
        perPage: ApiConstants.relatedPinsPageSize,
      );
      state = state.copyWith(
        relatedPins: related,
        isLoadingRelated: false,
        relatedPage: 1,
        hasMoreRelated: related.length >= ApiConstants.relatedPinsPageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingRelated: false);
    }
  }

  Future<void> loadMoreRelated() async {
    if (state.isLoadingRelated || !state.hasMoreRelated || state.pin == null) return;
    state = state.copyWith(isLoadingRelated: true);

    try {
      final nextPage = state.relatedPage + 1;
      final repo = _ref.read(pinRepositoryProvider);
      final related = await repo.getRelatedPins(
        state.pin!.id,
        page: nextPage,
        perPage: ApiConstants.relatedPinsPageSize,
      );
      state = state.copyWith(
        relatedPins: [...state.relatedPins, ...related],
        isLoadingRelated: false,
        relatedPage: nextPage,
        hasMoreRelated: related.length >= ApiConstants.relatedPinsPageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingRelated: false);
    }
  }

  void updatePin(Pin updatedPin) {
    state = state.copyWith(pin: updatedPin);
  }
}

// ── Provider ──

final pinDetailProvider =
    StateNotifierProvider.autoDispose<PinDetailNotifier, PinDetailState>((ref) {
  return PinDetailNotifier(ref);
});
