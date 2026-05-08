import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/product.dart';

class SearchPage extends StatefulWidget {
  final String? initialMealType;

  const SearchPage({super.key, this.initialMealType});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _queryController = TextEditingController();
  List<Product> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _error;
  String? _selectedMealType;

  static const _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.initialMealType;
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      final raw = await ApiService.searchProducts(query);
      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      final products = (parsed['products'] as List<dynamic>?)
              ?.map((e) =>
                  Product.fromSearchJson(e as Map<String, dynamic>))
              .where((p) => p.id.isNotEmpty)
              .toList() ??
          [];
      if (mounted) {
        setState(() {
          _results = products;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isSearching = false;
        });
      }
    }
  }

  void _showAddSheet(Product product) {
    final mealType = _selectedMealType ?? 'Breakfast';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textDarkGray,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                  ),
                  if (product.brand != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.brand!,
                      style: const TextStyle(color: AppColors.textGray),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _macroChips(product),
                  const SizedBox(height: 20),
                  const Text(
                    'Add to',
                    style: TextStyle(
                        color: AppColors.textGray,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: mealType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: AppColors.surfaceBg,
                    items: _mealTypes
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t,
                                  style:
                                      const TextStyle(color: AppColors.textWhite)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setSheetState(() => _selectedMealType = v);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _addToDiary(product, mealType, ctx),
                      icon: const Icon(Icons.add),
                      label: const Text('Add to Diary'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _macroChips(Product p) {
    final items = [
      if (p.calories > 0) _chip('${p.calories} cal', AppColors.calorieColor),
      if (p.carbs != null) _chip('C: ${p.carbs!.toStringAsFixed(0)}g', AppColors.carbColor),
      if (p.protein != null) _chip('P: ${p.protein!.toStringAsFixed(0)}g', AppColors.proteinColor),
      if (p.fat != null) _chip('F: ${p.fat!.toStringAsFixed(0)}g', AppColors.fatColor),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items,
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Future<void> _addToDiary(
      Product product, String mealType, BuildContext sheetContext) async {
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      await ApiService.addMealEntry(
        date: dateKey,
        mealType: mealType,
        foodName: product.name,
        calories: product.calories,
        carbs: product.carbs,
        protein: product.protein,
        fat: product.fat,
      );
      if (sheetContext.mounted) Navigator.pop(sheetContext);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${product.name} to $mealType'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to add: ${e.toString().replaceFirst('Exception: ', '')}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _queryController,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            hintText: 'Search foods...',
            hintStyle: const TextStyle(color: AppColors.textDarkGray),
            filled: true,
            fillColor: AppColors.surfaceBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _search,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.errorRed),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textGray),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _search,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search, size: 64, color: AppColors.textDarkGray),
            const SizedBox(height: 16),
            const Text(
              'Search for any food',
              style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Type a food name and tap search',
              style: TextStyle(color: AppColors.textDarkGray, fontSize: 14),
            ),
            if (_selectedMealType != null) ...[
              const SizedBox(height: 4),
              Text(
                'Adding to $_selectedMealType',
                style: const TextStyle(
                    color: AppColors.primaryBlue, fontSize: 13),
              ),
            ],
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(color: AppColors.textGray),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final product = _results[index];
        return _FoodCard(
          product: product,
          onTap: () => _showAddSheet(product),
        );
      },
    );
  }
}

class _FoodCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _FoodCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textWhite,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.brand != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.brand!,
                        style: const TextStyle(
                            color: AppColors.textDarkGray, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (product.calories > 0)
                          Text(
                            '${product.calories} cal',
                            style: const TextStyle(
                              color: AppColors.calorieColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        if (product.carbs != null) ...[
                          const SizedBox(width: 12),
                          _miniMacro('C', product.carbs!, AppColors.carbColor),
                        ],
                        if (product.protein != null) ...[
                          const SizedBox(width: 8),
                          _miniMacro(
                              'P', product.protein!, AppColors.proteinColor),
                        ],
                        if (product.fat != null) ...[
                          const SizedBox(width: 8),
                          _miniMacro('F', product.fat!, AppColors.fatColor),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textDarkGray),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniMacro(String label, double value, Color color) {
    return Text(
      '$label:${value.toStringAsFixed(0)}g',
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
    );
  }
}
