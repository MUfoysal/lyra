
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

import '../core/theme/app_theme.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<IconData> icons = const [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.favorite_rounded,
    Icons.library_music_rounded,
  ];

  final List<String> labels = const [
    'Home',
    'Search',
    'Favorites',
    'Library',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.darkRed.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: AnimatedBottomNavigationBar.builder(
        itemCount: icons.length,
        activeIndex: selectedIndex,
        onTap: onTap,
        backgroundColor: AppColors.surface,
        splashColor: AppColors.darkRed,
       
        height: 68,
        elevation: 0,
        leftCornerRadius: 22,
        rightCornerRadius: 22,
        gapLocation: GapLocation.none,
        tabBuilder: (index, isActive) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icons[index],
                size: 23,
                color: isActive
                    ? AppColors.primaryRed
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 5),
              Text(
                labels[index],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive
                      ? FontWeight.w800
                      : FontWeight.w500,
                  color: isActive
                      ? AppColors.primaryRed
                      : AppColors.textSecondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
