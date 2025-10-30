import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';

/// Reusable menu tile widget for Settings, Sales, and other similar pages
class MenuTile extends StatelessWidget {
  final SvgGenImage icon;
  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;
  final bool isLogout;

  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color defaultColor = isLogout ? AppColors.danger : Colors.black;
    final Color iconColor = active ? AppColors.primary : defaultColor;
    final Color textColor = active ? AppColors.primary : defaultColor;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: active ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            icon.svg(
              height: 32,
              width: 32,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
