
import 'package:flutter/material.dart';
import 'package:lyra/screens/favorites_screen.dart';
import 'package:lyra/screens/search_screen.dart';
import 'package:lyra/services/favorites_service.dart';

import 'home_screen.dart';
import '../widgets/bottom_navigation.dart';
import '../core/theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState(
    
  );
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  @override
void initState() {
  super.initState();
  FavoritesService.loadFavorites();
}

  final List<Widget> _pages = const [
  HomeScreen(),
  SearchScreen(),
   FavoritesScreen(),
  PlaceholderPage(title: 'Library'),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
