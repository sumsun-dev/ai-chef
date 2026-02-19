import 'package:flutter/material.dart';

/// 도움말 화면
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('도움말')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFaqItem(
            '재료는 어떻게 등록하나요?',
            '냉장고 탭에서 + 버튼을 눌러 직접 입력하거나, '
                '영수증 스캔으로 자동 등록할 수 있습니다.',
          ),
          _buildFaqItem(
            'AI 셰프를 변경할 수 있나요?',
            '프로필 > 내 셰프에서 원하는 셰프를 선택할 수 있습니다.',
          ),
          _buildFaqItem(
            '유통기한 알림은 어떻게 설정하나요?',
            '프로필 > 알림 설정에서 유통기한 알림을 켜면 '
                'D-3, D-1, D-Day에 알림을 받을 수 있습니다.',
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'AI Chef v1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
