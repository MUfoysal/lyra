
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_theme.dart';
import '../data/song_data.dart';
import '../services/favorites_service.dart';
import '../cubit/music_cubit.dart';
import 'player_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Future<void> _playSong(
    BuildContext context,
    Map<String, String> song,
  ) async {
    final index = songs.indexWhere(
      (item) => item['id'] == song['id'],
    );

    if (index == -1) return;

    await context.read<MusicCubit>().playSong(index);

    if (!context.mounted) return;

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

  Widget _buildHeroCard(int totalSongs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7D101D),
            Color(0xFF3B0B12),
            Color(0xFF181313),
          ],
        ),
        border: Border.all(
          color: AppColors.primaryRed.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -5,
            top: -12,
            child: Icon(
              Icons.favorite_rounded,
              size: 115,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'YOUR PERSONAL COLLECTION',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                '$totalSongs',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                totalSongs == 1 ? 'Favorite Track' : 'Favorite Tracks',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'The music that feels like yours.',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSongCard(
    BuildContext context,
    Map<String, String> song,
  ) {
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
              onTap: () => _playSong(context, song),
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
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
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

                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        FavoritesService.toggleFavorite(title);
                      },
                      icon: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.primaryRed,
                        size: 20,
                      ),
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<Set<String>>(
          valueListenable: FavoritesService.favorites,
          builder: (context, favorites, child) {
            final favoriteSongs = songs.where((song) {
              return favorites.contains(song['title']);
            }).toList();

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
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
                                  Icons.favorite_rounded,
                                  color: AppColors.primaryRed,
                                  size: 23,
                                ),
                              ),
                            ),
                            const Text(
                              'L Y R A',
                              style: TextStyle(
                                fontFamily: 'BlackOpsOne',
                                fontSize: 25,
                                letterSpacing: 2,
                                color: AppColors.primaryRed,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        'YOUR COLLECTION',
                        style: TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Favorites',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),

                      const SizedBox(height: 7),

                      const Text(
                        'Your favorite sounds, all in one place.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 23),

                      _buildHeroCard(favoriteSongs.length),

                      const SizedBox(height: 27),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Tracks',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${favoriteSongs.length} SONGS',
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

                      if (favoriteSongs.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 65),
                          child: Column(
                            children: [
                              Container(
                                width: 85,
                                height: 85,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.darkRed,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.favorite_border_rounded,
                                  size: 38,
                                  color: AppColors.primaryRed,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'No favorites yet',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Add songs you love to your collection.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ]),
                  ),
                ),

                if (favoriteSongs.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildSongCard(
                            context,
                            favoriteSongs[index],
                          );
                        },
                        childCount: favoriteSongs.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
