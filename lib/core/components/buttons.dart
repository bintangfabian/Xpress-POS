import 'package:flutter/material.dart';
import '../constants/colors.dart';

enum ButtonStyleType { filled, outlined }

class Button extends StatelessWidget {
  // Filled
  const Button.filled({
    super.key,
    required this.onPressed,
    this.label, // ← opsional
    this.icon,
    this.style = ButtonStyleType.filled,
    this.color = AppColors.primary,
    this.textColor = Colors.white,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0.0,
    this.width = double.infinity,
    this.height = 50.0,
    this.borderRadius = 6.0,
    this.disabled = false,
    this.fontSize = 16.0,
    this.padding,
    this.fontWeight = FontWeight.w600,
  });

  // Outlined
  const Button.outlined({
    super.key,
    required this.onPressed,
    this.label, // ← opsional
    this.icon,
    this.style = ButtonStyleType.outlined,
    this.color = Colors.transparent,
    this.textColor = AppColors.primary,
    this.borderColor = AppColors.primary,
    this.borderWidth = 2.0,
    this.width = double.infinity,
    this.height = 50.0,
    this.borderRadius = 6.0,
    this.disabled = false,
    this.fontSize = 16.0,
    this.padding,
    this.fontWeight = FontWeight.w600,
  });

  final VoidCallback onPressed;
  final String? label;
  final Widget? icon;
  final ButtonStyleType style;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final double borderWidth;
  final double width;
  final double height;
  final double borderRadius;
  final bool disabled;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) icon!,
        if (icon != null && label != null) const SizedBox(width: 8),
        if (label != null)
          Flexible(
            child: Text(
              label!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: disabled ? Colors.grey : textColor,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
            ),
          ),
      ],
    );

    return SizedBox(
      width: width,
      height: height,
      child: style == ButtonStyleType.filled
          ? ElevatedButton(
              onPressed: disabled ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: shape,
                padding: padding,
                elevation: 0,
                side: borderWidth > 0
                    ? BorderSide(color: borderColor, width: borderWidth)
                    : BorderSide.none,
              ),
              child: child,
            )
          : OutlinedButton(
              onPressed: disabled ? null : onPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: color,
                side: BorderSide(color: borderColor, width: borderWidth),
                shape: shape,
                padding: padding,
              ),
              child: child,
            ),
    );
  }
}
