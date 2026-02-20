import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../components/empty_state.dart';
import '../../components/recipe_card.dart';
import '../../models/chef.dart';
import '../../models/chef_config.dart';
import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../models/recipe_quick_filter.dart';
import '../../services/auth_service.dart';
import '../../services/gemini_service.dart';
import '../../services/ingredient_service.dart';
import '../../services/recipe_service.dart';
import '../../services/tool_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// 레시피 탭
class RecipeTab extends StatefulWidget {
  final GeminiService? geminiService;
  final IngredientService? ingredientService;
  final RecipeService? recipeService;
  final AuthService? authService;
  final ToolService? toolService;
  final RecipeQuickFilter? quickFilter;

  const RecipeTab({
    super.key,
    this.geminiService,
    this.ingredientService,
    this.recipeService,
    this.authService,
    this.toolService,
    this.quickFilter,
  });

  @override
  State<RecipeTab> createState() => _RecipeTabState();
}

class _RecipeTabState extends State<RecipeTab> {
  late final IngredientService _ingredientService;
  late final AuthService _authService;
  late final RecipeService _recipeService;
  late final ToolService _toolService;

  List<Ingredient> _ingredients = [];
  List<Recipe> _recipes = [];
  List<Recipe> _bookmarkedRecipes = [];
  List<Map<String, dynamic>> _historyList = [];
  bool _isLoadingIngredients = true;
  bool _isGenerating = false;
  bool _isLoadingSaved = false;
  bool _isLoadingHistory = false;
  String? _error;

  int _servings = 1;
  int? _maxCookingTime;
  RecipeDifficulty? _difficulty;
  bool _useExpiringFirst = false;
  String? _activeFilterLabel;

  @override
  void initState() {
    super.initState();
    _ingredientService = widget.ingredientService ?? IngredientService();
    _authService = widget.authService ?? AuthService();
    _recipeService = widget.recipeService ?? RecipeService();
    _toolService = widget.toolService ?? ToolService();
    _applyQuickFilter(widget.quickFilter);
    _loadIngredients();
    _loadBookmarkedRecipes();
    _loadHistory();
  }

