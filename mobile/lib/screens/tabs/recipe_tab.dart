import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/chef.dart';
import '../../models/chef_config.dart';
import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../services/auth_service.dart';
import '../../services/gemini_service.dart';
import '../../services/ingredient_service.dart';
import '../../services/recipe_service.dart';

/// 레시피 탭
class RecipeTab extends StatefulWidget {
  const RecipeTab({super.key});

  @override
  State<RecipeTab> createState() => _RecipeTabState();
}

class _RecipeTabState extends State<RecipeTab> {
  final IngredientService _ingredientService = IngredientService();
  final AuthService _authService = AuthService();
  final RecipeService _recipeService = RecipeService();

  List<Ingredient> _ingredients = [];
  List<Recipe> _recipes = [];
  List<Recipe> _bookmarkedRecipes = [];
  List<Map<String, dynamic>> _historyList = [];
  bool _isLoadingIngredients = true;
  bool _isGenerating = false;
  bool _isLoadingSaved = false;
  bool _isLoadingHistory = false;
  String? _error;

  // 추천 조건
  int _servings = 1;
  int? _maxCookingTime;
  RecipeDifficulty? _difficulty;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
    _loadBookmarkedRecipes();
    _loadHistory();
  }

  Future<void> _loadIngredients() async {
    try {
      final ingredients = await _ingredientService.getUserIngredients();
      setState(() {
        _ingredients = ingredients;
        _isLoadingIngredients = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingIngredients = false;
        _error = '재료를 불러오지 못했습니다.';
      });
    }
  }

  Future<void> _loadBookmarkedRecipes() async {
    setState(() => _isLoadingSaved = true);
    try {
      final recipes = await _recipeService.getBookmarkedRecipes();
      if (mounted) {
        setState(() {
          _bookmarkedRecipes = recipes;
          _isLoadingSaved = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingSaved = false);
    }
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final history = await _recipeService.getRecipeHistory();
      if (mounted) {
        setState(() {
          _historyList = history;
          _isLoadingHistory = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _generateRecipe() async {
    if (_ingredients.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      final profile = await _authService.getUserProfile();
      final chefId = profile?['primary_chef_id'] ?? 'baek';
      final chef = Chefs.findById(chefId) ?? Chefs.defaultChef;

      final chefConfig = AIChefConfig(
        name: chef.name,
        expertise: chef.specialties,
        cookingPhilosophy: chef.philosophy,
      );

      final ingredientNames = _ingredients.map((i) => i.name).toList();
      final geminiService = GeminiService();

      final recipe = await geminiService.generateRecipe(
        ingredients: ingredientNames,
        tools: ['프라이팬', '냄비', '전자레인지', '오븐'],
        chefConfig: chefConfig,
        difficulty: _difficulty,
        cookingTime: _maxCookingTime,
        servings: _servings,
      );

      setState(() {
        _recipes = [recipe, ..._recipes];
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _error = '레시피 생성에 실패했습니다. 다시 시도해주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('레시피'),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              tabs: const [
                Tab(text: '추천'),
                Tab(text: '저장됨'),
                Tab(text: '기록'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildRecommendedTab(colorScheme),
                  _buildSavedTab(colorScheme),
                  _buildHistoryTab(colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedTab(ColorScheme colorScheme) {
    if (_isLoadingIngredients) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIngredientStatus(colorScheme),
          const SizedBox(height: 16),

          if (_ingredients.isNotEmpty) ...[
            _buildConditionSelector(colorScheme),
            const SizedBox(height: 16),
            _buildGenerateButton(colorScheme),
            const SizedBox(height: 16),
          ],

          if (_error != null) ...[
            _buildErrorMessage(),
            const SizedBox(height: 16),
          ],

          if (_isGenerating) ...[
            _buildLoadingIndicator(colorScheme),
            const SizedBox(height: 16),
          ],

          if (_recipes.isNotEmpty) ...[
            const Text(
              '추천 레시피',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._recipes.map(
              (recipe) => _buildRecipeCard(recipe, colorScheme),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIngredientStatus(ColorScheme colorScheme) {
    if (_ingredients.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(Icons.kitchen_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              '냉장고에 재료를 등록하면\n맞춤 레시피를 추천해드려요',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.go('/refrigerator'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('재료 등록하기'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '보유 재료 ${_ingredients.length}개로 레시피를 추천받을 수 있어요',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '추천 조건',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(
                '인원수',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
            ...List.generate(4, (i) {
              final count = i + 1;
              final isSelected = _servings == count;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('$count인'),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _servings = count),
                  selectedColor: colorScheme.primary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    fontSize: 13,
                    color: isSelected ? colorScheme.primary : null,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(
                '조리시간',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
            ...[null, 15, 30, 60].map((time) {
              final isSelected = _maxCookingTime == time;
              final label = time == null ? '무관' : '$time분';
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _maxCookingTime = time),
                  selectedColor: colorScheme.primary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    fontSize: 13,
                    color: isSelected ? colorScheme.primary : null,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(
                '난이도',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
            ...[
              (null, '무관'),
              (RecipeDifficulty.easy, '쉬움'),
              (RecipeDifficulty.medium, '보통'),
              (RecipeDifficulty.hard, '어려움'),
            ].map((entry) {
              final (diff, label) = entry;
              final isSelected = _difficulty == diff;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _difficulty = diff),
                  selectedColor: colorScheme.primary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    fontSize: 13,
                    color: isSelected ? colorScheme.primary : null,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildGenerateButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton.icon(
        onPressed: _isGenerating ? null : _generateRecipe,
        icon: const Icon(Icons.auto_awesome, size: 20),
        label: const Text(
          '레시피 추천받기',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AI 셰프가 레시피를 만들고 있어요...',
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '보유 재료를 분석하고 최적의 레시피를 찾는 중',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(fontSize: 14, color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _error = null),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          await context.push('/recipe/detail', extra: recipe);
          _loadBookmarkedRecipes();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                recipe.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildCardBadge(
                    Icons.timer_outlined,
                    '${recipe.cookingTime}분',
                  ),
                  const SizedBox(width: 8),
                  _buildCardBadge(
                    Icons.signal_cellular_alt,
                    _difficultyLabel(recipe.difficulty),
                  ),
                  const SizedBox(width: 8),
                  _buildCardBadge(
                    Icons.people_outline,
                    '${recipe.servings}인분',
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardBadge(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _difficultyLabel(RecipeDifficulty difficulty) {
    switch (difficulty) {
      case RecipeDifficulty.easy:
        return '쉬움';
      case RecipeDifficulty.medium:
        return '보통';
      case RecipeDifficulty.hard:
        return '어려움';
    }
  }

  Widget _buildSavedTab(ColorScheme colorScheme) {
    if (_isLoadingSaved) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bookmarkedRecipes.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadBookmarkedRecipes,
        child: ListView(
          children: [
            const SizedBox(height: 120),
            Center(
              child: Column(
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '저장한 레시피가 없어요',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '레시피를 북마크하면 여기에 표시됩니다',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookmarkedRecipes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookmarkedRecipes.length,
        itemBuilder: (context, index) {
          return _buildRecipeCard(_bookmarkedRecipes[index], colorScheme);
        },
      ),
    );
  }

  Widget _buildHistoryTab(ColorScheme colorScheme) {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_historyList.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView(
          children: [
            const SizedBox(height: 120),
            Center(
              child: Column(
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '요리 기록이 없어요',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '레시피를 요리하면 기록이 남습니다',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _historyList.length,
        itemBuilder: (context, index) {
          final item = _historyList[index];
          final createdAt = item['cooked_at'] != null
              ? DateTime.parse(item['cooked_at'])
              : DateTime.now();

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: Text(item['recipe_title'] ?? ''),
              subtitle: Text(
                '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}',
              ),
            ),
          );
        },
      ),
    );
  }
}
