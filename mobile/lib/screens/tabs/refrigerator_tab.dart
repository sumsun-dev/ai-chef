import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/category_emoji.dart';
import '../../components/empty_state.dart';
import '../../components/expiry_badge.dart';
import '../../models/ingredient.dart';
import '../../services/ingredient_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// 냉장고 탭
class RefrigeratorTab extends StatefulWidget {
  const RefrigeratorTab({super.key});

  @override
  State<RefrigeratorTab> createState() => _RefrigeratorTabState();
}

class _RefrigeratorTabState extends State<RefrigeratorTab> {
  final IngredientService _ingredientService = IngredientService();
  List<Ingredient> _ingredients = [];
  bool _isLoading = true;
  String _selectedLocation = 'all';
  String? _selectedCategory;
  String _sortBy = 'expiry';
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const _locations = [
    ('all', '전체', '📋'),
    ('fridge', '냉장', '❄️'),
    ('freezer', '냉동', '🧊'),
    ('pantry', '실온', '📦'),
  ];

  static const _categories = [
    ('all', '전체', '🍽️'),
    ('vegetable', '채소', '🥬'),
    ('fruit', '과일', '🍎'),
    ('meat', '고기', '🍖'),
    ('seafood', '해산물', '🐟'),
    ('dairy', '유제품', '🥛'),
    ('egg', '계란', '🥚'),
    ('grain', '곡류', '🍚'),
    ('seasoning', '양념', '🧂'),
    ('other', '기타', '🍽️'),
  ];

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadIngredients() async {
    setState(() => _isLoading = true);
    try {
      final ingredients = await _ingredientService.getUserIngredients();
      setState(() {
        _ingredients = ingredients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Ingredient> get _filteredIngredients {
    var result = List<Ingredient>.from(_ingredients);

    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
              (i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedLocation != 'all') {
      result = result.where((i) {
        switch (_selectedLocation) {
          case 'fridge':
            return i.storageLocation == StorageLocation.fridge;
          case 'freezer':
            return i.storageLocation == StorageLocation.freezer;
          case 'pantry':
            return i.storageLocation == StorageLocation.pantry;
          default:
            return true;
        }
      }).toList();
    }

    if (_selectedCategory != null && _selectedCategory != 'all') {
      result = result.where((i) => i.category == _selectedCategory).toList();
    }

    switch (_sortBy) {
      case 'expiry':
        result.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
        break;
      case 'name':
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'category':
        result.sort((a, b) => a.category.compareTo(b.category));
        break;
    }

    return result;
  }

  List<Ingredient> get _expiringIngredients {
    return _ingredients.where((i) {
      final daysUntil = i.expiryDate.difference(DateTime.now()).inDays;
      return daysUntil <= 3 && daysUntil >= 0;
    }).toList()
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '재료 검색...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: true,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : const Text('냉장고'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => [
              _buildSortMenuItem('expiry', '유통기한순'),
              _buildSortMenuItem('name', '이름순'),
              _buildSortMenuItem('category', '카테고리순'),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadIngredients,
              child: CustomScrollView(
                slivers: [
                  if (_expiringIngredients.isNotEmpty)
                    SliverToBoxAdapter(child: _buildExpiryAlert()),

                  // 위치 필터 — SegmentedButton 스타일
                  SliverToBoxAdapter(child: _buildLocationFilter()),

                  // 카테고리 필터 — 이모지+텍스트 칩
                  SliverToBoxAdapter(child: _buildCategoryFilter()),

                  if (_filteredIngredients.isEmpty)
                    SliverFillRemaining(child: _buildEmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _buildIngredientCard(
                                _filteredIngredients[index]);
                          },
                          childCount: _filteredIngredients.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddIngredientSheet,
        icon: const Icon(Icons.add),
        label: const Text('재료 추가'),
      ),
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (_sortBy == value)
            const Icon(Icons.check, size: 18, color: AppColors.primary),
          if (_sortBy == value) const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildExpiryAlert() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.expiryCritical.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.expiryCritical.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber,
                  color: AppColors.expiryCritical, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '유통기한 임박 (${_expiringIngredients.length})',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.expiryCritical,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: _expiringIngredients.take(5).map((i) {
              return Chip(
                label: Text('${i.name} (${i.dDayString})'),
                backgroundColor:
                    AppColors.expiryCritical.withValues(alpha: 0.1),
                labelStyle: AppTypography.bodySmall,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: SegmentedButton<String>(
        segments: _locations.map((entry) {
          final (value, label, emoji) = entry;
          return ButtonSegment<String>(
            value: value,
            label: Text('$emoji $label'),
          );
        }).toList(),
        selected: {_selectedLocation},
        onSelectionChanged: (selected) {
          setState(() => _selectedLocation = selected.first);
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 13, fontFamily: 'Pretendard'),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: _categories.map((entry) {
          final (value, label, emoji) = entry;
          final isSelected =
              (_selectedCategory == null && value == 'all') ||
                  _selectedCategory == value;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              avatar: Text(emoji, style: const TextStyle(fontSize: 14)),
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory =
                      selected && value != 'all' ? value : null;
                });
              },
              labelStyle: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      emoji: _searchQuery.isNotEmpty ? '🔍' : '🧊',
      title: _searchQuery.isNotEmpty ? '검색 결과가 없어요' : '냉장고가 비어있어요',
      subtitle: _searchQuery.isNotEmpty
          ? '다른 키워드로 검색해 보세요'
          : '재료를 추가해서 맞춤 레시피를 받아보세요',
      actionText: _searchQuery.isEmpty ? '재료 추가하기' : null,
      onAction: _searchQuery.isEmpty ? _showAddIngredientSheet : null,
    );
  }

  Widget _buildIngredientCard(Ingredient ingredient) {
    final emoji = getCategoryEmoji(ingredient.category);
    final color = getExpiryColor(ingredient.expiryStatus);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          title: Text(
            ingredient.name,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '${ingredient.quantity} ${ingredient.unit} · ${ingredient.storageLocation.displayName}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          trailing: ExpiryBadge(
            status: ingredient.expiryStatus,
            dDayString: ingredient.dDayString,
          ),
          onTap: () => _showEditIngredientSheet(ingredient),
        ),
      ),
    );
  }

  void _showAddIngredientSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '재료 추가',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  children: [
                    Expanded(
                      child: _buildAddOption(
                        icon: Icons.camera_alt,
                        label: '사진으로\n인식',
                        onTap: () {
                          Navigator.pop(context);
                          this.context.push('/camera');
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _buildAddOption(
                        icon: Icons.edit,
                        label: '직접\n입력',
                        onTap: () async {
                          Navigator.pop(context);
                          final result =
                              await this.context.push<bool>('/ingredient/add');
                          if (result == true) _loadIngredients();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surfaceDim,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              Icon(icon, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditIngredientSheet(Ingredient ingredient) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('수정'),
              onTap: () async {
                Navigator.pop(sheetContext);
                final result = await context.push<bool>(
                  '/ingredient/edit',
                  extra: ingredient,
                );
                if (result == true) _loadIngredients();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title:
                  const Text('삭제', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(sheetContext);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('재료 삭제'),
                    content: Text('${ingredient.name}을(를) 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await _ingredientService.deleteIngredient(ingredient.id);
                  _loadIngredients();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${ingredient.name}이(가) 삭제되었습니다.'),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
