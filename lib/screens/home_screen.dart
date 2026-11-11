
import 'dart:async';

import 'package:flutter/material.dart';

import '../data/song_data.dart';
import '../core/theme/app_theme.dart';
import '../services/favorites_service.dart';

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

  void _playSong(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Playback system is not connected yet.'),
        duration: Duration(seconds: 2),
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
                              color: AppColors.primaryRed,
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

                    SizedBox(
                      height: 205,
                      child: songs.isEmpty
                          ? const Center(
                              child: Text('No songs available'),
                            )
                          : NotificationListener<ScrollNotification>(
                              onNotification:
                                  _handleScrollNotification,
                              child: PageView.builder(
                                controller: _pageController,
                                physics: const PageScrollPhysics(),
                                onPageChanged: _onPageChanged,
                                itemBuilder: (context, page) {
                                  final song =
                                      songs[page % songs.length];

                                  final title = song['title']!;
                                  final artist = song['artist']!;

                                  return GestureDetector(
                                    onTap: () => _playSong(title),
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                        right: 5,
                                      ),
                                      padding: const EdgeInsets.all(22),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(22),
                                        gradient:
                                            const LinearGradient(
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
                                              color:
                                                  Colors.white.withValues(
                                                alpha: 0.07,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                  horizontal: 10,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(
                                                    alpha: 0.12,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(20),
                                                ),
                                                child: const Text(
                                                  'FEATURED TRACK',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          title,
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 21,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        Text(
                                                          artist,
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors
                                                                .white70,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  ValueListenableBuilder<
                                                      Set<String>>(
                                                    valueListenable:
                                                        FavoritesService
                                                            .favorites,
                                                    builder: (
                                                      context,
                                                      favorites,
                                                      child,
                                                    ) {
                                                      final isFavorite =
                                                          favorites
                                                              .contains(
                                                        title,
                                                      );

                                                      return IconButton(
                                                        onPressed: () {
                                                          FavoritesService
                                                              .toggleFavorite(
                                                            title,
                                                          );
                                                        },
                                                        icon: Icon(
                                                          isFavorite
                                                              ? Icons
                                                                  .favorite_rounded
                                                              : Icons
                                                                  .favorite_border_rounded,
                                                          color:
                                                              Colors.white,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  Container(
                                                    width: 48,
                                                    height: 48,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: AppColors
                                                          .primaryRed,
                                                      shape:
                                                          BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons
                                                          .play_arrow_rounded,
                                                      size: 32,
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
                                  );
                                },
                              ),
                            ),
                    ),

                    const SizedBox(height: 14),

                    if (songs.isNotEmpty)
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            songs.length,
                            (index) {
                              final isActive =
                                  _currentIndex == index;

                              return GestureDetector(
                                onTap: () => _selectPage(index),
                                child: AnimatedContainer(
                                  duration: const Duration(
                                    milliseconds: 200,
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: isActive ? 22 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.primaryRed
                                        : AppColors.darkRed,
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recently Added',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'NEW TRACKS',
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
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 132,
                                      height: 105,
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        gradient:
                                            const LinearGradient(
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
                                      child:
                                          ValueListenableBuilder<
                                              Set<String>>(
                                        valueListenable:
                                            FavoritesService.favorites,
                                        builder: (
                                          context,
                                          favorites,
                                          child,
                                        ) {
                                          final isFavorite =
                                              favorites.contains(title);

                                          return IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            onPressed: () {
                                              FavoritesService
                                                  .toggleFavorite(title);
                                            },
                                            icon: Icon(
                                              isFavorite
                                                  ? Icons
                                                      .favorite_rounded
                                                  : Icons
                                                      .favorite_border_rounded,
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
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(
                    color: AppColors.darkRed.withValues(
                      alpha: 0.4,
                    ),
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
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
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                    ),
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
