import 'package:flutter/material.dart';
import 'package:xpress/core/constants/colors.dart';

class LoadingListPlaceholder extends StatelessWidget {
  final ScrollController controller;
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry padding;

  const LoadingListPlaceholder({
    super.key,
    required this.controller,
    this.itemCount = 6,
    this.itemHeight = 72,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final listView = ListView.separated(
      controller: controller,
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (context, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _AnimatedPlaceholderRow(height: itemHeight),
    );

    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      child: listView,
    );
  }
}

class _AnimatedPlaceholderRow extends StatefulWidget {
  final double height;

  const _AnimatedPlaceholderRow({required this.height});

  @override
  State<_AnimatedPlaceholderRow> createState() =>
      _AnimatedPlaceholderRowState();
}

class _AnimatedPlaceholderRowState extends State<_AnimatedPlaceholderRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = AppColors.primary.withAlpha((0.06 * 255).round());
    final highlightColor = AppColors.primary.withAlpha((0.18 * 255).round());
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Color.lerp(baseColor, highlightColor, _controller.value),
          ),
        );
      },
    );
  }
}
