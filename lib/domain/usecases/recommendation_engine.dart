import '../entities/pin.dart';

/// Non-ML recommendation engine.
/// Scoring: score = (saves × 3) + (clicks × 2) + recency_decay
/// Cold start: trending assets used.
class RecommendationEngine {
  RecommendationEngine._();

  /// Score a single pin.
  static double scorePin(Pin pin) {
    return pin.recommendationScore;
  }

  /// Sort pins by recommendation score (descending).
  static List<Pin> rankPins(List<Pin> pins) {
    final sorted = List<Pin>.from(pins);
    sorted.sort((a, b) => b.recommendationScore.compareTo(a.recommendationScore));
    return sorted;
  }

  /// Infer user interests from saved pins.
  /// Returns a set of photographer IDs / categories the user gravitates toward.
  static Set<int> inferInterests(List<Pin> savedPins) {
    final interests = <int>{};
    for (final pin in savedPins) {
      interests.add(pin.photographerId);
    }
    return interests;
  }

  /// Boost pins that match user interests.
  static List<Pin> personalizeRanking(List<Pin> pins, Set<int> interests) {
    if (interests.isEmpty) return rankPins(pins);

    final boosted = pins.map((pin) {
      final interestBoost = interests.contains(pin.photographerId) ? 5.0 : 0.0;
      return _ScoredPin(pin, pin.recommendationScore + interestBoost);
    }).toList();

    boosted.sort((a, b) => b.score.compareTo(a.score));
    return boosted.map((sp) => sp.pin).toList();
  }

  /// Cold start: just rank by trending (score-based).
  static List<Pin> coldStartRanking(List<Pin> pins) {
    return rankPins(pins);
  }
}

class _ScoredPin {
  final Pin pin;
  final double score;
  _ScoredPin(this.pin, this.score);
}
