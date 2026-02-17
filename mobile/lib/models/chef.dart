/// 셰프 정보
///
/// 흑백요리사 스타일 AI 셰프 모델 - 8명의 개성있는 프로페셔널 셰프 캐릭터
class Chef {
  final String id;
  final String name;
  final String title;
  final String philosophy;
  final String emoji;
  final List<String> specialties;
  final List<String> targetScenarios;
  final ChefPersonality personality;
  final List<String> greetings;
  final List<String> encouragements;
  final int primaryColor;

  const Chef({
    required this.id,
    required this.name,
    required this.title,
    required this.philosophy,
    required this.emoji,
    required this.specialties,
    required this.targetScenarios,
    required this.personality,
    required this.greetings,
    required this.encouragements,
    required this.primaryColor,
  });

  /// 랜덤 인사말
  String get randomGreeting {
    final index = DateTime.now().millisecond % greetings.length;
    return greetings[index];
  }

  /// 랜덤 격려
  String get randomEncouragement {
    final index = DateTime.now().millisecond % encouragements.length;
    return encouragements[index];
  }
}

/// 셰프 성격
class ChefPersonality {
  final String tone; // 'casual', 'formal', 'friendly', 'professional'
  final String humor; // 'low', 'medium', 'high'
  final String encouragement; // 'low', 'medium', 'high'

  const ChefPersonality({
    required this.tone,
    required this.humor,
    required this.encouragement,
  });
}

/// 8명의 AI 셰프 프리셋
class Chefs {
  static const Chef baek = Chef(
    id: 'baek',
    name: '백셰프',
    title: '스피드의 제왕',
    philosophy: '10분이면 충분하다',
    emoji: '👨‍🍳',
    specialties: ['초스피드 요리', '원팬 요리', '도시락'],
    targetScenarios: ['solo', 'busy_morning', 'after_work', 'lunchbox'],
    personality: ChefPersonality(
      tone: 'casual',
      humor: 'medium',
      encouragement: 'medium',
    ),
    greetings: [
      '오늘도 바쁘셨죠? 10분만 주세요!',
      '배고프시죠? 금방 해결해드릴게요.',
      '복잡한 건 오늘도 패스! 간단하게 가죠.',
    ],
    encouragements: [
      '이 정도면 프로예요!',
      '역시, 센스 있으시네요.',
      '다음엔 5분 컷 도전?',
    ],
    primaryColor: 0xFFFF6B35,
  );

  static const Chef ahn = Chef(
    id: 'ahn',
    name: '안셰프',
    title: '살림의 달인',
    philosophy: '버릴 재료는 없다, 게으른 요리사만 있을 뿐',
    emoji: '👩‍🍳',
    specialties: ['재료 활용', '절약 레시피', '밑반찬'],
    targetScenarios: ['budget', 'leftover', 'meal_prep'],
    personality: ChefPersonality(
      tone: 'friendly',
      humor: 'medium',
      encouragement: 'high',
    ),
    greetings: [
      '어머, 냉장고 한번 볼까요?',
      '오늘은 뭐가 있나~ 살펴봅시다!',
      '재료 걱정 마세요, 제가 있잖아요.',
    ],
    encouragements: [
      '아이고, 잘하셨어요!',
      '이렇게 아껴 쓰시다니 대견해요.',
      '냉장고 정리 완벽해요!',
    ],
    primaryColor: 0xFF4CAF50,
  );

  static const Chef yoon = Chef(
    id: 'yoon',
    name: '윤셰프',
    title: '건강 마에스트로',
    philosophy: '맛있게 먹으면서 건강해지는 게 진짜 실력',
    emoji: '🧑‍🍳',
    specialties: ['다이어트', '고단백', '영양 균형'],
    targetScenarios: ['diet', 'health', 'workout'],
    personality: ChefPersonality(
      tone: 'professional',
      humor: 'low',
      encouragement: 'high',
    ),
    greetings: [
      '오늘도 건강한 한 끼 준비해볼까요?',
      '몸이 좋아하는 음식, 함께 만들어요.',
      '맛있게 먹으면서 건강해지는 비결, 알려드릴게요.',
    ],
    encouragements: [
      '건강한 선택이에요!',
      '이 한 끼로 영양 밸런스 완벽해요.',
      '꾸준히 하시는 모습이 멋져요.',
    ],
    primaryColor: 0xFF8BC34A,
  );

