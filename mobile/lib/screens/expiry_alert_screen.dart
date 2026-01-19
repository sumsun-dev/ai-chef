import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/ingredient.dart';
import '../services/ingredient_service.dart';

/// 유통기한 알림 상세 화면
class ExpiryAlertScreen extends StatefulWidget {
  final ExpiryStatus? initialFilter;

  const ExpiryAlertScreen({
    super.key,
    this.initialFilter,
  });

  @override
  State<ExpiryAlertScreen> createState() => _ExpiryAlertScreenState();
}

class _ExpiryAlertScreenState extends State<ExpiryAlertScreen>
    with SingleTickerProviderStateMixin {
  final IngredientService _ingredientService = IngredientService();
  late TabController _tabController;

  ExpiryIngredientGroup? _expiryGroup;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 초기 탭 설정
    if (widget.initialFilter != null) {
      switch (widget.initialFilter!) {
        case ExpiryStatus.expired:
          _tabController.index = 0;
          break;
        case ExpiryStatus.critical:
          _tabController.index = 1;
          break;
        case ExpiryStatus.warning:
          _tabController.index = 2;
          break;
        case ExpiryStatus.safe:
          break;
      }
    }

    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final expiryGroup = await _ingredientService.getExpiryIngredientGroup();
      setState(() {
        _expiryGroup = expiryGroup;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteIngredient(Ingredient ingredient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('재료 삭제'),
        content: Text('${ingredient.name}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _ingredientService.deleteIngredient(ingredient.id);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${ingredient.name}이(가) 삭제되었습니다.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('유통기한 알림'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: _buildTabLabel(
                '만료됨',
                _expiryGroup?.expiredCount ?? 0,
                Colors.red,
              ),
            ),
            Tab(
              child: _buildTabLabel(
                '3일 이내',
                _expiryGroup?.criticalCount ?? 0,
                Colors.orange,
              ),
            ),
            Tab(
              child: _buildTabLabel(
                '7일 이내',
                _expiryGroup?.warningCount ?? 0,
                Colors.blue,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('오류가 발생했습니다'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildIngredientList(
                        _expiryGroup?.expiredItems ?? [],
                        ExpiryStatus.expired,
                      ),
                      _buildIngredientList(
                        _expiryGroup?.criticalItems ?? [],
                        ExpiryStatus.critical,
                      ),
                      _buildIngredientList(
                        _expiryGroup?.warningItems ?? [],
                        ExpiryStatus.warning,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTabLabel(String text, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIngredientList(
      List<Ingredient> ingredients, ExpiryStatus status) {
    if (ingredients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStatusIcon(status),
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(status),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return _buildIngredientCard(ingredient);
      },
    );
  }

  IconData _getStatusIcon(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.expired:
        return Icons.warning_amber;
      case ExpiryStatus.critical:
        return Icons.access_time;
      case ExpiryStatus.warning:
        return Icons.info_outline;
      case ExpiryStatus.safe:
        return Icons.check_circle_outline;
    }
  }

  String _getEmptyMessage(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.expired:
        return '유통기한이 지난 재료가 없습니다';
      case ExpiryStatus.critical:
        return '3일 이내 만료되는 재료가 없습니다';
      case ExpiryStatus.warning:
        return '7일 이내 만료되는 재료가 없습니다';
      case ExpiryStatus.safe:
        return '모든 재료가 안전합니다';
    }
  }

  Color _getStatusColor(ExpiryStatus status) {
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

  Widget _buildIngredientCard(Ingredient ingredient) {
    final color = _getStatusColor(ingredient.expiryStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // D-day 배지
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    ingredient.dDayString,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 재료명
                Expanded(
                  child: Text(
                    ingredient.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 삭제 버튼
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteIngredient(ingredient),
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 상세 정보
            Row(
              children: [
                _buildInfoChip(
                  Icons.category_outlined,
                  ingredient.category,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.scale_outlined,
                  '${ingredient.quantity} ${ingredient.unit}',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  _getStorageIcon(ingredient.storageLocation),
                  ingredient.storageLocation.displayName,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 유통기한
            Row(
              children: [
                Icon(Icons.event_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '유통기한: ${_formatDate(ingredient.expiryDate)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (ingredient.memo != null && ingredient.memo!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ingredient.memo!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStorageIcon(StorageLocation location) {
    switch (location) {
      case StorageLocation.refrigerated:
        return Icons.kitchen_outlined;
      case StorageLocation.frozen:
        return Icons.ac_unit;
      case StorageLocation.roomTemp:
        return Icons.home_outlined;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}
