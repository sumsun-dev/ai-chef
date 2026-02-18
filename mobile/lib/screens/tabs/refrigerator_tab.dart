import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/ingredient.dart';
import '../../services/ingredient_service.dart';

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
  String _sortBy = 'expiry'; // 'expiry', 'name', 'category'
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const _categories = [
    ('all', '전체'),
    ('vegetable', '채소'),
    ('fruit', '과일'),
    ('meat', '고기'),
    ('seafood', '해산물'),
    ('dairy', '유제품'),
    ('egg', '계란'),
    ('grain', '곡류'),
    ('seasoning', '양념'),
    ('other', '기타'),
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

    // 검색 필터
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // 위치 필터
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

    // 카테고리 필터
    if (_selectedCategory != null && _selectedCategory != 'all') {
      result = result.where((i) => i.category == _selectedCategory).toList();
    }

    // 정렬
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '재료 검색...',
                  border: InputBorder.none,
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
              PopupMenuItem(
                value: 'expiry',
                child: Row(
                  children: [
                    if (_sortBy == 'expiry')
                      Icon(Icons.check, size: 18, color: colorScheme.primary),
                    if (_sortBy == 'expiry') const SizedBox(width: 8),
                    const Text('유통기한순'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    if (_sortBy == 'name')
                      Icon(Icons.check, size: 18, color: colorScheme.primary),
                    if (_sortBy == 'name') const SizedBox(width: 8),
                    const Text('이름순'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'category',
                child: Row(
                  children: [
                    if (_sortBy == 'category')
                      Icon(Icons.check, size: 18, color: colorScheme.primary),
                    if (_sortBy == 'category') const SizedBox(width: 8),
                    const Text('카테고리순'),
                  ],
                ),
              ),
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
                  // 유통기한 임박 섹션
                  if (_expiringIngredients.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildExpiryAlert(),
                    ),

                  // 위치 필터
                  SliverToBoxAdapter(
                    child: _buildLocationFilter(colorScheme),
                  ),

                  // 카테고리 필터
                  SliverToBoxAdapter(
                    child: _buildCategoryFilter(colorScheme),
                  ),

                  // 재료 목록
                  if (_filteredIngredients.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
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

  Widget _buildExpiryAlert() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                '유통기한 임박 (${_expiringIngredients.length})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _expiringIngredients.take(5).map((i) {
              return Chip(
                label: Text('${i.name} (${i.dDayString})'),
                backgroundColor: Colors.orange.shade100,
                labelStyle: const TextStyle(fontSize: 12),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationFilter(ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('all', '전체', colorScheme),
          const SizedBox(width: 8),
          _buildFilterChip('fridge', '냉장', colorScheme),
          const SizedBox(width: 8),
          _buildFilterChip('freezer', '냉동', colorScheme),
          const SizedBox(width: 8),
          _buildFilterChip('pantry', '실온', colorScheme),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, ColorScheme colorScheme) {
    final isSelected = _selectedLocation == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedLocation = selected ? value : 'all';
        });
      },
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.primary,
    );
  }

  Widget _buildCategoryFilter(ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _categories.map((entry) {
          final (value, label) = entry;
          final isSelected =
              (_selectedCategory == null && value == 'all') ||
              _selectedCategory == value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected && value != 'all' ? value : null;
                });
              },
              selectedColor: colorScheme.secondaryContainer,
              checkmarkColor: colorScheme.secondary,
              labelStyle: TextStyle(fontSize: 12, color: isSelected ? colorScheme.secondary : null),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.kitchen,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? '검색 결과가 없어요' : '냉장고가 비어있어요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? '다른 키워드로 검색해 보세요'
                : '재료를 추가해서 맞춤 레시피를 받아보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientCard(Ingredient ingredient) {
    final expiryColor = _getExpiryColor(ingredient.expiryStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: expiryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              _getCategoryEmoji(ingredient.category),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          ingredient.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${ingredient.quantity} ${ingredient.unit} · ${ingredient.storageLocation.displayName}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: expiryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            ingredient.dDayString,
            style: TextStyle(
              color: expiryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () => _showEditIngredientSheet(ingredient),
      ),
    );
  }

  Color _getExpiryColor(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.expired:
        return Colors.red;
      case ExpiryStatus.critical:
        return Colors.orange;
      case ExpiryStatus.warning:
        return Colors.blue;
      case ExpiryStatus.safe:
        return Colors.green;
    }
  }

  String _getCategoryEmoji(String? category) {
    switch (category) {
      case 'vegetable':
        return '🥬';
      case 'fruit':
        return '🍎';
      case 'meat':
        return '🍖';
      case 'seafood':
        return '🐟';
      case 'dairy':
        return '🥛';
      case 'egg':
        return '🥚';
      case 'grain':
        return '🍚';
      case 'seasoning':
        return '🧂';
      default:
        return '🍽️';
    }
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
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '재료 추가',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
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
                    const SizedBox(width: 16),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey[700]),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditIngredientSheet(Ingredient ingredient) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(16),
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
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('삭제', style: TextStyle(color: Colors.red)),
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
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
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
