import '../entities/pin.dart';
import '../repositories/pin_repository_interface.dart';

/// Use case: Save a pin to a board (optimistic update).
class SavePin {
  final PinRepositoryInterface _repository;

  SavePin(this._repository);

  Future<Pin> call(String pinId, {String? boardId}) {
    return _repository.savePin(pinId, boardId: boardId);
  }
}

/// Use case: Unsave a pin.
class UnsavePin {
  final PinRepositoryInterface _repository;

  UnsavePin(this._repository);

  Future<Pin> call(String pinId) {
    return _repository.unsavePin(pinId);
  }
}

/// Use case: Record a click/impression on a pin for recommendation scoring.
class RecordPinClick {
  final PinRepositoryInterface _repository;

  RecordPinClick(this._repository);

  Future<void> call(String pinId) {
    return _repository.recordClick(pinId);
  }
}

/// Use case: Retrieve all saved pins.
class GetSavedPins {
  final PinRepositoryInterface _repository;

  GetSavedPins(this._repository);

  Future<List<Pin>> call() {
    return _repository.getSavedPins();
  }
}
