import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/recipe_service.dart';

/// 레시피 상세 화면
class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeService _recipeService = RecipeService();
  late Recipe _recipe;
  bool _isSaved = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
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
    final colorScheme = Theme.of(context).colorScheme;

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
              color: _recipe.isBookmarked ? colorScheme.primary : null,
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
            _buildHeader(colorScheme),
            _buildBadges(colorScheme),
            const Divider(height: 32),
            _buildIngredientsSection(colorScheme),
            const Divider(height: 32),
            _buildInstructionsSection(colorScheme),
            if (_recipe.nutrition != null) ...[
              const Divider(height: 32),
              _buildNutritionSection(colorScheme),
            ],
            if (_recipe.chefNote != null && _recipe.chefNote!.isNotEmpty) ...[
              const Divider(height: 32),
              _buildChefNote(colorScheme),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _recipe.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _recipe.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildBadge(
            icon: Icons.signal_cellular_alt,
            label: _difficultyLabel(_recipe.difficulty),
            color: _difficultyColor(_recipe.difficulty),
          ),
          const SizedBox(width: 8),
          _buildBadge(
            icon: Icons.timer_outlined,
            label: '${_recipe.cookingTime}분',
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          _buildBadge(
            icon: Icons.people_outline,
            label: '${_recipe.servings}인분',
            color: Colors.teal,
          ),
          if (_recipe.cuisine.isNotEmpty) ...[
            const SizedBox(width: 8),
            _buildBadge(
              icon: Icons.restaurant,
              label: _recipe.cuisine,
              color: Colors.purple,
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
        borderRadius: BorderRadius.circular(20),
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

  Widget _buildIngredientsSection(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shopping_basket_outlined, size: 20),
              SizedBox(width: 8),
              Text(
                '재료',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._recipe.ingredients.map(
            (ingredient) => _buildIngredientRow(ingredient, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientRow(
    RecipeIngredient ingredient,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            ingredient.isAvailable
                ? Icons.check_circle
                : Icons.circle_outlined,
            size: 18,
            color: ingredient.isAvailable ? Colors.green : Colors.grey[400],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ingredient.name,
              style: TextStyle(
                fontSize: 15,
                color: ingredient.isAvailable ? null : Colors.grey[600],
              ),
            ),
          ),
          Text(
            '${ingredient.quantity} ${ingredient.unit}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          if (ingredient.substitute != null) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: '대체: ${ingredient.substitute}',
              child: Icon(
                Icons.swap_horiz,
                size: 16,
                color: colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructionsSection(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.format_list_numbered, size: 20),
              SizedBox(width: 8),
              Text(
                '조리 순서',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._recipe.instructions.map(
            (step) => _buildInstructionCard(step, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard(
    RecipeInstruction step,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
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
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${step.time}분',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            step.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          if (step.tips != null && step.tips!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      step.tips!,
                      style: const TextStyle(fontSize: 13),
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

  Widget _buildNutritionSection(ColorScheme colorScheme) {
    final nutrition = _recipe.nutrition!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, size: 20),
              SizedBox(width: 8),
              Text(
                '영양 정보',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildNutritionItem('칼로리', '${nutrition.calories}', 'kcal', Colors.red),
              _buildNutritionItem('단백질', '${nutrition.protein}', 'g', Colors.blue),
              _buildNutritionItem('탄수화물', '${nutrition.carbs}', 'g', Colors.orange),
              _buildNutritionItem('지방', '${nutrition.fat}', 'g', Colors.purple),
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
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
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChefNote(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.primary.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('👨‍🍳', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  '셰프 노트',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _recipe.chefNote!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
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
        return Colors.green;
      case RecipeDifficulty.medium:
        return Colors.orange;
      case RecipeDifficulty.hard:
        return Colors.red;
    }
  }
}
