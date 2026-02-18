import '../entities/pin.dart';
import '../repositories/pin_repository_interface.dart';

/// Use case: Fetch paginated feed pins.
class GetFeedPins {
  final PinRepositoryInterface _repository;

  GetFeedPins(this._repository);

  Future<List<Pin>> call({required int page, required int perPage}) {
    return _repository.getFeedPins(page: page, perPage: perPage);
  }
}

/// Use case: Fetch a single pin's detail.
class GetPinDetail {
  final PinRepositoryInterface _repository;

  GetPinDetail(this._repository);

  Future<Pin> call(String pinId) {
    return _repository.getPinById(pinId);
  }
}

/// Use case: Fetch related pins for a given pin.
class GetRelatedPins {
  final PinRepositoryInterface _repository;

  GetRelatedPins(this._repository);

  Future<List<Pin>> call(String pinId, {required int page, required int perPage}) {
    return _repository.getRelatedPins(pinId, page: page, perPage: perPage);
  }
}
