import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/chef_greeting_card.dart';
import '../../components/expiry_badge.dart';
import '../../components/fridge_summary_card.dart';
import '../../components/quick_action_card.dart';
import '../../components/recipe_card.dart';
import '../../components/section_header.dart';
import '../../models/chef.dart';
import '../../models/chef_config.dart';
import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../models/recipe_quick_filter.dart';
import '../../services/auth_service.dart';
import '../../services/gemini_service.dart';
import '../../services/ingredient_service.dart';
import '../../services/smart_recommendation_service.dart';
import '../../services/tool_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// 홈 탭
class HomeTab extends StatefulWidget {
  final AuthService? authService;
  final IngredientService? ingredientService;
  final GeminiService? geminiService;
  final ToolService? toolService;

  const HomeTab({
    super.key,
    this.authService,
    this.ingredientService,
    this.geminiService,
    this.toolService,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final AuthService _authService;
  late final IngredientService _ingredientService;
  late final ToolService _toolService;
  final TextEditingController _chatController = TextEditingController();

  List<Ingredient> _expiringIngredients = [];
  List<Ingredient> _allIngredients = [];
  bool _isLoading = true;
  Chef _currentChef = Chefs.defaultChef;

  Recipe? _recommendedRecipe;
  bool _isLoadingRecommendation = false;
  String? _smartRecommendation;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _ingredientService = widget.ingredientService ?? IngredientService();
    _toolService = widget.toolService ?? ToolService();
    _loadData();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final profile = await _authService.getUserProfile();
      final expiryGroup = await _ingredientService.getExpiryIngredientGroup();
      final allIngredients = await _ingredientService.getUserIngredients();

      final chefId = profile?['primary_chef_id'] ?? 'baek';
      final chef = Chefs.findById(chefId) ?? Chefs.defaultChef;

      final expiringItems = [
        ...expiryGroup.expiredItems,
        ...expiryGroup.criticalItems,
      ].take(5).toList();

      // 스마트 추천 메시지 생성 (서비스 생성 없이 정적 호출)
      final smartMessage = SmartRecommendationService.buildRecommendationMessage(
        expiringIngredients: expiringItems,
      );

      setState(() {
        _currentChef = chef;
        _expiringIngredients = expiringItems;
        _allIngredients = allIngredients;
        _smartRecommendation = smartMessage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRecommendation() async {
    setState(() => _isLoadingRecommendation = true);

    try {
      final ingredients = await _ingredientService.getUserIngredients();
      if (ingredients.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('냉장고에 재료를 먼저 등록해주세요.')),
          );
          setState(() => _isLoadingRecommendation = false);
        }
        return;
      }

      final profile = await _authService.getUserProfile();
      final chefId = profile?['primary_chef_id'] ?? 'baek';
      final chef = Chefs.findById(chefId) ?? Chefs.defaultChef;

      final chefConfig = AIChefConfig(
        name: chef.name,
        expertise: chef.specialties,
        cookingPhilosophy: chef.philosophy,
      );

      final geminiService = widget.geminiService ?? GeminiService();
      final tools = await _toolService.getAvailableToolNames();
      final servings = (profile?['household_size'] as int?) ?? 1;
      final recipe = await geminiService.generateRecipe(
        ingredients: ingredients.map((i) => i.name).toList(),
        tools: tools,
        chefConfig: chefConfig,
        servings: servings,
      );

      if (mounted) {
        setState(() {
          _recommendedRecipe = recipe;
          _isLoadingRecommendation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRecommendation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('추천 생성에 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 셰프'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 셰프 인사 카드
            ChefGreetingCard(chef: _currentChef),
            const SizedBox(height: AppSpacing.lg),

            // 채팅 입력
            _buildChatInput(),
            const SizedBox(height: AppSpacing.lg),

            // 빠른 선택
            _buildQuickActions(),
            const SizedBox(height: AppSpacing.xxl),

            // 냉장고 요약
            if (_allIngredients.isNotEmpty) ...[
              FridgeSummaryCard(
                ingredients: _allIngredients,
                expiringCount: _expiringIngredients.length,
                onTap: () => context.go('/refrigerator'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 유통기한 임박
            if (_expiringIngredients.isNotEmpty) ...[
              _buildExpirySection(),
              const SizedBox(height: AppSpacing.xxl),
            ],

            // 스마트 추천 카드
            if (_smartRecommendation != null) ...[
              _buildSmartRecommendationCard(),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 오늘의 추천
            _buildRecommendationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: TextField(
        controller: _chatController,
        decoration: InputDecoration(
          hintText: '${_currentChef.name}에게 물어보세요...',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppSpacing.lg),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, color: AppColors.textTertiary),
                onPressed: () => context.push('/camera'),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.primary),
                onPressed: () {
                  final text = _chatController.text.trim();
                  _chatController.clear();
                  context.push('/chat', extra: text.isNotEmpty ? text : null);
                },
              ),
            ],
          ),
        ),
        onSubmitted: (value) {
          final text = value.trim();
          _chatController.clear();
          context.push('/chat', extra: text.isNotEmpty ? text : null);
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: QuickActionCard(
            icon: '🍚',
            label: '혼밥',
            onTap: () => context.go('/recipe', extra: RecipeQuickFilter.solo),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: QuickActionCard(
            icon: '⚡',
            label: '급해요',
            onTap: () => context.go('/recipe', extra: RecipeQuickFilter.quick),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: QuickActionCard(
            icon: '🥬',
            label: '재료정리',
            onTap: () => context.go('/recipe', extra: RecipeQuickFilter.clearFridge),
          ),
        ),
      ],
    );
  }

  Widget _buildExpirySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          emoji: '⚠️',
          title: '유통기한 임박',
          actionText: '전체보기',
          onAction: () => context.go('/refrigerator'),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 92,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _expiringIngredients.length,
            itemBuilder: (context, index) {
              return _buildExpiryIngredientCard(_expiringIngredients[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryIngredientCard(Ingredient ingredient) {
    final color = getExpiryColor(ingredient.expiryStatus);

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            ingredient.name,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${ingredient.quantity} ${ingredient.unit}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          ExpiryBadge(
            status: ingredient.expiryStatus,
            dDayString: ingredient.dDayString,
          ),
        ],
      ),
    );
  }

  Widget _buildSmartRecommendationCard() {
    return InkWell(
      onTap: () => context.push('/chat', extra: _smartRecommendation),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.primary.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI 추천',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _smartRecommendation!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(emoji: '🍳', title: '오늘의 추천'),
        const SizedBox(height: AppSpacing.md),
        if (_isLoadingRecommendation)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'AI 셰프가 추천 중...',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          )
        else if (_recommendedRecipe != null)
          RecipeCard(
            recipe: _recommendedRecipe!,
            onTap: () =>
                context.push('/recipe/detail', extra: _recommendedRecipe),
            trailing: TextButton.icon(
              onPressed: _loadRecommendation,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('다시 추천'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          )
        else
          Center(
            child: Column(
              children: [
                Text(
                  '🍽️',
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '냉장고 재료 기반 맞춤 레시피를\n추천받아 보세요',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: _loadRecommendation,
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('추천 받기'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
