import 'package:flutter/material.dart';

import '../../components/category_emoji.dart';
import '../../components/empty_state.dart';
import '../../components/shopping_item_add_sheet.dart';
import '../../components/move_to_fridge_sheet.dart';
import '../../models/shopping_item.dart';
import '../../services/ingredient_service.dart';
import '../../services/shopping_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// 쇼핑 리스트 탭
class ShoppingTab extends StatefulWidget {
  final ShoppingService? shoppingService;
  final IngredientService? ingredientService;

  const ShoppingTab({
    super.key,
    this.shoppingService,
    this.ingredientService,
  });

  @override
  State<ShoppingTab> createState() => _ShoppingTabState();
}

class _ShoppingTabState extends State<ShoppingTab> {
  late final ShoppingService _shoppingService;
  late final IngredientService _ingredientService;
  List<ShoppingItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _shoppingService = widget.shoppingService ?? ShoppingService();
    _ingredientService = widget.ingredientService ?? IngredientService();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _shoppingService.getShoppingItems();
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 카테고리별 그룹핑
  Map<String, List<ShoppingItem>> get _groupedItems {
    final grouped = <String, List<ShoppingItem>>{};
    for (final item in _items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  bool get _hasCheckedItems => _items.any((item) => item.isChecked);

  Future<void> _toggleCheck(ShoppingItem item) async {
    final newChecked = !item.isChecked;
    // 낙관적 업데이트
    setState(() {
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item.copyWith(isChecked: newChecked);
      }
    });
    try {
      await _shoppingService.toggleCheck(item.id!, newChecked);
    } catch (e) {
      // 실패 시 롤백
      setState(() {
        final index = _items.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          _items[index] = item.copyWith(isChecked: !newChecked);
        }
      });
    }
  }

  Future<void> _deleteCheckedItems() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('완료 항목 정리'),
        content: const Text('체크된 항목을 모두 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _shoppingService.deleteCheckedItems();
      _loadItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('완료 항목이 정리되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('정리에 실패했습니다.')),
        );
      }
    }
  }

  Future<void> _moveToFridge() async {
    final checkedItems = _items.where((i) => i.isChecked).toList();
    if (checkedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('체크된 항목이 없습니다.')),
      );
      return;
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => MoveToFridgeSheet(
        items: checkedItems,
        ingredientService: _ingredientService,
        shoppingService: _shoppingService,
      ),
    );

    if (result == true) {
      _loadItems();
    }
  }

  void _showAddSheet() {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ShoppingItemAddSheet(
        onAdd: (item) async {
          try {
            await _shoppingService.addShoppingItem(item);
            _loadItems();
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('${item.name}이(가) 추가되었습니다.')),
              );
            }
          } catch (e) {
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('추가에 실패했습니다.')),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('쇼핑 리스트'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: _hasCheckedItems ? _deleteCheckedItems : null,
            tooltip: '완료 정리',
          ),
          IconButton(
            icon: const Icon(Icons.kitchen),
            onPressed: _hasCheckedItems ? _moveToFridge : null,
            tooltip: '냉장고에 추가',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadItems,
              child: _items.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        EmptyState(
                          emoji: '\u{1F6D2}',
                          title: '쇼핑 리스트가 비어있어요',
                          subtitle: '필요한 재료를 추가해 보세요',
                        ),
                      ],
                    )
                  : _buildGroupedList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add),
        label: const Text('추가'),
      ),
    );
  }

  Widget _buildGroupedList() {
    final grouped = _groupedItems;
    final categories = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: 80,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final items = grouped[category]!;
        return _buildCategorySection(category, items);
      },
    );
  }

  Widget _buildCategorySection(String category, List<ShoppingItem> items) {
    final emoji = getCategoryEmoji(category);
    final label = getCategoryLabel(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${items.length}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildShoppingItemTile(item)),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _buildShoppingItemTile(ShoppingItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        leading: Checkbox(
          value: item.isChecked,
          onChanged: (_) => _toggleCheck(item),
        ),
        title: Text(
          item.name,
          style: AppTypography.bodyLarge.copyWith(
            color: item.isChecked ? AppColors.textTertiary : AppColors.textPrimary,
            decoration: item.isChecked ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          [
            '${item.quantity} ${item.unit}',
            if (item.source == ShoppingItemSource.recipe && item.recipeTitle != null)
              item.recipeTitle!,
          ].join(' · '),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 18),
          onPressed: () async {
            if (item.id == null) return;
            try {
              await _shoppingService.deleteShoppingItem(item.id!);
              _loadItems();
            } catch (_) {}
          },
          tooltip: '삭제',
        ),
      ),
    );
  }
}
