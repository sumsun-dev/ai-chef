import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/recipe.dart';
import '../models/shopping_item.dart';
import '../services/recipe_service.dart';
import '../services/shopping_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 레시피 상세 화면
class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final ShoppingService? shoppingService;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    this.shoppingService,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeService _recipeService = RecipeService();
  late final ShoppingService _shoppingService;
  late Recipe _recipe;
  bool _isSaved = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _shoppingService = widget.shoppingService ?? ShoppingService();
    _recipe = widget.recipe;
    _isSaved = _recipe.id != null;
  }

  Future<void> _saveRecipe() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final saved = await _recipeService.saveRecipe(_recipe);
      if (mounted) {
        setState(() {
          _recipe = saved;
          _isSaved = true;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('레시피가 저장되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했습니다.')),
        );
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (!_isSaved || _recipe.id == null) {
      await _saveRecipe();
      return;
    }

    final newBookmark = !_recipe.isBookmarked;
    try {
      await _recipeService.toggleBookmark(_recipe.id!, newBookmark);
      if (mounted) {
        setState(() {
          _recipe = _recipe.copyWith(isBookmarked: newBookmark);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newBookmark ? '북마크에 추가했습니다.' : '북마크를 해제했습니다.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('처리에 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_recipe.title),
        actions: [
          if (!_isSaved)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              onPressed: _isSaving ? null : _saveRecipe,
              tooltip: '레시피 저장',
            ),
          IconButton(
            icon: Icon(
              _recipe.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _recipe.isBookmarked ? AppColors.primary : null,
            ),
            onPressed: _toggleBookmark,
            tooltip: '북마크',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildBadges(),
            const Divider(height: 32),
            _buildIngredientsSection(),
            const Divider(height: 32),
            _buildInstructionsSection(),
            if (_recipe.nutrition != null) ...[
              const Divider(height: 32),
              _buildNutritionSection(),
            ],
            if (_recipe.chefNote != null && _recipe.chefNote!.isNotEmpty) ...[
              const Divider(height: 32),
              _buildChefNote(),
            ],
            // FAB 공간 확보
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: _recipe.instructions.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => context.push(
                '/recipe/cooking',
                extra: _recipe,
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('요리 시작'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _recipe.title,
            style: AppTypography.headlineLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _recipe.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _buildBadge(
            icon: Icons.signal_cellular_alt,
            label: _difficultyLabel(_recipe.difficulty),
            color: _difficultyColor(_recipe.difficulty),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildBadge(
            icon: Icons.timer_outlined,
            label: '${_recipe.cookingTime}분',
            color: AppColors.info,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildBadge(
            icon: Icons.people_outline,
            label: '${_recipe.servings}인분',
            color: AppColors.teal,
          ),
          if (_recipe.cuisine.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            _buildBadge(
              icon: Icons.restaurant,
              label: _recipe.cuisine,
              color: AppColors.purple,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_basket_outlined, size: 20,
                  color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '재료',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ..._recipe.ingredients.map(
            (ingredient) => _buildIngredientRow(ingredient),
          ),
          if (_missingIngredients.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _buildAddToShoppingButton(),
          ],
        ],
      ),
    );
  }

  List<RecipeIngredient> get _missingIngredients {
    return _recipe.ingredients.where((i) => !i.isAvailable).toList();
  }

  Widget _buildAddToShoppingButton() {
    final count = _missingIngredients.length;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _addMissingToShopping,
        icon: const Icon(Icons.shopping_cart_outlined, size: 18),
        label: Text('부족한 재료 $count개 쇼핑리스트 담기'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Future<void> _addMissingToShopping() async {
    final items = _missingIngredients.map((ingredient) {
      return ShoppingItem(
        name: ingredient.name,
        quantity: double.tryParse(ingredient.quantity) ?? 1,
        unit: ingredient.unit,
        source: ShoppingItemSource.recipe,
        recipeTitle: _recipe.title,
      );
    }).toList();

    try {
      await _shoppingService.addShoppingItems(items);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${items.length}개 재료가 쇼핑리스트에 추가되었습니다.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('쇼핑리스트 추가에 실패했습니다.')),
        );
      }
    }
  }

  Widget _buildIngredientRow(RecipeIngredient ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            ingredient.isAvailable
                ? Icons.check_circle
                : Icons.circle_outlined,
            size: 18,
            color: ingredient.isAvailable
                ? AppColors.success
                : AppColors.textTertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ingredient.name,
              style: AppTypography.bodyLarge.copyWith(
                color: ingredient.isAvailable
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '${ingredient.quantity} ${ingredient.unit}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          if (ingredient.substitute != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Tooltip(
              message: '대체: ${ingredient.substitute}',
              child: const Icon(
                Icons.swap_horiz,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_list_numbered, size: 20,
                  color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '조리 순서',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ..._recipe.instructions.map(
            (step) => _buildInstructionCard(step),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard(RecipeInstruction step) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${step.step}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.title,
                  style: AppTypography.labelLarge.copyWith(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (step.time > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    '${step.time}분',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            step.description,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (step.tips != null && step.tips!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      step.tips!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutritionSection() {
    final nutrition = _recipe.nutrition!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, size: 20,
                  color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '영양 정보',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildNutritionItem(
                '칼로리', '${nutrition.calories}', 'kcal', AppColors.error,
              ),
              _buildNutritionItem(
                '단백질', '${nutrition.protein}', 'g', AppColors.info,
              ),
              _buildNutritionItem(
                '탄수화물', '${nutrition.carbs}', 'g', AppColors.warning,
              ),
              _buildNutritionItem(
                '지방', '${nutrition.fat}', 'g', AppColors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              unit,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChefNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.primary.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('👨‍🍳', style: TextStyle(fontSize: 18)),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '셰프 노트',
                  style: AppTypography.labelLarge.copyWith(
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _recipe.chefNote!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
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

  Color _difficultyColor(RecipeDifficulty difficulty) {
    switch (difficulty) {
      case RecipeDifficulty.easy:
        return AppColors.success;
      case RecipeDifficulty.medium:
        return AppColors.warning;
      case RecipeDifficulty.hard:
        return AppColors.error;
    }
  }
}
