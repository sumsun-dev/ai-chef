import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/gemini_service.dart';

/// 실시간 요리 가이드 카메라 화면
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final GeminiService _geminiService = GeminiService();

  File? _selectedImage;
  CookingFeedback? _feedback;
  bool _isAnalyzing = false;
  String? _errorMessage;

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
          _feedback = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '카메라를 사용할 수 없습니다.';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _feedback = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '갤러리에서 사진을 선택할 수 없습니다.';
      });
    }
  }

  Future<void> _analyzePhoto() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final extension = _selectedImage!.path.split('.').last.toLowerCase();
      final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';

      final feedback = await _geminiService.analyzeCookingPhoto(
        imageBytes: bytes,
        mimeType: mimeType,
        chefConfig: AIChefConfig.defaultConfig,
      );

      setState(() {
        _feedback = feedback;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '사진 분석 중 오류가 발생했습니다: $e';
        _isAnalyzing = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _selectedImage = null;
      _feedback = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('요리 가이드 카메라'),
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
              tooltip: '다시 촬영',
            ),
        ],
      ),
      body: SafeArea(
        child: _selectedImage == null
            ? _buildCameraPrompt(colorScheme)
            : _buildPhotoPreview(colorScheme),
      ),
    );
  }

  Widget _buildCameraPrompt(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.restaurant,
                size: 60,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '요리 중인 음식을 촬영해주세요',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'AI 셰프가 익힘 정도와 플레이팅을\n분석하고 피드백을 드립니다',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('촬영하기'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('갤러리'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 24),
              Text(
                _errorMessage!,
                style: TextStyle(color: colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
              height: 250,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 16),
          if (_feedback == null && !_isAnalyzing) ...[
            FilledButton.icon(
              onPressed: _analyzePhoto,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('AI 분석 시작'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('다시 촬영'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
          if (_isAnalyzing) ...[
            const SizedBox(height: 32),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
            Text(
              'AI 셰프가 분석 중입니다...',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Card(
              color: colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              ),
            ),
          ],
          if (_feedback != null) _buildFeedbackCard(colorScheme),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(ColorScheme colorScheme) {
    final feedback = _feedback!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        // 격려 메시지
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer,
                colorScheme.secondaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_emotions, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feedback.encouragement,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 익힘 정도
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getDonenessIcon(feedback.doneness),
                      color: _getDonenessColor(feedback.doneness),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '익힘 정도: ${feedback.doneness.displayName}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  feedback.donenessDescription,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 플레이팅 점수
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.palette),
                    const SizedBox(width: 8),
                    Text(
                      '플레이팅 점수',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPlatingScoreColor(feedback.platingScore),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${feedback.platingScore}/10',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  feedback.platingFeedback,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 전반적인 평가
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.assessment),
                    const SizedBox(width: 8),
                    Text(
                      '전반적인 평가',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  feedback.overallAssessment,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),

        // 개선 제안
        if (feedback.suggestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb),
                      const SizedBox(width: 8),
                      Text(
                        '개선 제안',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...feedback.suggestions.map((suggestion) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 6, right: 8),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.camera_alt),
          label: const Text('새로운 사진 촬영'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  IconData _getDonenessIcon(Doneness doneness) {
    switch (doneness) {
      case Doneness.undercooked:
        return Icons.hourglass_empty;
      case Doneness.perfect:
        return Icons.check_circle;
      case Doneness.overcooked:
        return Icons.local_fire_department;
      case Doneness.notApplicable:
        return Icons.help_outline;
    }
  }

  Color _getDonenessColor(Doneness doneness) {
    switch (doneness) {
      case Doneness.undercooked:
        return Colors.orange;
      case Doneness.perfect:
        return Colors.green;
      case Doneness.overcooked:
        return Colors.red;
      case Doneness.notApplicable:
        return Colors.grey;
    }
  }

  Color _getPlatingScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }
}
