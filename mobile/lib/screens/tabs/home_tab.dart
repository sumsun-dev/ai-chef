import 'package:flutter/material.dart';
import '../../models/chef.dart';
import '../../models/ingredient.dart';
import '../../services/auth_service.dart';
import '../../services/ingredient_service.dart';

/// 홈 탭
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final AuthService _authService = AuthService();
  final IngredientService _ingredientService = IngredientService();
  final TextEditingController _chatController = TextEditingController();

  List<Ingredient> _expiringIngredients = [];
  bool _isLoading = true;
  Chef _currentChef = Chefs.defaultChef;

  @override
  void initState() {
    super.initState();
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
            onPressed: () {
              // TODO: 알림 화면
            },
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
            _buildRecommendationSection(),
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
              // TODO: 메시지 전송
              _chatController.clear();
            },
          ),
        ),
        onSubmitted: (value) {
          // TODO: 메시지 전송
          _chatController.clear();
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
            onTap: () {
              // TODO: 혼밥 레시피 추천
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: '⚡',
            label: '급해요',
            onTap: () {
              // TODO: 빠른 레시피 추천
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: '🥬',
            label: '재료정리',
            onTap: () {
              // TODO: 유통기한 임박 재료로 레시피
            },
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
              onPressed: () {
                // TODO: 냉장고 탭으로 이동
              },
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

  Widget _buildRecommendationSection() {
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
                '냉장고 재료를 등록하면\n맞춤 레시피를 추천해드려요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
