import 'package:flutter/material.dart';
import 'package:xpress/core/constants/colors.dart';

/// Reusable content title widget with shadow and rounded corners
class ContentTitle extends StatelessWidget {
  final String title;
  const ContentTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 66,
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              offset: const Offset(0, 5), // Only bottom shadow
              blurRadius: 2,
              spreadRadius: 0,
            ),
          ],
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
