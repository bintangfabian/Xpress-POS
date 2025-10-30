import 'package:flutter/material.dart';

import '../../../core/components/spaces.dart';
import '../../../core/constants/colors.dart';



class AddData extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const AddData({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: ShapeDecoration(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: AppColors.greyLightActive),
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withAlpha((0.06 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.black, size: 36),
            const SpaceHeight(8.0),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
