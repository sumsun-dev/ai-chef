import 'package:flutter/material.dart';

/// 알림 설정 화면
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _expiryAlert = true;
  bool _recipeRecommendation = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('알림 설정')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('유통기한 알림'),
            subtitle: const Text('D-3, D-1, D-Day 재료 알림'),
            value: _expiryAlert,
            onChanged: (v) => setState(() => _expiryAlert = v),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('레시피 추천 알림'),
            subtitle: const Text('새로운 맞춤 레시피 추천'),
            value: _recipeRecommendation,
            onChanged: (v) => setState(() => _recipeRecommendation = v),
          ),
        ],
      ),
    );
  }
}