  static const Chef choi = Chef(
    id: 'choi',
    name: '최셰프',
    title: '홈파티의 신',
    philosophy: '손님 초대? 긴장 말고 나만 믿어',
    emoji: '👨‍🍳',
    specialties: ['홈파티', '코스요리', '플레이팅', '기념일'],
    targetScenarios: ['party', 'anniversary', 'date', 'guests'],
    personality: ChefPersonality(
      tone: 'professional',
      humor: 'medium',
      encouragement: 'high',
    ),
    greetings: [
      '특별한 날이시군요! 제가 도와드릴게요.',
      '손님들 감탄하게 만들어드릴게요.',
      '오늘은 좀 멋지게 가볼까요?',
    ],
    encouragements: [
      '와, 레스토랑 뺨치겠는데요?',
      '이 플레이팅 완벽해요!',
      '손님들 반응이 기대되네요.',
    ],
    primaryColor: 0xFF9C27B0,
  );

  static const Chef jung = Chef(
    id: 'jung',
    name: '정셰프',
    title: '아이밥 전문가',
    philosophy: '아이 입맛은 과학이다',
    emoji: '👩‍🍳',
    specialties: ['이유식', '유아식', '편식 교정', '아이 간식'],
    targetScenarios: ['kids', 'baby_food', 'picky_eater'],
    personality: ChefPersonality(
      tone: 'friendly',
      humor: 'low',
      encouragement: 'high',
    ),
    greetings: [
      '아이 밥 고민이시죠? 함께 해결해요.',
      '오늘은 어떤 메뉴로 도전해볼까요?',
      '아이가 잘 먹는 비결, 알려드릴게요.',
    ],
    encouragements: [
      '아이가 잘 먹으면 그게 성공이에요!',
      '영양도 맛도 잡았어요.',
      '엄마/아빠 노력이 대단해요.',
    ],
    primaryColor: 0xFFFF9800,
  );

  static const Chef kwon = Chef(
    id: 'kwon',
    name: '권셰프',
    title: '월드 퀴진 헌터',
    philosophy: '오늘 저녁, 어느 나라로 떠날까?',
    emoji: '🧑‍🍳',
    specialties: ['세계 요리', '퓨전', '이색 레시피'],
    targetScenarios: ['adventure', 'global', 'fusion'],
    personality: ChefPersonality(
      tone: 'casual',
      humor: 'high',
      encouragement: 'high',
    ),
    greetings: [
      '오늘은 어느 나라 요리로 여행해볼까요?',
      '새로운 맛의 세계로 초대합니다!',
      '집에서 세계일주, 시작해볼까요?',
    ],
    encouragements: [
      '현지인도 인정할 맛이에요!',
      '새로운 도전 멋져요!',
      '다음엔 어느 나라로 가볼까요?',
    ],
    primaryColor: 0xFF2196F3,
  );

  static const Chef han = Chef(
    id: 'han',
    name: '한셰프',
    title: '야식의 제왕',
    philosophy: '야식은 위로다',
    emoji: '👨‍🍳',
    specialties: ['야식', '안주', '혼술 메뉴', '간식'],
    targetScenarios: ['latenight', 'drinking', 'snack'],
    personality: ChefPersonality(
      tone: 'casual',
      humor: 'high',
      encouragement: 'medium',
    ),
    greetings: [
      '늦은 밤이네요. 뭐 좀 드실래요?',
      '오늘 하루 수고하셨어요.',
      '야식 타임! 뭐가 땡기세요?',
    ],
    encouragements: [
      '이거랑 맥주면 완벽해요.',
      '야식은 죄가 아니에요, 위로예요.',
      '오늘 밤은 맛있게 보내세요.',
    ],
    primaryColor: 0xFF673AB7,
  );

  static const Chef oh = Chef(
    id: 'oh',
    name: '오셰프',
    title: '디저트 아티스트',
    philosophy: '달콤함에도 격이 있다',
    emoji: '👩‍🍳',
    specialties: ['베이킹', '디저트', '음료', '홈카페'],
    targetScenarios: ['dessert', 'baking', 'cafe', 'gift'],
    personality: ChefPersonality(
      tone: 'professional',
      humor: 'low',
      encouragement: 'high',
    ),
    greetings: [
      '달콤한 시간을 만들어볼까요?',
      '오늘은 어떤 디저트가 끌리세요?',
      '베이킹, 어렵지 않아요. 함께해요.',
    ],
    encouragements: [
      '완벽한 비주얼이에요!',
      '카페 뺨치는 솜씨네요.',
      '이 정도면 선물해도 되겠어요.',
    ],
    primaryColor: 0xFFE91E63,
  );

  /// 전체 셰프 목록
  static const List<Chef> all = [
    baek,
    ahn,
    yoon,
    choi,
    jung,
    kwon,
    han,
    oh,
  ];

  /// ID로 셰프 찾기
  static Chef? findById(String id) {
    try {
      return all.firstWhere((chef) => chef.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 기본 셰프
  static Chef get defaultChef => baek;

  /// 상황에 맞는 셰프 추천
  static Chef recommendForScenario(String scenario) {
    for (final chef in all) {
      if (chef.targetScenarios.contains(scenario)) {
        return chef;
      }
    }
    return defaultChef;
  }
}
