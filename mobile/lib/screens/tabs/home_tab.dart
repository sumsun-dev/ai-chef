import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/chef.dart';
import '../../models/chef_config.dart';
import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../services/auth_service.dart';
import '../../services/gemini_service.dart';
import '../../services/ingredient_service.dart';

/// 홈 탭
class HomeTab extends StatefulWidget {
  final AuthService? authService;
  final IngredientService? ingredientService;
  final GeminiService? geminiService;

  const HomeTab({
    super.key,
    this.authService,
    this.ingredientService,
    this.geminiService,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final AuthService _authService;
  late final IngredientService _ingredientService;
  final TextEditingController _chatController = TextEditingController();

  List<Ingredient> _expiringIngredients = [];
  bool _isLoading = true;
  Chef _currentChef = Chefs.defaultChef;

  // 오늘의 추천 상태
  Recipe? _recommendedRecipe;
  bool _isLoadingRecommendation = false;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _ingredientService = widget.ingredientService ?? IngredientService();
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

      final chefId = profile?['primary_chef_id'] ?? 'baek';
      final chef = Chefs.findById(chefId) ?? Chefs.defaultChef;

      final expiringItems = [
        ...expiryGroup.expiredItems,
        ...expiryGroup.criticalItems,
      ].take(5).toList();

      setState(() {
        _currentChef = chef;
        _expiringIngredients = expiringItems;
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
      final recipe = await geminiService.generateRecipe(
        ingredients: ingredients.map((i) => i.name).toList(),
        tools: ['프라이팬', '냄비', '전자레인지', '오븐'],
        chefConfig: chefConfig,
        servings: 1,
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
    final colorScheme = Theme.of(context).colorScheme;

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 셰프 인사 카드
            _buildChefGreetingCard(colorScheme),
            const SizedBox(height: 16),

            // 채팅 입력
            _buildChatInput(colorScheme),
            const SizedBox(height: 16),

            // 빠른 선택
            _buildQuickActions(),
            const SizedBox(height: 24),

            // 유통기한 임박
            if (_expiringIngredients.isNotEmpty) ...[
              _buildExpirySection(),
              const SizedBox(height: 24),
            ],

            // 오늘의 추천
            _buildRecommendationSection(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildChefGreetingCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(_currentChef.primaryColor).withValues(alpha: 0.1),
            Color(_currentChef.primaryColor).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(_currentChef.primaryColor).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _currentChef.emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentChef.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentChef.randomGreeting,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _chatController,
        decoration: InputDecoration(
          hintText: '메시지를 입력하세요...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          suffixIcon: IconButton(
            icon: Icon(Icons.send, color: colorScheme.primary),
            onPressed: () {
              final text = _chatController.text.trim();
              _chatController.clear();
              context.push('/chat', extra: text.isNotEmpty ? text : null);
            },
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
          child: _buildQuickActionCard(
            icon: '🍚',
            label: '혼밥',
            onTap: () => context.go('/recipe'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: '⚡',
            label: '급해요',
            onTap: () => context.go('/recipe'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: '🥬',
            label: '재료정리',
            onTap: () => context.go('/recipe'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpirySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Text('⚠️', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text(
                  '유통기한 임박',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => context.go('/refrigerator'),
              child: const Text('전체보기'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
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
    final color = _getExpiryColor(ingredient.expiryStatus);

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            ingredient.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${ingredient.quantity} ${ingredient.unit}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              ingredient.dDayString,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getExpiryColor(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.expired:
        return Colors.red;
      case ExpiryStatus.critical:
        return Colors.orange;
      case ExpiryStatus.warning:
        return Colors.blue;
      case ExpiryStatus.safe:
        return Colors.green;
    }
  }

  Widget _buildRecommendationSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('🍳', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text(
              '오늘의 추천',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingRecommendation)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'AI 셰프가 추천 중...',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          )
        else if (_recommendedRecipe != null)
          _buildRecommendedRecipeCard(_recommendedRecipe!, colorScheme)
        else
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.restaurant,
                  size: 48,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Text(
                  '냉장고 재료 기반 맞춤 레시피를\n추천받아 보세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 12),
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

  Widget _buildRecommendedRecipeCard(Recipe recipe, ColorScheme colorScheme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/recipe/detail', extra: recipe),
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
                  Icon(Icons.timer_outlined,
                      size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 3),
                  Text(
                    '${recipe.cookingTime}분',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: _loadRecommendation,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('다시 추천'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
