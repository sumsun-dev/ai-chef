import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/chef.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// 프로필 탭
class ProfileTab extends StatefulWidget {
  final AuthService? authService;

  const ProfileTab({super.key, this.authService});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late final AuthService _authService;
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userName = _profile?['name'] ?? '사용자';
    final email = _profile?['email'] ?? '';
    final primaryChefId = _profile?['primary_chef_id'] ?? 'baek';
    final chef = Chefs.findById(primaryChefId) ?? Chefs.defaultChef;
    final chefColor = Color(chef.primaryColor);

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // 프로필 카드 — 그라디언트 배경
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  chefColor.withValues(alpha: 0.15),
                  chefColor.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: chefColor.withValues(alpha: 0.2),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: chefColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 내 셰프
          _buildSectionTitle('내 셰프'),
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: () async {
                final result =
                    await context.push<bool>('/profile/chef-selection');
                if (result == true) _loadProfile();
              },
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: chefColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Center(
                        child: Text(
                          chef.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chef.name,
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            chef.title,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            chef.philosophy,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 요리 설정
          _buildSectionTitle('요리 설정'),
          Card(
            child: Column(
              children: [
                _buildSettingTile(
                  icon: Icons.star,
                  title: '요리 실력',
                  value: _getSkillLevelText(_profile?['skill_level']),
                  onTap: () async {
                    final result = await context.push<bool>('/profile/edit');
                    if (result == true) _loadProfile();
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingTile(
                  icon: Icons.people,
                  title: '가구원 수',
                  value: '${_profile?['household_size'] ?? 1}명',
                  onTap: () async {
                    final result = await context.push<bool>('/profile/edit');
                    if (result == true) _loadProfile();
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingTile(
                  icon: Icons.timer,
                  title: '선호 조리시간',
                  value: _getTimePreferenceText(_profile?['time_preference']),
                  onTap: () async {
                    final result = await context.push<bool>('/profile/edit');
                    if (result == true) _loadProfile();
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingTile(
                  icon: Icons.attach_money,
                  title: '1인분 예산',
                  value: _getBudgetText(_profile?['budget_preference']),
                  onTap: () async {
                    final result = await context.push<bool>('/profile/edit');
                    if (result == true) _loadProfile();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 요리 통계
          _buildSectionTitle('요리 활동'),
          Card(
            child: _buildSettingTile(
              icon: Icons.bar_chart,
              title: '요리 통계',
              onTap: () => context.push('/profile/statistics'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 조리 도구
          _buildSectionTitle('조리 도구 관리'),
          Card(
            child: _buildSettingTile(
              icon: Icons.kitchen,
              title: '보유 조리 도구',
              onTap: () async {
                final result =
                    await context.push<bool>('/profile/cooking-tools');
                if (result == true) _loadProfile();
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 앱 설정
          _buildSectionTitle('설정'),
          Card(
            child: Column(
              children: [
                _buildSettingTile(
                  icon: Icons.notifications,
                  title: '알림 설정',
                  onTap: () => context.push('/settings/notifications'),
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingTile(
                  icon: Icons.lock,
                  title: '개인정보 및 보안',
                  onTap: () => context.push('/settings/privacy'),
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingTile(
                  icon: Icons.help,
                  title: '도움말',
                  onTap: () => context.push('/settings/help'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 로그아웃
          OutlinedButton(
            onPressed: _signOut,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            child: const Text('로그아웃'),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          fontSize: 16,
          color: AppColors.textPrimary,
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
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
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
