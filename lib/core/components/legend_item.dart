import 'package:flutter/material.dart';

/// Reusable legend item widget for color indicators with labels
class LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double width;
  final double height;
  final double fontSize;

  const LegendItem({
    super.key,
    required this.color,
    required this.label,
    this.width = 75,
    this.height = 40,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
