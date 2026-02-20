import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthResponse, AuthState, User;

import 'package:ai_chef/models/ai_response.dart';
import 'package:ai_chef/models/ingredient.dart';
import 'package:ai_chef/models/cooking_feedback.dart';
import 'package:ai_chef/models/chef_config.dart';
import 'package:ai_chef/models/recipe.dart';
import 'package:ai_chef/services/auth_service.dart';
import 'package:ai_chef/services/cooking_audio_service.dart';
import 'package:ai_chef/services/function_calling_service.dart';
import 'package:ai_chef/services/gemini_service.dart';
import 'package:ai_chef/services/ingredient_service.dart';
import 'package:ai_chef/services/chat_service.dart';
import 'package:ai_chef/services/notification_service.dart';
import 'package:ai_chef/services/receipt_ocr_service.dart';
import 'package:ai_chef/models/cooking_statistics.dart';
import 'package:ai_chef/models/recipe_history.dart';
import 'package:ai_chef/services/recipe_service.dart';
import 'package:ai_chef/services/tts_service.dart';
import 'package:ai_chef/services/tool_service.dart';
import 'package:ai_chef/services/voice_command_service.dart';

import 'package:ai_chef/models/chat_message.dart';
import 'package:ai_chef/models/shopping_item.dart';
import 'package:ai_chef/services/shopping_service.dart';

export 'package:ai_chef/models/ingredient.dart' show ExpiryIngredientGroup;

// --- MaterialApp 래퍼 ---

/// GoRouter 없이 단순 위젯 테스트용 래퍼
Widget wrapWithMaterialApp(Widget child) {
  return MaterialApp(home: child);
}

// --- Fake 서비스 ---

class FakeAuthService with Fake implements AuthService {
  Map<String, dynamic>? profileData;
  bool signOutCalled = false;

  FakeAuthService({this.profileData});

  @override
  User? get currentUser => null;

  @override
  Future<Map<String, dynamic>?> getUserProfile() async => profileData;

  @override
  Future<void> updateUserProfile(Map<String, dynamic> data) async {}

  @override
  Future<AuthResponse> signInWithGoogle() async {
    throw UnimplementedError('FakeAuthService.signInWithGoogle');
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();

  @override
  Future<void> updateAIChefSettings({
    required String name,
    required String personality,
    String? customPersonality,
    required List<String> expertise,
    String? cookingPhilosophy,
    required String formality,
    required String emojiUsage,
    required String technicality,
  }) async {}

  @override
  Future<void> saveOnboardingData(dynamic state) async {}
}

class FakeIngredientService with Fake implements IngredientService {
  List<Ingredient> ingredients;
  ExpiryIngredientGroup? expiryGroup;

  FakeIngredientService({
    this.ingredients = const [],
    this.expiryGroup,
  });

  @override
  Future<List<Ingredient>> getUserIngredients() async => ingredients;

  @override
  Future<ExpiryIngredientGroup> getExpiryIngredientGroup() async {
    return expiryGroup ??
        ExpiryIngredientGroup(
          expiredItems: [],
          criticalItems: [],
          warningItems: [],
          safeItems: [],
        );
  }

  @override
  Future<List<Ingredient>> getIngredients() async => ingredients;

  @override
  Future<Ingredient> getIngredient(String id) async => ingredients.first;

  @override
  Future<Ingredient> addIngredient(Ingredient ingredient) async => ingredient;

  @override
  Future<List<Ingredient>> saveIngredients(List<Ingredient> ingredients) async =>
      ingredients;

  @override
  Future<Ingredient> updateIngredient(Ingredient ingredient) async => ingredient;

  @override
  Future<void> deleteIngredient(String? id) async {}

  @override
  Future<List<Ingredient>> getExpiringIngredients({int days = 7}) async => [];

  @override
  Future<List<Ingredient>> getExpiredIngredients() async => [];

  @override
  Future<List<Ingredient>> getIngredientsByCategory(String category) async => [];

  @override
  Future<List<Ingredient>> getIngredientsByStorageLocation(
      StorageLocation location) async => [];

