/// 앱 전역 상수
class AppConstants {
  AppConstants._();

  // Gemini 모델명
  static const geminiFlashModel = 'gemini-2.5-flash';
  static const geminiProModel = 'gemini-2.5-pro';

  // 이미지 제한
  static const maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const allowedImageMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
  ];

  // updateUserProfile 허용 필드
  static const allowedProfileFields = {
    'name',
    'skill_level',
    'scenarios',
    'time_preference',
    'budget_preference',
    'household_size',
    'primary_chef_id',
    'ai_chef_name',
    'ai_chef_personality',
    'ai_chef_custom_personality',
    'ai_chef_expertise',
    'ai_chef_cooking_philosophy',
    'ai_chef_formality',
    'ai_chef_emoji_usage',
    'ai_chef_technicality',
  };
}
