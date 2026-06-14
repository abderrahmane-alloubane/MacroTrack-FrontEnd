import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/daily_summary.dart';
import '../services/api_service.dart';

class MealCard extends StatelessWidget {
  final String name;
  final int calories;
  final List<FoodItem> items;
  final VoidCallback onAdd;
  final Future<void> Function() onRefresh;
  final String dateKey;

  const MealCard({
    super.key,
    required this.name,
    required this.calories,
    required this.items,
    required this.onAdd,
    required this.onRefresh,
    required this.dateKey,
  });

  Future<void> _deleteItem(BuildContext context, String foodId) async {
    if (foodId.isEmpty) return;

    try {
      await ApiService.deleteMealEntry(foodId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Aliment retiré')));
      }
      await onRefresh();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Échec de la suppression : ${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '$calories',
                      style: TextStyle(
                        color: calories > 0
                            ? AppColors.primaryBlue
                            : AppColors.textDarkGray,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'cal',
                      style: TextStyle(
                        color: AppColors.textDarkGray,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onAdd,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Aucun aliment enregistré',
                  style: TextStyle(color: AppColors.textDarkGray, fontSize: 13),
                ),
              )
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.calories} cal',
                        style: TextStyle(
                          color: AppColors.textDarkGray,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: item.id.isNotEmpty
                            ? () => _deleteItem(context, item.id)
                            : null,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textDarkGray,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close, size: 16),
                            SizedBox(width: 2),
                            Text('Retirer', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
