import 'package:flutter/material.dart';

import '../models/shopping_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 쇼핑 아이템 추가 바텀시트
class ShoppingItemAddSheet extends StatefulWidget {
  final void Function(ShoppingItem item) onAdd;

  const ShoppingItemAddSheet({super.key, required this.onAdd});

  @override
  State<ShoppingItemAddSheet> createState() => _ShoppingItemAddSheetState();
}

class _ShoppingItemAddSheetState extends State<ShoppingItemAddSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  String _selectedUnit = '개';
  String _selectedCategory = 'other';

  static const _units = ['개', 'g', 'kg', 'ml', 'L', '팩', '봉', '병', '캔'];

  static const _categories = [
    ('vegetable', '채소'),
    ('fruit', '과일'),
    ('meat', '육류'),
    ('seafood', '해산물'),
    ('dairy', '유제품'),
    ('egg', '달걀'),
    ('grain', '곡류'),
    ('seasoning', '양념'),
    ('other', '기타'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final item = ShoppingItem(
      name: _nameController.text.trim(),
      quantity: double.tryParse(_quantityController.text) ?? 1,
      unit: _selectedUnit,
      category: _selectedCategory,
    );

    widget.onAdd(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '쇼핑 아이템 추가',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름',
                hintText: '재료명을 입력하세요',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '이름을 입력해주세요';
                }
                return null;
              },
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: '수량'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedUnit,
                    decoration: const InputDecoration(labelText: '단위'),
                    items: _units.map((unit) {
                      return DropdownMenuItem(value: unit, child: Text(unit));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedUnit = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: '카테고리'),
              items: _categories.map((entry) {
                final (value, label) = entry;
                return DropdownMenuItem(value: value, child: Text(label));
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('추가하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
