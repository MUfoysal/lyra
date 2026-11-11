
import 'package:flutter/material.dart';

import '../data/song_data.dart';
import '../core/theme/app_theme.dart';
import '../services/favorites_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 18, 20, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    SizedBox(
                      height: 50,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 43,
                              height: 43,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.darkRed,
                                ),
                              ),
                              child: const Icon(
                                Icons.graphic_eq_rounded,
                                color: AppColors.primaryRed,
                                size: 27,
                              ),
                            ),
                          ),

                          const Text(
                            'L Y R A',
                            style: TextStyle(
                              fontFamily: 'BlackOpsOne',
                              fontSize: 30,
                              letterSpacing: 2,
                              color: Color.fromARGB(255, 249, 10, 10),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 38),

                    // Welcome Section
                    const Text(
                      'YOUR MUSIC. YOUR WORLD.',
                      style: TextStyle(
                        color: AppColors.primaryRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Feel every beat.',
                      style: TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Your favorite sounds, all in one place.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Featured Track
                    Container(
                      width: double.infinity,
                      height: 205,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF8B111F),
                            Color(0xFF42121B),
                            Color(0xFF181313),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -15,
                            top: -20,
                            child: Icon(
                              Icons.album_rounded,
                              size: 145,
                              color: Colors.white.withValues(alpha: 0.07),
                            ),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'FEATURED TRACK',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Midnight Dreams',
                                          style: TextStyle(
                                            fontSize: 23,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Unknown Artist',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  ValueListenableBuilder<Set<String>>(
                                    valueListenable:
                                        FavoritesService.favorites,
                                    builder: (context, favorites, child) {
                                      final isFavorite = favorites.contains(
                                        'Midnight Dreams',
                                      );

                                      return IconButton(
                                        onPressed: () {
                                          FavoritesService.toggleFavorite(
                                            'Midnight Dreams',
                                          );
                                        },
                                        icon: Icon(
                                          isFavorite
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_border_rounded,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),

                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryRed,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      size: 34,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),

                    // Recently Added
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recently Added',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'VIEW ALL',
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 17),

                    SizedBox(
                      height: 157,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          final title = song['title']!;

                          return Container(
                            width: 132,
                            margin: const EdgeInsets.only(right: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 132,
                                      height: 105,
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.darkRed,
                                            AppColors.surface,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.album_rounded,
                                        size: 49,
                                        color: AppColors.primaryRed,
                                      ),
                                    ),

                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: ValueListenableBuilder<Set<String>>(
                                        valueListenable:
                                            FavoritesService.favorites,
                                        builder: (context, favorites, child) {
                                          final isFavorite =
                                              favorites.contains(title);

                                          return IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            onPressed: () {
                                              FavoritesService.toggleFavorite(
                                                title,
                                              );
                                            },
                                            icon: Icon(
                                              isFavorite
                                                  ? Icons.favorite_rounded
                                                  : Icons.favorite_border_rounded,
                                              color: isFavorite
                                                  ? AppColors.primaryRed
                                                  : Colors.white,
                                              size: 19,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 9),

                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // All Songs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'All Songs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${songs.length} TRACKS',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    ...songs.map((song) {
                      final title = song['title']!;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 3,
                          ),
                          leading: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.darkRed.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.music_note_rounded,
                              color: AppColors.primaryRed,
                            ),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            song['artist']!,
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: ValueListenableBuilder<Set<String>>(
                            valueListenable: FavoritesService.favorites,
                            builder: (context, favorites, child) {
                              final isFavorite = favorites.contains(title);

                              return IconButton(
                                onPressed: () {
                                  FavoritesService.toggleFavorite(title);
                                },
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: isFavorite
                                      ? AppColors.primaryRed
                                      : AppColors.textSecondary,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Mini Player
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(
                    color: AppColors.darkRed.withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: AppColors.darkRed,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.album_rounded,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nothing Playing',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Select a song to play',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow_rounded),
                    color: AppColors.primaryRed,
                    iconSize: 29,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
