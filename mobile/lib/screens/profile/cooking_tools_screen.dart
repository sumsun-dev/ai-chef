import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/onboarding_state.dart';
import '../onboarding/step_cooking_tools.dart';

/// 프로필 > 조리 도구 관리 화면
class CookingToolsScreen extends StatefulWidget {
  const CookingToolsScreen({super.key});

  @override
  State<CookingToolsScreen> createState() => _CookingToolsScreenState();
}

class _CookingToolsScreenState extends State<CookingToolsScreen> {
  Map<String, bool> _tools = Map.from(OnboardingState.defaultTools);
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadTools();
  }

  Future<void> _loadTools() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('cooking_tools')
          .select()
          .eq('user_id', userId);

      final loaded = Map<String, bool>.from(_tools);
      for (final row in response) {
        final key = row['tool_key'] as String?;
        if (key != null && loaded.containsKey(key)) {
          loaded[key] = row['is_available'] ?? false;
        }
      }

      if (mounted) {
        setState(() {
          _tools = loaded;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // 기존 도구 삭제 후 재삽입
      await Supabase.instance.client
          .from('cooking_tools')
          .delete()
          .eq('user_id', userId);

      final toolKeyToName = OnboardingState.toolKeyToName;
      final rows = _tools.entries.map((e) => {
        'user_id': userId,
        'tool_key': e.key,
        'tool_name': toolKeyToName[e.key] ?? e.key,
        'is_available': e.value,
      }).toList();

      await Supabase.instance.client.from('cooking_tools').insert(rows);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('조리 도구가 저장되었습니다.')),
        );
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('조리 도구 관리'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('저장'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StepCookingTools(
              tools: _tools,
              onChanged: (updated) => setState(() => _tools = updated),
            ),
    );
  }
}
