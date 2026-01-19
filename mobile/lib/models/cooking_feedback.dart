/// 익힘 정도
enum Doneness {
  undercooked,
  perfect,
  overcooked,
  notApplicable;

  static Doneness fromString(String value) {
    switch (value.toLowerCase()) {
      case 'undercooked':
        return Doneness.undercooked;
      case 'perfect':
        return Doneness.perfect;
      case 'overcooked':
        return Doneness.overcooked;
      default:
        return Doneness.notApplicable;
    }
  }

  String get displayName {
    switch (this) {
      case Doneness.undercooked:
        return '덜 익음';
      case Doneness.perfect:
        return '적절함';
      case Doneness.overcooked:
        return '과하게 익음';
      case Doneness.notApplicable:
        return '해당 없음';
    }
  }
}

/// 요리 사진 분석 피드백
class CookingFeedback {
  final Doneness doneness;
  final String donenessDescription;
  final int platingScore;
  final String platingFeedback;
  final String overallAssessment;
  final List<String> suggestions;
  final String encouragement;

  const CookingFeedback({
    required this.doneness,
    required this.donenessDescription,
    required this.platingScore,
    required this.platingFeedback,
    required this.overallAssessment,
    required this.suggestions,
    required this.encouragement,
  });

  factory CookingFeedback.fromJson(Map<String, dynamic> json) {
    return CookingFeedback(
      doneness: Doneness.fromString(json['doneness'] ?? 'not_applicable'),
      donenessDescription: json['donenessDescription'] ?? '',
      platingScore: (json['platingScore'] as num?)?.toInt() ?? 5,
      platingFeedback: json['platingFeedback'] ?? '',
      overallAssessment: json['overallAssessment'] ?? '',
      suggestions: List<String>.from(json['suggestions'] ?? []),
      encouragement: json['encouragement'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'doneness': doneness.name,
        'donenessDescription': donenessDescription,
        'platingScore': platingScore,
        'platingFeedback': platingFeedback,
        'overallAssessment': overallAssessment,
        'suggestions': suggestions,
        'encouragement': encouragement,
      };
}
