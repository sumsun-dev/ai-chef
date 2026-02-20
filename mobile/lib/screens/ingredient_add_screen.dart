import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/ingredient.dart';
import '../services/ingredient_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 재료 직접 입력 화면
class IngredientAddScreen extends StatefulWidget {
  /// 수정 모드일 때 기존 재료 전달
  final Ingredient? ingredient;
  final IngredientService? ingredientService;

  const IngredientAddScreen({
    super.key,
    this.ingredient,
    this.ingredientService,
  });

  bool get isEditMode => ingredient != null;

  @override
  State<IngredientAddScreen> createState() => _IngredientAddScreenState();
}

class _IngredientAddScreenState extends State<IngredientAddScreen> {
  final _formKey = GlobalKey<FormState>();
  late final IngredientService _ingredientService;

  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _memoController;

  String _selectedCategory = 'other';
  String _selectedUnit = '개';
  StorageLocation _selectedStorage = StorageLocation.fridge;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  DateTime? _purchaseDate = DateTime.now();

  bool _isSaving = false;

  static const Map<String, String> _categories = {
    'vegetable': '채소',
    'fruit': '과일',
    'meat': '육류',
    'seafood': '해산물',
    'dairy': '유제품',
    'egg': '달걀',
    'grain': '곡류',
    'seasoning': '양념',
    'other': '기타',
  };

  static const List<String> _units = [
    '개',
    'g',
    'kg',
    'ml',
    'L',
    '팩',
    '봉',
    '병',
    '캔',
    '줄',
    '묶음',
  ];

  @override
  void initState() {
    super.initState();
    _ingredientService = widget.ingredientService ?? IngredientService();
    final i = widget.ingredient;
    _nameController = TextEditingController(text: i?.name ?? '');
    _quantityController =
        TextEditingController(text: (i?.quantity ?? 1).toString());
    _priceController =
        TextEditingController(text: i?.price?.toStringAsFixed(0) ?? '');
    _memoController = TextEditingController(text: i?.memo ?? '');

    if (i != null) {
      _selectedCategory = i.category;
      _selectedUnit = i.unit;
      _selectedStorage = i.storageLocation;
      _expiryDate = i.expiryDate;
      _purchaseDate = i.purchaseDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isExpiry}) async {
    final initial = isExpiry ? _expiryDate : (_purchaseDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isExpiry) {
          _expiryDate = picked;
        } else {
          _purchaseDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final ingredient = Ingredient(
        id: widget.ingredient?.id,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        quantity: double.tryParse(_quantityController.text) ?? 1,
        unit: _selectedUnit,
        expiryDate: _expiryDate,
        purchaseDate: _purchaseDate,
        storageLocation: _selectedStorage,
        price: double.tryParse(_priceController.text),
        memo: _memoController.text.trim().isEmpty
            ? null
            : _memoController.text.trim(),
      );

      if (widget.isEditMode) {
        await _ingredientService.updateIngredient(ingredient);
      } else {
        await _ingredientService.addIngredient(ingredient);
      }

      if (!mounted) return;

      if (widget.isEditMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('재료가 수정되었습니다.')),
        );
        context.pop(true);
      } else {
        _showPostSaveSheet(_nameController.text.trim());
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}. ${date.month}. ${date.day}.';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? '재료 수정' : '재료 추가'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 재료명
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '재료명 *',
                hintText: '예: 삼겹살, 양파, 우유',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '재료명을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 카테고리
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: '카테고리',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // 수량 + 단위
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: '수량',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: '단위',
                      border: OutlineInputBorder(),
                    ),
                    items: _units
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedUnit = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 보관 위치
            Text(
              '보관 위치',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<StorageLocation>(
              segments: StorageLocation.values
                  .map((s) => ButtonSegment(
                        value: s,
                        label: Text(s.displayName),
                        icon: Icon(_getStorageIcon(s)),
                      ))
                  .toList(),
              selected: {_selectedStorage},
              onSelectionChanged: (selected) {
                setState(() => _selectedStorage = selected.first);
              },
            ),
            const SizedBox(height: 24),

            // 유통기한
            _buildDateTile(
              icon: Icons.event,
              label: '유통기한 *',
              date: _expiryDate,
              color: colorScheme.error,
              onTap: () => _pickDate(isExpiry: true),
            ),
            const SizedBox(height: 12),

            // 구매일
            _buildDateTile(
              icon: Icons.shopping_cart,
              label: '구매일',
              date: _purchaseDate,
              color: colorScheme.primary,
              onTap: () => _pickDate(isExpiry: false),
              onClear: () => setState(() => _purchaseDate = null),
            ),
            const SizedBox(height: 16),

            // 가격
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: '가격 (원)',
                hintText: '선택사항',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // 메모
            TextFormField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: '메모',
                hintText: '선택사항',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTile({
    required IconData icon,
    required String label,
    required DateTime? date,
    required Color color,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null ? _formatDate(date) : '선택 안 함',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null && date != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: onClear,
                color: AppColors.textTertiary,
              ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  void _showPostSaveSheet(String ingredientName) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '$ingredientName이(가) 추가되었습니다!',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              ListTile(
                leading: const Icon(Icons.restaurant_menu, color: AppColors.primary),
                title: const Text('이 재료로 레시피 추천받기'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.pop(true);
                  context.go('/recipe');
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: AppColors.accent),
                title: const Text('재료 더 추가하기'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(sheetContext);
                  // 폼 초기화
                  _formKey.currentState?.reset();
                  _nameController.clear();
                  _quantityController.text = '1';
                  _priceController.clear();
                  _memoController.clear();
                  setState(() {
                    _selectedCategory = 'other';
                    _selectedUnit = '개';
                    _selectedStorage = StorageLocation.fridge;
                    _expiryDate = DateTime.now().add(const Duration(days: 7));
                    _purchaseDate = DateTime.now();
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.check, color: AppColors.textSecondary),
                title: const Text('완료'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.pop(true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStorageIcon(StorageLocation location) {
    switch (location) {
      case StorageLocation.fridge:
        return Icons.kitchen;
      case StorageLocation.freezer:
        return Icons.ac_unit;
      case StorageLocation.pantry:
        return Icons.home;
    }
  }
}
