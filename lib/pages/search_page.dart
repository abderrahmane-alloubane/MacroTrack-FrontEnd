import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../widgets/food_card.dart';
import 'barcode_scanner_page.dart';

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

  int _currentPage = 0;
  static const _itemsPerPage = 10;

  int get _totalPages => (_results.length / _itemsPerPage).ceil();
  List<Product> get _pageItems {
    final start = _currentPage * _itemsPerPage;
    if (start >= _results.length) return [];
    final end = (start + _itemsPerPage).clamp(0, _results.length);
    return _results.sublist(start, end);
  }

  static const _mealTypes = ['Petit-déjeuner', 'Déjeuner', 'Dîner', 'Snacks'];

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
      final rawList = (parsed['products'] ??
              parsed['data'] ??
              parsed['results']) as List<dynamic>? ??
          [];
      final products = rawList
              .map((e) =>
                  Product.fromSearchJson(e as Map<String, dynamic>))
              .where((p) => p.id.isNotEmpty)
              .toList();
      if (mounted) {
        setState(() {
          _results = products;
          _currentPage = 0;
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
    final mealType = _selectedMealType ?? 'Petit-déjeuner';
    final defaultGrams = (product.ServingSize != 0.0 && product.ServingSize != null) ? product.ServingSize : 100; 
    final servingController = TextEditingController(
      text: defaultGrams?.toStringAsFixed(0),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final parsedServing = double.tryParse(servingController.text);
            final ratio = (parsedServing != null && parsedServing > 0)
                ? parsedServing / defaultGrams!
                : 1.0;
            final scaledCalories = (product.calories * ratio).round();
            final scaledCarbs = product.carbs != null ? product.carbs! * ratio : null;
            final scaledProtein = product.protein != null ? product.protein! * ratio : null;
            final scaledFat = product.fat != null ? product.fat! * ratio : null;

            return Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 32 + MediaQuery.of(ctx).viewInsets.bottom),
              child: SingleChildScrollView(
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
                        style: TextStyle(color: AppColors.textGray),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Pour ${product.servingSize ?? "${defaultGrams?.toStringAsFixed(0)}g"}',
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 100,
                          height: 36,
                          child: TextField(
                            controller: servingController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.surfaceBg,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              suffixText: 'g',
                              suffixStyle: TextStyle(
                                color: AppColors.textDarkGray,
                                fontSize: 13,
                              ),
                            ),
                            onChanged: (_) => setSheetState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _macroChips(scaledCalories, scaledCarbs, scaledProtein, scaledFat),
                    const SizedBox(height: 20),
                    Text(
                      'Ajouter à',
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
                                        TextStyle(color: AppColors.textWhite)),
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
                        onPressed: () {
                          product.servingGrams = (parsedServing ?? defaultGrams) as double?;
                          _addToDiary(
                            product, mealType, ctx,
                            calories: scaledCalories,
                            carbs: scaledCarbs,
                            protein: scaledProtein,
                            fat: scaledFat,
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter au journal'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _macroChips(int calories, double? carbs, double? protein, double? fat) {
    final items = [
      if (calories > 0) _chip('$calories cal', AppColors.calorieColor),
      if (carbs != null) _chip('G: ${carbs.toStringAsFixed(0)}g', AppColors.carbColor),
      if (protein != null) _chip('P: ${protein.toStringAsFixed(0)}g', AppColors.proteinColor),
      if (fat != null) _chip('L: ${fat.toStringAsFixed(0)}g', AppColors.fatColor),
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
    Product product, String mealType, BuildContext sheetContext, {
    int? calories,
    double? carbs,
    double? protein,
    double? fat,
  }) async {
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      await ApiService.addMealEntry(
        date: dateKey,
        mealType: mealType,
        foodName: product.name,
        calories: calories ?? product.calories,
        carbs: carbs ?? product.carbs,
        protein: protein ?? product.protein,
        fat: fat ?? product.fat,
      );
      if (sheetContext.mounted) Navigator.pop(sheetContext);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ajouté ${product.name} à $mealType'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context, true);
        } else {
          setState(() {
            _results = [];
            _hasSearched = false;
            _queryController.clear();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Échec d\'ajout : ${e.toString().replaceFirst('Exception: ', '')}'),
          ),
        );
      }
    }
  }

  Future<void> _scanBarcode() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );
    if (barcode == null || barcode.isEmpty || !mounted) return;

    setState(() {
      _isSearching = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      final raw = await ApiService.getProductDetails(barcode);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final product = Product.fromDetailsJson(json);
      if (mounted) {
        setState(() {
          _results = [product];
          _currentPage = 0;
          _isSearching = false;
        });
        _showAddSheet(product);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _queryController,
          style: TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            hintText: 'Rechercher des aliments...',
            hintStyle: TextStyle(color: AppColors.textDarkGray),
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
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
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
                style: TextStyle(color: AppColors.textGray),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _search,
                child: const Text('Réessayer'),
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
            Icon(Icons.search, size: 64, color: AppColors.textDarkGray),
            const SizedBox(height: 16),
            Text(
              'Rechercher un aliment',
              style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Tapez un nom d\'aliment et appuyez sur Rechercher',
              style: TextStyle(color: AppColors.textDarkGray, fontSize: 14),
            ),
            if (_selectedMealType != null) ...[
              const SizedBox(height: 4),
              Text(
                'Ajout à $_selectedMealType',
                style: TextStyle(
                    color: AppColors.primaryBlue, fontSize: 13),
              ),
            ],
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Text(
          'Aucun résultat trouvé',
          style: TextStyle(color: AppColors.textGray),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _pageItems.length,
            itemBuilder: (context, index) {
              final product = _pageItems[index];
              return FoodCard(
                product: product,
                onTap: () => _showAddSheet(product),
              );
            },
          ),
        ),
        if (_totalPages > 1)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              border: Border(
                top: BorderSide(color: AppColors.surfaceBg, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: _currentPage > 0
                      ? AppColors.textWhite
                      : AppColors.textDarkGray,
                  onPressed: _currentPage > 0
                      ? () => setState(() => _currentPage--)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  'Page ${_currentPage + 1} sur $_totalPages',
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: _currentPage < _totalPages - 1
                      ? AppColors.textWhite
                      : AppColors.textDarkGray,
                  onPressed: _currentPage < _totalPages - 1
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
