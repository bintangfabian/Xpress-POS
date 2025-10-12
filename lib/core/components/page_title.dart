import 'package:flutter/material.dart';

/// Reusable page title widget for consistent styling across pages
class PageTitle extends StatelessWidget {
  final String title;
  final TextStyle? style;

  const PageTitle({
    super.key,
    required this.title,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: style ??
          const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
