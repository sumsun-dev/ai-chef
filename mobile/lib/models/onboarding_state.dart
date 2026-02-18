/// 온보딩 간소 재료 (이름 + 카테고리만)
class SimpleIngredient {
  final String name;
  final String category;

  SimpleIngredient({required this.name, required this.category});
}

/// 온보딩 전체 상태
class OnboardingState {
  String skillLevel;
  List<String> scenarios;
  Map<String, bool> tools;
  String timePreference;
  String budgetPreference;

  // Chef settings
  String? selectedPresetId;
  String chefName;
  String personality;
  List<String> expertise;
  String formality;
  String emojiUsage;
  String technicality;

  // First fridge
  List<SimpleIngredient> firstIngredients;

  OnboardingState({
    this.skillLevel = 'beginner',
    List<String>? scenarios,
    Map<String, bool>? tools,
    this.timePreference = '20min',
    this.budgetPreference = 'medium',
    this.selectedPresetId,
    this.chefName = 'AI 셰프',
    this.personality = 'friendly',
    List<String>? expertise,
    this.formality = 'formal',
    this.emojiUsage = 'medium',
    this.technicality = 'general',
    List<SimpleIngredient>? firstIngredients,
  })  : scenarios = scenarios ?? [],
        tools = tools ?? Map.from(_defaultTools),
        expertise = expertise ?? ['한식'],
        firstIngredients = firstIngredients ?? [];

  /// DB insert_default_cooking_tools() 와 일치하는 기본 도구
  static const Map<String, bool> _defaultTools = {
    'frying_pan': true,
    'pot': true,
    'stove': true,
    'microwave': true,
    'rice_cooker': true,
    'air_fryer': false,
    'oven': false,
    'blender': false,
  };

  /// tool_key → 한글 이름 매핑
  static const Map<String, String> toolKeyToName = {
    'frying_pan': '프라이팬',
    'pot': '냄비',
    'stove': '가스레인지/인덕션',
    'microwave': '전자레인지',
    'rice_cooker': '전기밥솥',
    'air_fryer': '에어프라이어',
    'oven': '오븐',
    'blender': '블렌더/믹서기',
  };
}
