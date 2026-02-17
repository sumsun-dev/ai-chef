import 'package:flutter/material.dart';
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
  String _selectedLocation = 'all'; // 'all', 'fridge', 'freezer', 'pantry'

  @override
  void initState() {
    super.initState();
    _loadIngredients();
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
    if (_selectedLocation == 'all') return _ingredients;
    return _ingredients.where((i) {
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

  List<Ingredient> get _expiringIngredients {
    return _ingredients.where((i) {
      if (i.expiryDate == null) return false;
      final daysUntil = i.expiryDate!.difference(DateTime.now()).inDays;
      return daysUntil <= 3 && daysUntil >= 0;
    }).toList()
      ..sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('냉장고'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 재료 검색
            },
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
          _buildFilterChip('fridge', '🧊 냉장', colorScheme),
          const SizedBox(width: 8),
          _buildFilterChip('freezer', '❄️ 냉동', colorScheme),
          const SizedBox(width: 8),
          _buildFilterChip('pantry', '📦 실온', colorScheme),
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
            '냉장고가 비어있어요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '재료를 추가해서 맞춤 레시피를 받아보세요',
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
            color: expiryColor.withOpacity(0.1),
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
        trailing: ingredient.expiryDate != null
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: expiryColor.withOpacity(0.1),
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
              )
            : null,
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
                          // TODO: 사진 인식
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAddOption(
                        icon: Icons.edit,
                        label: '직접\n입력',
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: 직접 입력 화면
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
    // TODO: 재료 수정/삭제 바텀시트
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('수정'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 수정 화면
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('삭제', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await _ingredientService.deleteIngredient(ingredient.id);
                _loadIngredients();
              },
            ),
          ],
        ),
      ),
    );
  }
}
