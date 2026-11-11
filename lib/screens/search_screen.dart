
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_theme.dart';
import '../data/song_data.dart';
import '../services/favorites_service.dart';
import '../cubit/music_cubit.dart';
import 'player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  String searchQuery = '';

  List<Map<String, String>> get filteredSongs {
    return songs.where((song) {
      final title = song['title']!.toLowerCase();
      final artist = song['artist']!.toLowerCase();
      final query = searchQuery.toLowerCase();

      return title.contains(query) || artist.contains(query);
    }).toList();
  }

  Future<void> _playSong(Map<String, String> song) async {
    final index = songs.indexWhere(
      (item) => item['id'] == song['id'],
    );

    if (index == -1) return;

    await context.read<MusicCubit>().playSong(index);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlayerScreen(),
      ),
    );
  }

  Widget _buildFallback(double size) {
    return Container(
      color: AppColors.darkRed,
      alignment: Alignment.center,
      child: Icon(
        Icons.album_rounded,
        size: size * 0.45,
        color: AppColors.primaryRed,
      ),
    );
  }

  Widget _buildAlbumCover(String? image, {double size = 58}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: SizedBox(
        width: size,
        height: size,
        child: image != null
            ? Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallback(size);
                },
              )
            : _buildFallback(size),
      ),
    );
  }

  Widget _buildSongCard(Map<String, String> song) {
    final title = song['title']!;
    final artist = song['artist']!;

    final songIndex = songs.indexWhere(
      (item) => item['id'] == song['id'],
    );

    return BlocBuilder<MusicCubit, MusicState>(
      builder: (context, musicState) {
        final isCurrentSong = musicState.currentIndex == songIndex;

        return Container(
          margin: const EdgeInsets.only(bottom: 11),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: isCurrentSong
                  ? AppColors.primaryRed.withValues(alpha: 0.5)
                  : AppColors.darkRed.withValues(alpha: 0.35),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(17),
            child: InkWell(
              borderRadius: BorderRadius.circular(17),
              onTap: () => _playSong(song),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    _buildAlbumCover(song['image']),

                    const SizedBox(width: 13),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (isCurrentSong) ...[
                            const SizedBox(height: 6),
                            const Text(
                              'CURRENTLY PLAYING',
                              style: TextStyle(
                                color: AppColors.primaryRed,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    ValueListenableBuilder<Set<String>>(
                      valueListenable: FavoritesService.favorites,
                      builder: (context, favorites, child) {
                        final isFavorite = favorites.contains(title);

                        return IconButton(
                          visualDensity: VisualDensity.compact,
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
                            size: 20,
                          ),
                        );
                      },
                    ),

                    if (isCurrentSong)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          context.read<MusicCubit>().togglePlayPause();
                        },
                        icon: Icon(
                          musicState.isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          color: AppColors.primaryRed,
                          size: 32,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = filteredSongs;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 48,
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
                        color: AppColors.primaryRed,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              color: AppColors.primaryRed,
                              size: 12,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'OFFLINE',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 38),

              const Text(
                'YOUR MUSIC. YOUR WORLD.',
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.5,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Find your sound.',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Every track has its own story.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 27),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: AppColors.darkRed.withValues(alpha: 0.55),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryRed.withValues(alpha: 0.04),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.trim();
                    });
                  },
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search songs or artists...',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primaryRed,
                      size: 22,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                searchQuery = '';
                              });
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 17,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    searchQuery.isEmpty ? 'All Tracks' : 'Search Results',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${results.length} TRACKS',
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              if (results.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 45),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.music_off_rounded,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 14),
                      Text(
                        'No songs found',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Try another song or artist name.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...results.map(_buildSongCard),
            ],
          ),
        ),
      ),
    );
  }
}
