import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';

class FoodCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const FoodCard({super.key, required this.product, required this.onTap});

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
                          color: AppColors.textDarkGray,
                          fontSize: 13,
                        ),
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
                            'P',
                            product.protein!,
                            AppColors.proteinColor,
                          ),
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
