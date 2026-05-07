import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Info card widget for displaying user information
class InfoCard extends StatelessWidget {
  final String title;
  final List<InfoItem> items;

  const InfoCard({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderLight),
          ...items.asMap().entries.map((entry) {
            final item = entry.value;
            return Column(
              children: [
                InkWell(
                  onTap: item.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (item.trailing != null)
                          item.trailing!
                        else if (item.value.isNotEmpty)
                          Text(
                            item.value,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (entry.key < items.length - 1)
                  const Divider(color: AppColors.borderLight),
              ],
            );
          }),
        ],
      ),
    );
  }
}

/// Info item for info card
class InfoItem {
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const InfoItem({
    required this.label,
    this.value = '',
    this.trailing,
    this.onTap,
  });
}