  @override
  Future<List<Ingredient>> searchIngredients(String query) async => [];
}

class FakeGeminiService with Fake implements GeminiService {
  Recipe? generatedRecipe;
  bool shouldThrow;

  FakeGeminiService({this.generatedRecipe, this.shouldThrow = false});

  @override
  Future<Recipe> generateRecipe({
    required List<String> ingredients,
    required List<String> tools,
    required dynamic chefConfig,
    String? cuisine,
    dynamic difficulty,
    int? cookingTime,
    int servings = 1,
  }) async {
    if (shouldThrow) throw Exception('API 오류');
    return generatedRecipe ?? _defaultRecipe();
  }

  @override
  Future<String> sendMessage({
    required String message,
    required dynamic chefConfig,
    List<String>? ingredients,
    List<String>? tools,
  }) async {
    return '테스트 응답';
  }

  @override
  String generateSystemPrompt(dynamic config) => 'test prompt';

  @override
  String getPersonalityPrompt(dynamic personality, String? customPersonality) =>
      'test';

  @override
  String getSpeakingStylePrompt(dynamic style) => 'test';

  @override
  Future<AIResponse> sendMessageWithTools({
    required String message,
    required dynamic chefConfig,
    required FunctionCallingService functionCallingService,
    List<String>? ingredients,
    List<String>? tools,
  }) async {
    return TextResponse(text: '테스트 Function Calling 응답');
  }

  @override
  Future<CookingFeedback> analyzeCookingPhoto({
    required Uint8List imageBytes,
    required String mimeType,
    required AIChefConfig chefConfig,
    String? currentStep,
    String? recipeName,
  }) async {
    throw UnimplementedError();
  }

  static Recipe _defaultRecipe() {
    return Recipe(
      title: '테스트 레시피',
      description: '테스트용 레시피입니다',
      cuisine: '한식',
      difficulty: RecipeDifficulty.easy,
      cookingTime: 15,
      servings: 1,
      ingredients: [],
      tools: [],
      instructions: [],
      nutrition: NutritionInfo(calories: 300, protein: 10, carbs: 40, fat: 8),
      chefNote: '테스트 노트',
    );
  }
}

class FakeRecipeService with Fake implements RecipeService {
  List<Recipe> bookmarkedRecipes;
  List<Map<String, dynamic>> history;
  List<RecipeHistory> typedHistory;
  CookingStatistics? statistics;

  FakeRecipeService({
    this.bookmarkedRecipes = const [],
    this.history = const [],
    this.typedHistory = const [],
    this.statistics,
  });

  @override
  Future<List<Recipe>> getBookmarkedRecipes() async => bookmarkedRecipes;

  @override
  Future<List<Map<String, dynamic>>> getRecipeHistory({int limit = 50}) async =>
      history;

  @override
  Future<List<RecipeHistory>> getRecipeHistoryTyped({int limit = 50}) async =>
      typedHistory;

  @override
  Future<CookingStatistics> getCookingStatistics() async =>
      statistics ?? CookingStatistics.empty();

  @override
  Future<List<Recipe>> getSavedRecipes() async => [];

  @override
  Future<Recipe> saveRecipe(Recipe recipe) async => recipe;

  @override
  Future<void> toggleBookmark(String recipeId, bool isBookmarked) async {}

  @override
  Future<void> deleteRecipe(String recipeId) async {}

  @override
  Future<void> saveRecipeHistory({
    required String recipeTitle,
    String? recipeId,
    String? chefId,
  }) async {}
}

class FakeReceiptOcrService with Fake implements ReceiptOcrService {
  ReceiptOcrResult? result;
  bool shouldThrow;

  FakeReceiptOcrService({this.result, this.shouldThrow = false});

  @override
  Future<ReceiptOcrResult> extractIngredientsFromReceipt(dynamic imageFile) async {
    if (shouldThrow) throw Exception('OCR 오류');
    return result ??
        ReceiptOcrResult(ingredients: [], purchaseDate: DateTime.now());
  }

  @override
  Future<ReceiptOcrResult> extractIngredientsFromBytes(dynamic bytes) async {
    if (shouldThrow) throw Exception('OCR 오류');
    return result ??
        ReceiptOcrResult(ingredients: [], purchaseDate: DateTime.now());
  }

