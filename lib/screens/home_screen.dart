
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/song_data.dart';
import '../core/theme/app_theme.dart';
import '../services/favorites_service.dart';
import '../cubit/music_cubit.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  Timer? _autoSlideTimer;

  int _currentIndex = 0;
  late final int _initialPage;

  @override
  void initState() {
    super.initState();

    _initialPage = songs.isEmpty ? 0 : songs.length * 1000;
    _pageController = PageController(initialPage: _initialPage);

    _scheduleAutoSlide();
  }

  void _scheduleAutoSlide() {
    _autoSlideTimer?.cancel();

    if (songs.length <= 1) return;

    _autoSlideTimer = Timer(
      const Duration(seconds: 5),
      () {
        if (!_pageController.hasClients) {
          _scheduleAutoSlide();
          return;
        }

        final currentPage =
            (_pageController.page ?? _initialPage.toDouble()).round();

        _pageController.animateToPage(
          currentPage + 1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      },
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;

    if (notification is ScrollStartNotification) {
      _autoSlideTimer?.cancel();
    }

    if (notification is ScrollEndNotification) {
      _scheduleAutoSlide();
    }

    return false;
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentIndex = page % songs.length;
    });
  }

  void _selectPage(int index) {
    if (!_pageController.hasClients) return;

    final currentPage =
        (_pageController.page ?? _initialPage.toDouble()).round();

    final targetPage = currentPage - _currentIndex + index;

    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _playSong(int index) async {
    await context.read<MusicCubit>().playSong(index);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlayerScreen(),
      ),
    );
  }

  Future<void> _toggleSong(int index) async {
    final cubit = context.read<MusicCubit>();

    if (cubit.state.currentIndex == index) {
      await cubit.togglePlayPause();
    } else {
      await _playSong(index);
    }
  }

  Widget _buildPlayButton(
    int index, {
    double size = 43,
    double iconSize = 29,
  }) {
    return BlocBuilder<MusicCubit, MusicState>(
      builder: (context, state) {
        final isCurrentSong = state.currentIndex == index;
        final isPlaying = isCurrentSong && state.isPlaying;
        final isLoading = isCurrentSong && state.isLoading;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _toggleSong(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryRed.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: iconSize * 0.65,
                      height: iconSize * 0.65,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: iconSize,
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumCover(
    String? image, {
    double? width,
    double? height,
    double iconSize = 50,
    double radius = 15,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: image != null
            ? Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildCoverFallback(iconSize);
                },
              )
            : _buildCoverFallback(iconSize),
      ),
    );
  }

  Widget _buildCoverFallback(double iconSize) {
    return Container(
      color: AppColors.darkRed,
      alignment: Alignment.center,
      child: Icon(
        Icons.album_rounded,
        size: iconSize,
        color: AppColors.primaryRed,
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.primaryRed,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.darkRed.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppColors.primaryRed,
              size: 22,
            ),
            const SizedBox(height: 13),
            Text(
              value,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(int index) {
    final song = songs[index];
    final title = song['title']!;
    final artist = song['artist']!;
    final image = song['image'];

    return GestureDetector(
      onTap: () => _playSong(index),
      child: Container(
        margin: const EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(
            color: AppColors.darkRed.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryRed.withValues(alpha: 0.12),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null)
              Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildCoverFallback(65);
                },
              )
            else
              _buildCoverFallback(65),

            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.25, 0.55, 1.0],
                ),
              ),
            ),

            Positioned(
              top: 15,
              left: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.graphic_eq_rounded,
                      color: AppColors.primaryRed,
                      size: 13,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'FEATURED TRACK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 17,
              right: 15,
              bottom: 15,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  ValueListenableBuilder<Set<String>>(
                    valueListenable: FavoritesService.favorites,
                    builder: (context, favorites, child) {
                      final isFavorite = favorites.contains(title);

                      return GestureDetector(
                        onTap: () {
                          FavoritesService.toggleFavorite(title);
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite
                                ? AppColors.primaryRed
                                : Colors.white,
                            size: 19,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 8),

                  _buildPlayButton(index),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyAddedCard(int index) {
    final song = songs[index];
    final title = song['title']!;
    final artist = song['artist']!;
    final image = song['image'];

    return GestureDetector(
      onTap: () => _playSong(index),
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 13),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.darkRed.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _buildAlbumCover(
                  image,
                  width: double.infinity,
                  height: 112,
                  iconSize: 45,
                  radius: 13,
                ),

                Positioned(
                  top: 5,
                  right: 5,
                  child: ValueListenableBuilder<Set<String>>(
                    valueListenable: FavoritesService.favorites,
                    builder: (context, favorites, child) {
                      final isFavorite = favorites.contains(title);

                      return GestureDetector(
                        onTap: () {
                          FavoritesService.toggleFavorite(title);
                        },
                        child: Container(
                          width: 29,
                          height: 29,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite
                                ? AppColors.primaryRed
                                : Colors.white,
                            size: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Positioned(
                  bottom: 6,
                  right: 6,
                  child: _buildPlayButton(
                    index,
                    size: 29,
                    iconSize: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recentSongs = songs.take(5).toList();

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
                                letterSpacing: 0.5,
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
                'Feel every beat.',
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

              const SizedBox(height: 30),

              _buildSectionTitle('Featured Track', 'HANDPICKED FOR YOU'),

              const SizedBox(height: 14),

              SizedBox(
                height: 210,
                child: songs.isEmpty
                    ? const Center(
                        child: Text('No songs available'),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: _handleScrollNotification,
                        child: PageView.builder(
                          controller: _pageController,
                          physics: const PageScrollPhysics(),
                          onPageChanged: _onPageChanged,
                          itemBuilder: (context, page) {
                            final index = page % songs.length;
                            return _buildFeaturedCard(index);
                          },
                        ),
                      ),
              ),

              const SizedBox(height: 15),

              if (songs.isNotEmpty)
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      songs.length,
                      (index) {
                        final isActive = _currentIndex == index;

                        return GestureDetector(
                          onTap: () => _selectPage(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 22 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primaryRed
                                  : AppColors.darkRed,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              _buildSectionTitle('Your Collection', 'YOUR MUSIC LIBRARY'),

              const SizedBox(height: 14),

              Row(
                children: [
                  _buildStatCard(
                    icon: Icons.library_music_rounded,
                    label: 'TOTAL TRACKS',
                    value: '${songs.length}',
                  ),

                  const SizedBox(width: 12),

                  ValueListenableBuilder<Set<String>>(
                    valueListenable: FavoritesService.favorites,
                    builder: (context, favorites, child) {
                      return _buildStatCard(
                        icon: Icons.favorite_rounded,
                        label: 'FAVORITES',
                        value: '${favorites.length}',
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              _buildSectionTitle(
                'Recently Added',
                '${recentSongs.length} TRACKS',
              ),

              const SizedBox(height: 14),

              if (recentSongs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 25),
                  child: Center(
                    child: Text(
                      'No songs added yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 183,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentSongs.length,
                    itemBuilder: (context, index) {
                      return _buildRecentlyAddedCard(index);
                    },
                  ),
                ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
