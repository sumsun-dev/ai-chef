import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/ingredient.dart';
import '../services/ingredient_service.dart';

/// 재료 검토 및 편집 화면
class IngredientReviewScreen extends StatefulWidget {
  final ReceiptOcrResult ocrResult;

  const IngredientReviewScreen({
    super.key,
    required this.ocrResult,
  });

  @override
  State<IngredientReviewScreen> createState() => _IngredientReviewScreenState();
}

class _IngredientReviewScreenState extends State<IngredientReviewScreen> {
  late List<Ingredient> _ingredients;
  final Set<int> _selectedIndices = {};
  bool _isSaving = false;

  final IngredientService _ingredientService = IngredientService();

  @override
  void initState() {
    super.initState();
    _ingredients = List.from(widget.ocrResult.ingredients);
    // 기본적으로 모두 선택
    _selectedIndices.addAll(List.generate(_ingredients.length, (i) => i));
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedIndices.length == _ingredients.length) {
        _selectedIndices.clear();
      } else {
        _selectedIndices.addAll(List.generate(_ingredients.length, (i) => i));
      }
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
      _selectedIndices.remove(index);
      // 인덱스 재조정
      final newSelected = <int>{};
      for (final i in _selectedIndices) {
        if (i > index) {
          newSelected.add(i - 1);
        } else {
          newSelected.add(i);
        }
      }
      _selectedIndices
        ..clear()
        ..addAll(newSelected);
    });
  }

  Future<void> _editIngredient(int index) async {
    final ingredient = _ingredients[index];
    final result = await showModalBottomSheet<Ingredient>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _IngredientEditSheet(ingredient: ingredient),
    );

    if (result != null) {
      setState(() {
        _ingredients[index] = result;
      });
    }
  }

  Future<void> _saveIngredients() async {
    final selectedIngredients = _selectedIndices
        .map((i) => _ingredients[i])
        .toList();

    if (selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장할 재료를 선택해주세요.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _ingredientService.saveIngredients(selectedIngredients);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${selectedIngredients.length}개의 재료가 저장되었습니다.')),
      );

      // 홈으로 이동
      context.go('/');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 중 오류가 발생했습니다: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('yyyy.MM.dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text('인식된 재료'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _selectAll,
            child: Text(
              _selectedIndices.length == _ingredients.length ? '전체 해제' : '전체 선택',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 상단 정보
          if (widget.ocrResult.storeName != null ||
              widget.ocrResult.purchaseDate != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  if (widget.ocrResult.storeName != null) ...[
                    Icon(Icons.store, size: 16, color: colorScheme.outline),
                    const SizedBox(width: 4),
                    Text(
                      widget.ocrResult.storeName!,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (widget.ocrResult.purchaseDate != null) ...[
                    Icon(Icons.calendar_today,
                        size: 16, color: colorScheme.outline),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(widget.ocrResult.purchaseDate!),
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),

          // 재료 목록
          Expanded(
            child: _ingredients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '인식된 재료가 없습니다.',
                          style: TextStyle(color: colorScheme.outline),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _ingredients.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final ingredient = _ingredients[index];
                      final isSelected = _selectedIndices.contains(index);

                      return _IngredientCard(
                        ingredient: ingredient,
                        isSelected: isSelected,
                        onToggle: () => _toggleSelection(index),
                        onEdit: () => _editIngredient(index),
                        onDelete: () => _removeIngredient(index),
                      );
                    },
                  ),
          ),

          // 하단 저장 버튼
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '선택된 재료',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        '${_selectedIndices.length}/${_ingredients.length}개',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          _isSaving || _selectedIndices.isEmpty ? null : _saveIngredients,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? '저장 중...' : '선택한 재료 저장'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
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

/// 재료 카드 위젯
class _IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _IngredientCard({
    required this.ingredient,
    required this.isSelected,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MM.dd');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 체크박스
              Checkbox(
                value: isSelected,
                onChanged: (_) => onToggle(),
              ),

              // 재료 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          ingredient.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildConfidenceBadge(ingredient.ocrConfidence, colorScheme),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildInfoChip(
                          '${ingredient.quantity} ${ingredient.unit}',
                          colorScheme,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          _getCategoryDisplayName(ingredient.category),
                          colorScheme,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          '~${dateFormat.format(ingredient.expiryDate)}',
                          colorScheme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 액션 버튼
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
                tooltip: '편집',
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                onPressed: onDelete,
                tooltip: '삭제',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(OcrConfidence? confidence, ColorScheme colorScheme) {
    if (confidence == null) return const SizedBox.shrink();

    final colors = {
      OcrConfidence.high: Colors.green,
      OcrConfidence.medium: Colors.orange,
      OcrConfidence.low: Colors.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors[confidence]!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        confidence.displayName,
        style: TextStyle(
          fontSize: 10,
          color: colors[confidence],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    const categoryNames = {
      'produce': '채소/과일',
      'dairy': '유제품',
      'meat': '육류',
      'seafood': '해산물',
      'pantry': '건조식품',
      'frozen': '냉동',
      'beverages': '음료',
      'bakery': '빵/과자',
      'condiments': '양념',
      'other': '기타',
    };
    return categoryNames[category] ?? '기타';
  }
}

/// 재료 편집 바텀시트
class _IngredientEditSheet extends StatefulWidget {
  final Ingredient ingredient;

  const _IngredientEditSheet({required this.ingredient});

  @override
  State<_IngredientEditSheet> createState() => _IngredientEditSheetState();
}

class _IngredientEditSheetState extends State<_IngredientEditSheet> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late String _selectedUnit;
  late String _selectedCategory;
  late StorageLocation _selectedStorage;
  late DateTime _expiryDate;

  final List<String> _units = ['개', 'g', 'kg', 'ml', 'L', '팩', '봉', '병', '캔'];
  final Map<String, String> _categories = {
    'produce': '채소/과일',
    'dairy': '유제품',
    'meat': '육류',
    'seafood': '해산물',
    'pantry': '건조식품',
    'frozen': '냉동',
    'beverages': '음료',
    'bakery': '빵/과자',
    'condiments': '양념',
    'other': '기타',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient.name);
    _quantityController =
        TextEditingController(text: widget.ingredient.quantity.toString());
    _selectedUnit = widget.ingredient.unit;
    _selectedCategory = widget.ingredient.category;
    _selectedStorage = widget.ingredient.storageLocation;
    _expiryDate = widget.ingredient.expiryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  void _save() {
    final quantity = double.tryParse(_quantityController.text) ?? 1;

    final updatedIngredient = widget.ingredient.copyWith(
      name: _nameController.text.trim(),
      quantity: quantity,
      unit: _selectedUnit,
      category: _selectedCategory,
      storageLocation: _selectedStorage,
      expiryDate: _expiryDate,
    );

    Navigator.pop(context, updatedIngredient);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('yyyy.MM.dd');

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '재료 편집',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 재료명
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '재료명',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 수량 & 단위
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '수량',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _units.contains(_selectedUnit) ? _selectedUnit : _units.first,
                    decoration: const InputDecoration(
                      labelText: '단위',
                      border: OutlineInputBorder(),
                    ),
                    items: _units
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedUnit = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 카테고리
            DropdownButtonFormField<String>(
              value: _categories.containsKey(_selectedCategory)
                  ? _selectedCategory
                  : 'other',
              decoration: const InputDecoration(
                labelText: '카테고리',
                border: OutlineInputBorder(),
              ),
              items: _categories.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 16),

            // 보관 위치
            DropdownButtonFormField<StorageLocation>(
              value: _selectedStorage,
              decoration: const InputDecoration(
                labelText: '보관 위치',
                border: OutlineInputBorder(),
              ),
              items: StorageLocation.values
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.displayName),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedStorage = v!),
            ),
            const SizedBox(height: 16),

            // 유통기한
            InkWell(
              onTap: _selectExpiryDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '유통기한',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateFormat.format(_expiryDate)),
                    Icon(Icons.calendar_today, color: colorScheme.outline),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 저장 버튼
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('저장'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