  void _applyQuickFilter(RecipeQuickFilter? filter) {
    if (filter == null) return;
    _servings = filter.servings ?? _servings;
    _maxCookingTime = filter.maxCookingTime;
    _difficulty = filter.difficulty;
    _useExpiringFirst = filter.useExpiringFirst;
    _activeFilterLabel = filter.label;
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

      var sortedIngredients = List<Ingredient>.from(_ingredients);
      if (_useExpiringFirst) {
        sortedIngredients.sort(
          (a, b) => a.expiryDate.compareTo(b.expiryDate),
        );
      }
      final ingredientNames = sortedIngredients.map((i) => i.name).toList();
      final geminiService = widget.geminiService ?? GeminiService();
      final tools = await _toolService.getAvailableToolNames();

      final recipe = await geminiService.generateRecipe(
        ingredients: ingredientNames,
        tools: tools,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('레시피'),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: '추천'),
                Tab(text: '저장됨'),
                Tab(text: '기록'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildRecommendedTab(),
                  _buildSavedTab(),
                  _buildHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedTab() {
    if (_isLoadingIngredients) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_activeFilterLabel != null) ...[
            _buildActiveFilterBanner(),
            const SizedBox(height: AppSpacing.md),
          ],
          _buildIngredientStatus(),
          const SizedBox(height: AppSpacing.lg),

          if (_ingredients.isNotEmpty) ...[
            _buildConditionSelector(),
            const SizedBox(height: AppSpacing.lg),
            _buildGenerateButton(),
            const SizedBox(height: AppSpacing.lg),
          ],

          if (_error != null) ...[
            _buildErrorMessage(),
            const SizedBox(height: AppSpacing.lg),
          ],

          if (_isGenerating) ...[
            _buildLoadingIndicator(),
            const SizedBox(height: AppSpacing.lg),
          ],

          if (_recipes.isNotEmpty) ...[
            Text(
              '추천 레시피',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._recipes.map(
              (recipe) => RecipeCard(
                recipe: recipe,
                onTap: () async {
                  await context.push('/recipe/detail', extra: recipe);
                  _loadBookmarkedRecipes();
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIngredientStatus() {
    if (_ingredients.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.surfaceDim,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Text('🍽️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text(
              '냉장고에 재료를 등록하면\n맞춤 레시피를 추천해드려요',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
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
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '보유 재료 ${_ingredients.length}개로 레시피를 추천받을 수 있어요',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추천 조건',
          style: AppTypography.labelLarge.copyWith(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        _buildConditionRow('인원수', List.generate(4, (i) {
          final count = i + 1;
          return _ConditionOption('$count인', _servings == count, () {
            setState(() => _servings = count);
          });
        })),
        const SizedBox(height: AppSpacing.sm),

        _buildConditionRow('조리시간', [null, 15, 30, 60].map((time) {
          return _ConditionOption(
            time == null ? '무관' : '$time분',
            _maxCookingTime == time,
            () => setState(() => _maxCookingTime = time),
          );
        }).toList()),
        const SizedBox(height: AppSpacing.sm),

        _buildConditionRow('난이도', [
          (null, '무관'),
          (RecipeDifficulty.easy, '쉬움'),
          (RecipeDifficulty.medium, '보통'),
          (RecipeDifficulty.hard, '어려움'),
        ].map((entry) {
          final (diff, label) = entry;
          return _ConditionOption(
            label,
            _difficulty == diff,
            () => setState(() => _difficulty = diff),
          );
        }).toList()),
      ],
    );
  }

  Widget _buildConditionRow(String label, List<_ConditionOption> options) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...options.map((opt) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(opt.label),
              selected: opt.isSelected,
              onSelected: (_) => opt.onTap(),
              labelStyle: TextStyle(
                fontSize: 13,
                color: opt.isSelected ? AppColors.primary : null,
                fontWeight:
                    opt.isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton.icon(
        onPressed: _isGenerating ? null : _generateRecipe,
        icon: const Icon(Icons.auto_awesome, size: 20),
        label: const Text('레시피 추천받기'),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'AI 셰프가 레시피를 만들고 있어요...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '보유 재료를 분석하고 최적의 레시피를 찾는 중',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '"$_activeFilterLabel" 모드로 조건이 설정되었습니다',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _activeFilterLabel = null;
                _servings = 1;
                _maxCookingTime = null;
                _difficulty = null;
                _useExpiringFirst = false;
              });
            },
            child: const Icon(Icons.close, size: 18, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _error!,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
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

  Widget _buildSavedTab() {
    if (_isLoadingSaved) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bookmarkedRecipes.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadBookmarkedRecipes,
        child: ListView(
          children: const [
            SizedBox(height: 80),
            EmptyState(
              emoji: '🔖',
              title: '저장한 레시피가 없어요',
              subtitle: '레시피를 북마크하면 여기에 표시됩니다',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookmarkedRecipes,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _bookmarkedRecipes.length,
        itemBuilder: (context, index) {
          return RecipeCard(
            recipe: _bookmarkedRecipes[index],
            onTap: () async {
              await context.push(
                '/recipe/detail',
                extra: _bookmarkedRecipes[index],
              );
              _loadBookmarkedRecipes();
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_historyList.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView(
          children: const [
            SizedBox(height: 80),
            EmptyState(
              emoji: '📝',
              title: '요리 기록이 없어요',
              subtitle: '레시피를 요리하면 기록이 남습니다',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _historyList.length,
        itemBuilder: (context, index) {
          final item = _historyList[index];
          final createdAt = item['cooked_at'] != null
              ? DateTime.parse(item['cooked_at'])
              : DateTime.now();

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Card(
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  item['recipe_title'] ?? '',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ConditionOption {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConditionOption(this.label, this.isSelected, this.onTap);
}
