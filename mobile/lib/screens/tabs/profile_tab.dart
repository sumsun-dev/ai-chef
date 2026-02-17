import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/chef.dart';
import '../../services/auth_service.dart';

/// 프로필 탭
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userName = _profile?['name'] ?? '사용자';
    final email = _profile?['email'] ?? '';
    final primaryChefId = _profile?['primary_chef_id'] ?? 'baek';
    final chef = Chefs.findById(primaryChefId) ?? Chefs.defaultChef;

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 프로필 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 내 셰프
          _buildSectionTitle('👨‍🍳 내 셰프'),
          Card(
            child: ListTile(
              leading: Text(chef.emoji, style: const TextStyle(fontSize: 32)),
              title: Text(chef.name),
              subtitle: Text(chef.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: 셰프 선택 화면
              },
            ),
          ),
          const SizedBox(height: 16),

          // 요리 설정
          _buildSectionTitle('🍳 요리 설정'),
          Card(
            child: Column(
              children: [
                _buildSettingTile(
                  icon: Icons.star,
                  title: '요리 실력',
                  value: _getSkillLevelText(_profile?['skill_level']),
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildSettingTile(
                  icon: Icons.people,
                  title: '가구원 수',
                  value: '${_profile?['household_size'] ?? 1}명',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildSettingTile(
                  icon: Icons.timer,
                  title: '선호 조리시간',
                  value: _getTimePreferenceText(_profile?['time_preference']),
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildSettingTile(
                  icon: Icons.attach_money,
                  title: '1인분 예산',
                  value: _getBudgetText(_profile?['budget_preference']),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 조리 도구
          _buildSectionTitle('🔧 조리 도구 관리'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.kitchen),
              title: const Text('보유 조리 도구'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: 조리 도구 관리 화면
              },
            ),
          ),
          const SizedBox(height: 16),

          // 앱 설정
          _buildSectionTitle('⚙️ 설정'),
          Card(
            child: Column(
              children: [
                _buildSettingTile(
                  icon: Icons.notifications,
                  title: '알림 설정',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildSettingTile(
                  icon: Icons.lock,
                  title: '개인정보 및 보안',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildSettingTile(
                  icon: Icons.help,
                  title: '도움말',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 로그아웃
          OutlinedButton(
            onPressed: _signOut,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text('로그아웃'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value,
              style: TextStyle(color: Colors.grey[600]),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }

  String _getSkillLevelText(String? level) {
    switch (level) {
      case 'beginner':
        return '왕초보';
      case 'novice':
        return '초보';
      case 'intermediate':
        return '중급';
      case 'advanced':
        return '고급';
      default:
        return '미설정';
    }
  }

  String _getTimePreferenceText(String? pref) {
    switch (pref) {
      case '10min':
        return '10분 이내';
      case '20min':
        return '20분 이내';
      case '40min':
        return '40분 이내';
      case 'unlimited':
        return '상관없음';
      default:
        return '미설정';
    }
  }

  String _getBudgetText(String? budget) {
    switch (budget) {
      case 'low':
        return '3천원 이하';
      case 'medium':
        return '3-5천원';
      case 'high':
        return '5천원 이상';
      case 'unlimited':
        return '상관없음';
      default:
        return '미설정';
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      context.go('/login');
    }
  }
}
