import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../services/receipt_ocr_service.dart';

/// 영수증 스캔 화면
class ReceiptScanScreen extends StatefulWidget {
  const ReceiptScanScreen({super.key});

  @override
  State<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends State<ReceiptScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final ReceiptOcrService _ocrService = ReceiptOcrService();

  File? _selectedImage;
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '이미지를 불러오는데 실패했습니다.';
      });
    }
  }

  Future<void> _processReceipt() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final result =
          await _ocrService.extractIngredientsFromReceipt(_selectedImage!);

      if (!mounted) return;

      if (result.ingredients.isEmpty) {
        setState(() {
          _isProcessing = false;
          _errorMessage = '영수증에서 식재료를 찾지 못했습니다.\n다른 이미지를 시도해보세요.';
        });
        return;
      }

      // 결과 화면으로 이동
      context.push('/receipt-result', extra: result);
    } catch (e) {
      setState(() {
        _errorMessage = 'OCR 처리 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
      });
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('영수증 스캔'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 안내 텍스트
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '영수증을 촬영하거나 갤러리에서 선택하면\nAI가 자동으로 재료를 인식합니다.',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 이미지 선택 영역
            if (_selectedImage != null) ...[
              // 선택된 이미지 미리보기
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              // 다시 선택 버튼
              OutlinedButton.icon(
                onPressed: _isProcessing ? null : () => _showImageSourceDialog(),
                icon: const Icon(Icons.refresh),
                label: const Text('다른 이미지 선택'),
              ),
            ] else ...[
              // 이미지 선택 버튼들
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.5),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showImageSourceDialog,
                    borderRadius: BorderRadius.circular(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '영수증 이미지 선택',
                          style: TextStyle(
                            color: colorScheme.outline,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // 에러 메시지
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // 촬영/갤러리 버튼 (이미지가 없을 때)
            if (_selectedImage == null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.camera_alt,
                      label: '카메라',
                      onTap: () => _pickImage(ImageSource.camera),
                      colorScheme: colorScheme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.photo_library,
                      label: '갤러리',
                      onTap: () => _pickImage(ImageSource.gallery),
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ),
            ],

            // 분석 시작 버튼 (이미지가 있을 때)
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isProcessing ? null : _processReceipt,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.document_scanner),
                label: Text(_isProcessing ? '분석 중...' : '재료 인식 시작'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // 팁 섹션
            _buildTipsSection(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, size: 32, color: colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipsSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '촬영 팁',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _buildTipItem(
          Icons.wb_sunny_outlined,
          '밝은 곳에서 촬영하세요',
          colorScheme,
        ),
        _buildTipItem(
          Icons.crop_free,
          '영수증 전체가 보이도록 촬영하세요',
          colorScheme,
        ),
        _buildTipItem(
          Icons.blur_off,
          '글자가 선명하게 보이도록 촬영하세요',
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildTipItem(IconData icon, String text, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.outline),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
