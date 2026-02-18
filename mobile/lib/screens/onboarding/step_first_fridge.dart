import 'package:flutter/material.dart';

import '../../models/onboarding_state.dart';

/// 온보딩 Step 4: 첫 냉장고 등록
class StepFirstFridge extends StatefulWidget {
  final List<SimpleIngredient> ingredients;
  final ValueChanged<List<SimpleIngredient>> onChanged;

  const StepFirstFridge({
    super.key,
    required this.ingredients,
    required this.onChanged,
  });

  @override
  State<StepFirstFridge> createState() => _StepFirstFridgeState();
}

class _StepFirstFridgeState extends State<StepFirstFridge> {
  final _nameController = TextEditingController();
  String _selectedCategory = 'vegetable';

  static const _categories = {
    'vegetable': '🥬 채소',
    'fruit': '🍎 과일',
    'meat': '🥩 육류',
    'seafood': '🐟 해산물',
    'dairy': '🧀 유제품',
    'egg': '🥚 달걀',
    'grain': '🌾 곡류',
    'seasoning': '🧂 양념',
    'other': '📦 기타',
  };

  void _addIngredient() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final updated = List<SimpleIngredient>.from(widget.ingredients)
      ..add(SimpleIngredient(name: name, category: _selectedCategory));
    widget.onChanged(updated);
    _nameController.clear();
  }

  void _removeIngredient(int index) {
    final updated = List<SimpleIngredient>.from(widget.ingredients)
      ..removeAt(index);
    widget.onChanged(updated);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            '냉장고에\n뭐가 있나요?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '간단하게 등록하거나 나중에 추가할 수 있어요',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // 입력 영역
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: '재료 이름',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onSubmitted: (_) => _addIngredient(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: _categories.entries.map((e) {
                    return DropdownMenuItem(value: e.key, child: Text(e.value));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addIngredient,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 추가된 재료 목록
          if (widget.ingredients.isNotEmpty) ...[
            Text(
              '추가된 재료 (${widget.ingredients.length}개)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(widget.ingredients.length, (index) {
                    final item = widget.ingredients[index];
                    final emoji = _categories[item.category]?.split(' ')[0] ?? '📦';
                    return Chip(
                      label: Text('$emoji ${item.name}'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeIngredient(index),
                    );
                  }),
                ),
              ),
            ),
          ] else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.kitchen,
                      size: 64,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '재료를 추가하거나\n나중에 등록해도 괜찮아요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
