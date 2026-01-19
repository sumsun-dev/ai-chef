import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/ingredient.dart';
import '../services/auth_service.dart';
import '../services/ingredient_service.dart';
import '../services/notification_service.dart';

/// 홈 화면
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final IngredientService _ingredientService = IngredientService();
  final NotificationService _notificationService = NotificationService();
  Map<String, dynamic>? _profile;
  ExpiryIngredientGroup? _expiryGroup;
  List<Ingredient> _priorityIngredients = [];
  bool _isLoading = true;
  bool _isLoadingExpiry = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    // 매일 아침 알림 스케줄
    await _notificationService.scheduleDailyExpiryCheck();
    // 앱 시작 시 유통기한 알림 체크
    await _notificationService.checkAndShowExpiryNotifications();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadProfile(),
      _loadExpiryData(),
    ]);
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _authService.getUserProfile();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadExpiryData() async {
    try {
      final expiryGroup = await _ingredientService.getExpiryIngredientGroup();

      // 우선 사용 재료: 만료됨 + 3일 이내 (최대 5개)
      final priorityItems = [
        ...expiryGroup.expiredItems,
        ...expiryGroup.criticalItems,
      ].take(5).toList();

      setState(() {
        _expiryGroup = expiryGroup;
        _priorityIngredients = priorityItems;
        _isLoadingExpiry = false;
      });
    } catch (e) {
      setState(() => _isLoadingExpiry = false);
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      context.go('/login');
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

    final chefName = _profile?['ai_chef_name'] ?? 'AI 셰프';
    final userName = _profile?['name'] ?? '사용자';

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chef'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 환영 메시지
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '안녕하세요, $userName님!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$chefName가 오늘도 함께합니다',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 우선 사용 재료 (긴급한 재료가 있을 때만 표시)
            if (_priorityIngredients.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.priority_high, color: Colors.red, size: 20),
                      SizedBox(width: 4),
                      Text(
                        '우선 사용 재료',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.push('/expiry-alert'),
                    child: const Text('전체보기'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _priorityIngredients.length,
                  itemBuilder: (context, index) {
                    return _buildPriorityIngredientCard(_priorityIngredients[index]);
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 유통기한 알림
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '유통기한 알림',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isLoadingExpiry)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAlertCard(
              icon: Icons.warning_amber,
              color: Colors.red,
              title: '유통기한 지남',
              count: _expiryGroup?.expiredCount ?? 0,
              onTap: () => context.push('/expiry-alert', extra: ExpiryStatus.expired),
            ),
            _buildAlertCard(
              icon: Icons.access_time,
              color: Colors.orange,
              title: '3일 이내 만료',
              count: _expiryGroup?.criticalCount ?? 0,
              onTap: () => context.push('/expiry-alert', extra: ExpiryStatus.critical),
            ),
            _buildAlertCard(
              icon: Icons.info_outline,
              color: Colors.blue,
              title: '7일 이내 만료',
              count: _expiryGroup?.warningCount ?? 0,
              onTap: () => context.push('/expiry-alert', extra: ExpiryStatus.warning),
            ),
            const SizedBox(height: 24),

            // 빠른 메뉴
            const Text(
              '빠른 메뉴',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildMenuCard(
                  icon: Icons.chat,
                  title: 'AI 셰프와 대화',
                  color: colorScheme.primary,
                  onTap: () {
                    // TODO: 채팅 화면으로 이동
                  },
                ),
                _buildMenuCard(
                  icon: Icons.restaurant,
                  title: '레시피 추천',
                  color: colorScheme.secondary,
                  onTap: () {
                    // TODO: 레시피 추천 화면으로 이동
                  },
                ),
                _buildMenuCard(
                  icon: Icons.kitchen,
                  title: '재료 관리',
                  color: colorScheme.tertiary,
                  onTap: () {
                    // TODO: 재료 관리 화면으로 이동
                  },
                ),
                _buildMenuCard(
                  icon: Icons.settings,
                  title: '설정',
                  color: Colors.grey,
                  onTap: () {
                    // TODO: 설정 화면으로 이동
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color color,
    required String title,
    required int count,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: count > 0 ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, color: count > 0 ? color : Colors.grey),
          title: Text(
            title,
            style: TextStyle(
              color: count > 0 ? null : Colors.grey,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: count > 0 ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count개',
                  style: TextStyle(
                    color: count > 0 ? color : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIngredientCard(Ingredient ingredient) {
    final color = _getExpiryColor(ingredient.expiryStatus);

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        color: color.withOpacity(0.1),
        child: InkWell(
          onTap: () => context.push('/expiry-alert', extra: ingredient.expiryStatus),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ingredient.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
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
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${ingredient.quantity} ${ingredient.unit}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  ingredient.storageLocation.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
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
}
