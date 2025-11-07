import 'package:flutter/material.dart';
import '../../../core/utils/app_styles.dart';

class DynamicTabBar extends StatefulWidget {
  final TabController controller;
  final List<String> tabs;

  const DynamicTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  State<DynamicTabBar> createState() => _DynamicTabBarState();
}

class _DynamicTabBarState extends State<DynamicTabBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.tabs.length, (index) {
          final isSelected = widget.controller.index == index;
          return Flexible(
            flex: isSelected ? 2 : 1,
            child: GestureDetector(
              onTap: () => widget.controller.animateTo(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.tabs[index],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: isSelected ? 16 : 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppStyles.primaryColor
                                : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // Indicator line that follows text width
                    Container(
                      height: 2,
                      width: isSelected ? _calculateTextWidth(
                        widget.tabs[index],
                        TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ) : 0,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppStyles.primaryColor
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  double _calculateTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width; // Exact text width
  }
}
