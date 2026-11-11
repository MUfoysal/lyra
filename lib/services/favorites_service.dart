
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _key = 'favorite_songs';

  static final ValueNotifier<Set<String>> favorites =
      ValueNotifier<Set<String>>({});

  static Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final savedSongs = prefs.getStringList(_key) ?? [];

    favorites.value = savedSongs.toSet();
  }

  static Future<void> toggleFavorite(String title) async {
    final updatedFavorites = Set<String>.from(favorites.value);

    if (updatedFavorites.contains(title)) {
      updatedFavorites.remove(title);
    } else {
      updatedFavorites.add(title);
    }

    favorites.value = updatedFavorites;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      _key,
      updatedFavorites.toList(),
    );
  }
}
