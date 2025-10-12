import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> tabTitles;
  final int initialTabIndex;
  final List<Widget> tabViews;

  const CustomTabBar({
    super.key,
    required this.tabTitles,
    required this.initialTabIndex,
    required this.tabViews,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  late int _selectedIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final header = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              widget.tabTitles.length,
              (index) => GestureDetector(
                onTap: () => _onTabSelected(index),
                child: Container(
                  margin: const EdgeInsets.only(right: 32),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 3,
                        color: _selectedIndex == index
                            ? AppColors.primary
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Text(
                    widget.tabTitles[index],
                    style: TextStyle(
                      color: _selectedIndex == index
                          ? AppColors.primary
                          : AppColors.black,
                      fontWeight: _selectedIndex == index
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final pageView = PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          children: widget.tabViews,
        );

        // Jika memiliki tinggi terbatas (mis. di dalam Expanded), gunakan Expanded
        // Jika tidak (mis. di dalam SingleChildScrollView), berikan tinggi eksplisit longgar
        final bool boundedHeight = constraints.hasBoundedHeight;
        final Widget content = boundedHeight
            ? Expanded(child: pageView)
            : SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: pageView,
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: boundedHeight ? MainAxisSize.max : MainAxisSize.min,
          children: [
            header,
            const SizedBox(height: 8),
            content,
          ],
        );
      },
    );
  }
}
