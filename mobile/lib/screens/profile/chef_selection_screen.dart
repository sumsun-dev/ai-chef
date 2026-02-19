import 'package:flutter/material.dart';

import '../../models/chef_presets.dart';
import '../../services/auth_service.dart';
import '../onboarding/step_chef_selection.dart';

/// 프로필 > 셰프 변경 화면
class ChefSelectionScreen extends StatefulWidget {
  final AuthService? authService;

  const ChefSelectionScreen({super.key, this.authService});

  @override
  State<ChefSelectionScreen> createState() => _ChefSelectionScreenState();
}

class _ChefSelectionScreenState extends State<ChefSelectionScreen> {
  late final AuthService _authService;

  String? _selectedPresetId;
  String _chefName = '';
  String _personality = 'professional';
  List<String> _expertise = ['한식'];
  String _formality = 'formal';
  String _emojiUsage = 'medium';
  String _technicality = 'general';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _loadCurrentChef();
  }

  Future<void> _loadCurrentChef() async {
    try {
      final profile = await _authService.getUserProfile();
      if (profile == null) return;

      final chefId = profile['primary_chef_id'] ?? 'baek';
      final preset = ChefPresets.all.where((p) => p.id == chefId).firstOrNull;

      if (preset != null && mounted) {
        setState(() {
          _selectedPresetId = preset.id;
          _chefName = preset.config.name;
          _personality = preset.config.personality.name;
          _expertise = List.from(preset.config.expertise);
          _formality = preset.config.speakingStyle.formality.name;
          _emojiUsage = preset.config.speakingStyle.emojiUsage.name;
          _technicality = preset.config.speakingStyle.technicality.name;
        });
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await _authService.updateUserProfile({
        'primary_chef_id': _selectedPresetId ?? 'baek',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('셰프가 변경되었습니다.')),
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
        title: const Text('셰프 변경'),
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
      body: StepChefSelection(
        selectedPresetId: _selectedPresetId,
        chefName: _chefName,
        personality: _personality,
        expertise: _expertise,
        formality: _formality,
        emojiUsage: _emojiUsage,
        technicality: _technicality,
        onChanged: ({
          String? presetId,
          required String name,
          required String personality,
          required List<String> expertise,
          required String formality,
          required String emojiUsage,
          required String technicality,
        }) {
          setState(() {
            _selectedPresetId = presetId;
            _chefName = name;
            _personality = personality;
            _expertise = expertise;
            _formality = formality;
            _emojiUsage = emojiUsage;
            _technicality = technicality;
          });
        },
      ),
    );
  }
}
