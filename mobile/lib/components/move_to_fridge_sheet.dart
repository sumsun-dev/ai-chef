import 'package:flutter/material.dart';

import '../models/ingredient.dart';
import '../models/shopping_item.dart';
import '../services/ingredient_service.dart';
import '../services/shopping_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 쇼핑 아이템을 냉장고로 이동하는 바텀시트
class MoveToFridgeSheet extends StatefulWidget {
  final List<ShoppingItem> items;
  final IngredientService? ingredientService;
  final ShoppingService? shoppingService;

  const MoveToFridgeSheet({
    super.key,
    required this.items,
    this.ingredientService,
    this.shoppingService,
  });

  @override
  State<MoveToFridgeSheet> createState() => _MoveToFridgeSheetState();
}

class _MoveToFridgeSheetState extends State<MoveToFridgeSheet> {
  late final IngredientService _ingredientService;
  late final ShoppingService _shoppingService;
  late List<_FridgeItemConfig> _configs;
  bool _isSaving = false;

  /// 카테고리별 기본 유통기한 (일)
  static const _defaultExpiryDays = {
    'vegetable': 7,
    'fruit': 7,
    'meat': 5,
    'seafood': 3,
    'dairy': 14,
    'egg': 14,
    'grain': 180,
    'seasoning': 90,
    'other': 14,
  };

  /// 카테고리별 기본 보관위치
  static const _defaultLocations = {
    'vegetable': StorageLocation.fridge,
    'fruit': StorageLocation.fridge,
    'meat': StorageLocation.fridge,
    'seafood': StorageLocation.fridge,
    'dairy': StorageLocation.fridge,
    'egg': StorageLocation.fridge,
    'grain': StorageLocation.pantry,
    'seasoning': StorageLocation.pantry,
    'other': StorageLocation.fridge,
  };

  @override
  void initState() {
    super.initState();
    _ingredientService = widget.ingredientService ?? IngredientService();
    _shoppingService = widget.shoppingService ?? ShoppingService();
    _configs = widget.items.map((item) {
      final days = _defaultExpiryDays[item.category] ?? 14;
      final location = _defaultLocations[item.category] ?? StorageLocation.fridge;
      return _FridgeItemConfig(
        item: item,
        expiryDate: DateTime.now().add(Duration(days: days)),
        storageLocation: location,
      );
    }).toList();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final ingredients = _configs.map((config) {
        return Ingredient(
          name: config.item.name,
          category: config.item.category,
          quantity: config.item.quantity,
          unit: config.item.unit,
          expiryDate: config.expiryDate,
          storageLocation: config.storageLocation,
          purchaseDate: DateTime.now(),
        );
      }).toList();

      await _ingredientService.saveIngredients(ingredients);
      await _shoppingService.deleteCheckedItems();

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${ingredients.length}개 재료가 냉장고에 추가되었습니다.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('냉장고 추가에 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '냉장고에 추가',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${widget.items.length}개 아이템의 유통기한과 보관위치를 설정해주세요',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _configs.length,
                  itemBuilder: (context, index) {
                    return _buildItemConfig(_configs[index], index);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('${widget.items.length}개 냉장고에 추가'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemConfig(_FridgeItemConfig config, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${config.item.name} (${config.item.quantity} ${config.item.unit})',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // 유통기한
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '유통기한: ',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                InkWell(
                  onTap: () => _pickExpiryDate(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      _formatDate(config.expiryDate),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // 보관위치
            SegmentedButton<StorageLocation>(
              segments: const [
                ButtonSegment(
                  value: StorageLocation.fridge,
                  label: Text('냉장'),
                  icon: Icon(Icons.ac_unit, size: 16),
                ),
                ButtonSegment(
                  value: StorageLocation.freezer,
                  label: Text('냉동'),
                  icon: Icon(Icons.severe_cold, size: 16),
                ),
                ButtonSegment(
                  value: StorageLocation.pantry,
                  label: Text('실온'),
                  icon: Icon(Icons.countertops, size: 16),
                ),
              ],
              selected: {config.storageLocation},
              onSelectionChanged: (selected) {
                setState(() {
                  _configs[index] = config.copyWith(
                    storageLocation: selected.first,
                  );
                });
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 12, fontFamily: 'Pretendard'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickExpiryDate(int index) async {
    final config = _configs[index];
    final picked = await showDatePicker(
      context: context,
      initialDate: config.expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _configs[index] = config.copyWith(expiryDate: picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

class _FridgeItemConfig {
  final ShoppingItem item;
  final DateTime expiryDate;
  final StorageLocation storageLocation;

  _FridgeItemConfig({
    required this.item,
    required this.expiryDate,
    required this.storageLocation,
  });

  _FridgeItemConfig copyWith({
    DateTime? expiryDate,
    StorageLocation? storageLocation,
  }) {
    return _FridgeItemConfig(
      item: item,
      expiryDate: expiryDate ?? this.expiryDate,
      storageLocation: storageLocation ?? this.storageLocation,
    );
  }
}
