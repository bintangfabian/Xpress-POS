import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';

/// Reusable empty state widget with icon and message
class EmptyState extends StatelessWidget {
  final SvgGenImage? icon;
  final String message;
  final String? subtitle;
  final double iconSize;
  final Color iconColor;

  const EmptyState({
    super.key,
    this.icon,
    required this.message,
    this.subtitle,
    this.iconSize = 120,
    this.iconColor = AppColors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            icon!.svg(
              width: iconSize,
              height: iconSize,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          if (icon != null) const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              color: iconColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                color: iconColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
