/// 카테고리 → 이모지 매핑 유틸
String getCategoryEmoji(String? category) {
  switch (category) {
    case 'vegetable':
      return '🥬';
    case 'fruit':
      return '🍎';
    case 'meat':
      return '🍖';
    case 'seafood':
      return '🐟';
    case 'dairy':
      return '🥛';
    case 'egg':
      return '🥚';
    case 'grain':
      return '🍚';
    case 'seasoning':
      return '🧂';
    default:
      return '🍽️';
  }
}

/// 카테고리 → 한글 라벨
String getCategoryLabel(String? category) {
  switch (category) {
    case 'vegetable':
      return '채소';
    case 'fruit':
      return '과일';
    case 'meat':
      return '고기';
    case 'seafood':
      return '해산물';
    case 'dairy':
      return '유제품';
    case 'egg':
      return '계란';
    case 'grain':
      return '곡류';
    case 'seasoning':
      return '양념';
    default:
      return '기타';
  }
}