  @override
  String buildOcrPrompt() => '테스트 프롬프트';

  @override
  ReceiptOcrResult parseResponse(String text) {
    return result ??
        ReceiptOcrResult(ingredients: [], purchaseDate: DateTime.now());
  }
}

class FakeToolService with Fake implements ToolService {
  List<String> tools;

  FakeToolService({this.tools = const ['프라이팬', '냄비', '전자레인지', '오븐']});

  @override
  Future<List<String>> getAvailableToolNames() async => tools;
}

class FakeNotificationService with Fake implements NotificationService {
  bool scheduleCalled = false;
  bool cancelCalled = false;
  bool permissionRequested = false;
  String? lastRecommendationMessage;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async {
    permissionRequested = true;
    return true;
  }

  @override
  Future<void> scheduleDailyExpiryCheck() async {
    scheduleCalled = true;
  }

  @override
  Future<void> cancelAllNotifications() async {
    cancelCalled = true;
  }

  @override
  Future<void> cancelNotification(int id) async {}

  @override
  Future<void> checkAndShowExpiryNotifications() async {}

  @override
  Future<void> showRecipeRecommendation({required String message}) async {
    lastRecommendationMessage = message;
  }
}

class FakeTtsService with Fake implements TtsService {
  String? lastSpokenText;
  bool stopCalled = false;
  int speakCallCount = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> speak(String text) async {
    lastSpokenText = text;
    speakCallCount++;
  }

  @override
  Future<void> stop() async {
    stopCalled = true;
  }

  @override
  Future<void> dispose() async {
    stopCalled = true;
  }
}

class FakeVoiceCommandService with Fake implements VoiceCommandService {
  bool isListeningResult = false;

  @override
  bool get isListening => isListeningResult;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> startListening({
    required void Function(VoiceCommand command) onCommand,
    void Function(String partialText)? onPartial,
  }) async {
    isListeningResult = true;
  }

  @override
  Future<void> stopListening() async {
    isListeningResult = false;
  }

  @override
  VoiceCommand parseCommand(String text) => UnknownCommand(text);
}

class FakeChatService with Fake implements ChatService {
  List<ChatMessage> chatHistory;
  bool saveCalled = false;
  bool clearCalled = false;

  FakeChatService({this.chatHistory = const []});

  @override
  Future<List<ChatMessage>> getChatHistory({
    required String chefId,
    int limit = 50,
  }) async =>
      chatHistory;

  @override
  Future<void> saveMessage(ChatMessage message) async {
    saveCalled = true;
  }

  @override
  Future<void> saveMessages(List<ChatMessage> messages) async {
    saveCalled = true;
  }

  @override
  Future<void> clearChatHistory(String chefId) async {
    clearCalled = true;
  }
}

class FakeCookingAudioService with Fake implements CookingAudioService {
  int playCount = 0;
  int vibrateCount = 0;
  int notifyCount = 0;

  @override
  Future<void> playTimerDone() async {
    playCount++;
  }

  @override
  Future<void> vibrate() async {
    vibrateCount++;
  }

  @override
  Future<void> notifyTimerComplete() async {
    notifyCount++;
  }

  @override
  Future<void> dispose() async {}
}

class FakeShoppingService with Fake implements ShoppingService {
  List<ShoppingItem> items;
  List<ShoppingItem> checkedItems;
  bool addItemCalled = false;
  bool addItemsCalled = false;
  bool toggleCheckCalled = false;
  bool deleteItemCalled = false;
  bool deleteCheckedCalled = false;

  FakeShoppingService({
    this.items = const [],
    this.checkedItems = const [],
  });

  @override
  Future<List<ShoppingItem>> getShoppingItems() async => items;

  @override
  Future<ShoppingItem> addShoppingItem(ShoppingItem item) async {
    addItemCalled = true;
    return item.copyWith(id: 'new-id');
  }

  @override
  Future<List<ShoppingItem>> addShoppingItems(List<ShoppingItem> items) async {
    addItemsCalled = true;
    return items;
  }

