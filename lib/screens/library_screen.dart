
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_theme.dart';
import '../data/song_data.dart';
import '../services/favorites_service.dart';
import '../cubit/music_cubit.dart';
import 'player_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  Future<void> _playSong(BuildContext context, int index) async {
    await context.read<MusicCubit>().playSong(index);

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlayerScreen(),
      ),
    );
  }

  Widget _buildArtwork(String? image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 52,
        height: 52,
        child: image != null
            ? Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallback();
                },
              )
            : _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.darkRed,
      alignment: Alignment.center,
      child: const Icon(
        Icons.album_rounded,
        color: AppColors.primaryRed,
        size: 25,
      ),
    );
  }

  Widget _buildSongCard(
    BuildContext context,
    int index,
    Map<String, String> song,
  ) {
    final title = song['title'] ?? 'Unknown Track';
    final artist = song['artist'] ?? 'Unknown Artist';

    return BlocBuilder<MusicCubit, MusicState>(
      builder: (context, state) {
        final isCurrentSong = state.currentIndex == index;
        final isPlaying = isCurrentSong && state.isPlaying;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentSong
                  ? AppColors.primaryRed.withValues(alpha: 0.45)
                  : AppColors.darkRed.withValues(alpha: 0.25),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _playSong(context, index),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      child: Text(
                        '${index + 1}'.padLeft(2, '0'),
                        style: TextStyle(
                          color: isCurrentSong
                              ? AppColors.primaryRed
                              : AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    _buildArtwork(song['image']),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                          if (isCurrentSong) ...[
                            const SizedBox(height: 5),
                            const Text(
                              'NOW PLAYING',
                              style: TextStyle(
                                color: AppColors.primaryRed,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
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
                            size: 19,
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
                          isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          color: AppColors.primaryRed,
                          size: 29,
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        color: Color.fromARGB(255, 246, 6, 6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'YOUR COLLECTION',
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Your Library.',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'All your music in one place.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ALL TRACKS',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '${songs.length} TRACKS',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              if (songs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: Text(
                      'No songs available yet.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ...songs.asMap().entries.map((entry) {
                  return _buildSongCard(
                    context,
                    entry.key,
                    entry.value,
                  );
                }),

              const SizedBox(height: 15),

              const Center(
                child: Text(
                  'LYRA  •  YOUR MUSIC. YOUR WORLD.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
