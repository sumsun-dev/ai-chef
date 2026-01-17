import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';

/// 홈 화면
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
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

            // 유통기한 알림 (더미)
            const Text(
              '유통기한 알림',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildAlertCard(
              icon: Icons.warning_amber,
              color: Colors.red,
              title: '유통기한 지남',
              count: 0,
            ),
            _buildAlertCard(
              icon: Icons.access_time,
              color: Colors.orange,
              title: '3일 이내 만료',
              count: 0,
            ),
            _buildAlertCard(
              icon: Icons.info_outline,
              color: Colors.blue,
              title: '7일 이내 만료',
              count: 0,
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
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count개',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
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
}