  @override
  Future<void> toggleCheck(String id, bool isChecked) async {
    toggleCheckCalled = true;
  }

  @override
  Future<void> deleteShoppingItem(String id) async {
    deleteItemCalled = true;
  }

  @override
  Future<void> deleteCheckedItems() async {
    deleteCheckedCalled = true;
  }

  @override
  Future<List<ShoppingItem>> getCheckedItems() async => checkedItems;
}

class FakeRecipeSharingService {
  String? lastFormattedRecipe;
  bool shareCalled = false;

  String formatRecipeAsText(Recipe recipe) {
    final text = '${recipe.title}\n${recipe.description}';
    lastFormattedRecipe = text;
    return text;
  }

  Future<void> shareRecipe(Recipe recipe) async {
    shareCalled = true;
  }
}

// --- 테스트 데이터 ---

Map<String, dynamic> createTestProfile({
  String name = '테스트유저',
  String email = 'test@test.com',
  String primaryChefId = 'baek',
  String? aiChefName = '백셰프',
  String skillLevel = 'beginner',
  int householdSize = 1,
  String timePreference = '20min',
  String budgetPreference = 'medium',
}) {
  return {
    'name': name,
    'email': email,
    'primary_chef_id': primaryChefId,
    'ai_chef_name': aiChefName,
    'skill_level': skillLevel,
    'household_size': householdSize,
    'time_preference': timePreference,
    'budget_preference': budgetPreference,
    'scenarios': <String>[],
  };
}

ShoppingItem createTestShoppingItem({
  String id = 'shop-1',
  String name = '양파',
  String category = 'vegetable',
  double quantity = 3,
  String unit = '개',
  bool isChecked = false,
  ShoppingItemSource source = ShoppingItemSource.manual,
  String? recipeTitle,
  String? memo,
}) {
  return ShoppingItem(
    id: id,
    name: name,
    category: category,
    quantity: quantity,
    unit: unit,
    isChecked: isChecked,
    source: source,
    recipeTitle: recipeTitle,
    memo: memo,
  );
}

Ingredient createTestIngredient({
  String name = '양파',
  String category = 'vegetable',
  double quantity = 3,
  String unit = '개',
  DateTime? expiryDate,
}) {
  return Ingredient(
    id: 'test-id',
    name: name,
    category: category,
    quantity: quantity,
    unit: unit,
    expiryDate: expiryDate ?? DateTime.now().add(const Duration(days: 7)),
    storageLocation: StorageLocation.fridge,
    purchaseDate: DateTime.now(),
  );
}

Recipe createTestRecipe({
  String? id,
  String title = '테스트 레시피',
  String description = '맛있는 테스트 레시피입니다',
  String cuisine = '한식',
  RecipeDifficulty difficulty = RecipeDifficulty.easy,
  int cookingTime = 15,
  int servings = 2,
  List<RecipeIngredient>? ingredients,
  List<RecipeInstruction>? instructions,
  NutritionInfo? nutrition,
  String? chefNote,
  bool isBookmarked = false,
}) {
  return Recipe(
    id: id,
    title: title,
    description: description,
    cuisine: cuisine,
    difficulty: difficulty,
    cookingTime: cookingTime,
    servings: servings,
    ingredients: ingredients ?? [],
    tools: [],
    instructions: instructions ?? [],
    nutrition: nutrition,
    chefNote: chefNote,
    isBookmarked: isBookmarked,
  );
}

RecipeIngredient createTestRecipeIngredient({
  String name = '양파',
  String quantity = '1',
  String unit = '개',
  bool isAvailable = true,
  String? substitute,
}) {
  return RecipeIngredient(
    name: name,
    quantity: quantity,
    unit: unit,
    isAvailable: isAvailable,
    substitute: substitute,
  );
}

RecipeInstruction createTestInstruction({
  int step = 1,
  String title = '재료 준비',
  String description = '재료를 씻어 준비합니다.',
  int time = 5,
  String? tips,
}) {
  return RecipeInstruction(
    step: step,
    title: title,
    description: description,
    time: time,
    tips: tips,
  );
}
