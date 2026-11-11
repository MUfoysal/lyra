import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_theme.dart';
import '../cubit/music_cubit.dart';
import '../data/song_data.dart';
import '../services/favorites_service.dart';

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60);
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

void _openQueue(BuildContext context) {
  final cubit = context.read<MusicCubit>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: const _QueueSheet(),
    ),
  );
}

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MusicCubit, MusicState, int?>(
      selector: (state) => state.currentIndex,
      builder: (context, index) {
        final hasSong = index != null && index < songs.length;

        if (!hasSong) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              title: const Text('NOW PLAYING'),
            ),
            body: const Center(child: Text('No song selected')),
          );
        }

        return _PlayerBody(index: index);
      },
    );
  }
}

class _PlayerBody extends StatelessWidget {
  final int index;

  const _PlayerBody({required this.index});

  @override
  Widget build(BuildContext context) {
    final song = songs[index];
    final title = song['title'] ?? 'Unknown Title';
    final artist = song['artist'] ?? 'Unknown Artist';
    final image = song['image'];
    final cubit = context.read<MusicCubit>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(child: _Backdrop(index: index, image: image)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _GlassButton(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 26,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryRed
                                      .withValues(alpha: 0.8),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'NOW PLAYING',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      _GlassButton(
                        onTap: () => _openQueue(context),
                        child: const Icon(
                          Icons.queue_music_rounded,
                          size: 22,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final side = math.min(
                            math.min(constraints.maxWidth, constraints.maxHeight),
                            360.0,
                          );

                          return Center(
                            child: SizedBox(
                              width: side,
                              height: side,
                              child: BlocSelector<MusicCubit, MusicState, bool>(
                                selector: (state) => state.isPlaying,
                                builder: (context, playing) {
                                  return AnimatedScale(
                                    scale: playing ? 1.0 : 0.9,
                                    duration:
                                        const Duration(milliseconds: 450),
                                    curve: Curves.easeOutCubic,
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 450),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius:
                                            BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.08),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryRed
                                                .withValues(
                                              alpha: playing ? 0.38 : 0.14,
                                            ),
                                            blurRadius: playing ? 70 : 30,
                                            spreadRadius: playing ? 2 : 0,
                                            offset: const Offset(0, 24),
                                          ),
                                        ],
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 350),
                                        child: KeyedSubtree(
                                          key: ValueKey(index),
                                          child: _CoverImage(
                                            path: image,
                                            iconSize: 100,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ValueListenableBuilder<Set<String>>(
                        valueListenable: FavoritesService.favorites,
                        builder: (context, favorites, child) {
                          final isFavorite = favorites.contains(title);

                          return _GlassButton(
                            size: 48,
                            onTap: () =>
                                FavoritesService.toggleFavorite(title),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                key: ValueKey(isFavorite),
                                size: 24,
                                color: AppColors.primaryRed,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _ProgressBar(),
                  const SizedBox(height: 10),
                  BlocSelector<MusicCubit, MusicState, bool>(
                    selector: (state) => state.isPlaying,
                    builder: (context, playing) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: cubit.playPrevious,
                            icon: const Icon(Icons.skip_previous_rounded),
                            iconSize: 42,
                            color: AppColors.textPrimary,
                          ),
                          Material(
                            type: MaterialType.transparency,
                            child: Ink(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primaryRed,
                                    AppColors.darkRed,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryRed
                                        .withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: cubit.togglePlayPause,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (child, animation) =>
                                      ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                  child: Icon(
                                    playing
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    key: ValueKey(playing),
                                    size: 44,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: cubit.playNext,
                            icon: const Icon(Icons.skip_next_rounded),
                            iconSize: 42,
                            color: AppColors.textPrimary,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _UpNextCard(
                    index: index,
                    onTap: () => _openQueue(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  final int index;
  final String? image;

  const _Backdrop({required this.index, required this.image});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 700),
      child: Stack(
        key: ValueKey(index),
        fit: StackFit.expand,
        children: [
          if (image != null)
            ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Transform.scale(
                  scale: 1.4,
                  child: Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.5),
                radius: 0.95,
                colors: [
                  AppColors.primaryRed.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.5, 0.9],
                colors: [
                  AppColors.background.withValues(alpha: 0.3),
                  AppColors.background.withValues(alpha: 0.85),
                  AppColors.background,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String? path;
  final double iconSize;

  const _CoverImage({required this.path, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    final fallback = SizedBox.expand(
      child: Icon(
        Icons.album_rounded,
        color: AppColors.primaryRed,
        size: iconSize,
      ),
    );

    if (path == null) return fallback;

    return Image.asset(
      path!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}

class _GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double size;

  const _GlassButton({
    required this.child,
    required this.onTap,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.white.withValues(alpha: 0.07),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatefulWidget {
  const _ProgressBar();

  @override
  State<_ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<_ProgressBar> {
  double? _drag;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MusicCubit>();

    return BlocBuilder<MusicCubit, MusicState>(
      buildWhen: (previous, current) =>
          previous.position != current.position ||
          previous.duration != current.duration,
      builder: (context, state) {
        final total = state.duration.inMilliseconds.toDouble();
        final current = _drag ?? state.position.inMilliseconds.toDouble();
        final value = total > 0 ? current.clamp(0.0, total).toDouble() : 0.0;
        final shownPosition = Duration(milliseconds: value.round());

        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 5,
                trackShape: const RoundedRectSliderTrackShape(),
                activeTrackColor: AppColors.primaryRed,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
                thumbColor: Colors.white,
                overlayColor: AppColors.primaryRed.withValues(alpha: 0.2),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 7,
                  elevation: 4,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 18,
                ),
              ),
              child: Slider(
                min: 0,
                max: total > 0 ? total : 1,
                value: value,
                onChangeStart:
                    total > 0 ? (v) => setState(() => _drag = v) : null,
                onChanged:
                    total > 0 ? (v) => setState(() => _drag = v) : null,
                onChangeEnd: total > 0
                    ? (v) {
                        cubit.seek(Duration(milliseconds: v.round()));
                        setState(() => _drag = null);
                      }
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(shownPosition),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _formatDuration(state.duration),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _UpNextCard extends StatelessWidget {
  final int index;
  final VoidCallback onTap;

  const _UpNextCard({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final next = songs[(index + 1) % songs.length];
    final radius = BorderRadius.circular(20);

    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: radius,
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _CoverImage(path: next['image'], iconSize: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'UP NEXT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.8,
                          color: AppColors.primaryRed,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        next['title'] ?? 'Unknown Title',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        next['artist'] ?? 'Unknown Artist',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QueueSheet extends StatelessWidget {
  const _QueueSheet();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MusicCubit>();

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, controller) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.88),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'QUEUE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${songs.length} TRACKS',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BlocSelector<MusicCubit, MusicState, (int?, bool)>(
                      selector: (state) =>
                          (state.currentIndex, state.isPlaying),
                      builder: (context, data) {
                        final currentIndex = data.$1;
                        final playing = data.$2;

                        return ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: songs.length,
                          itemBuilder: (context, i) {
                            return _QueueTile(
                              song: songs[i],
                              isCurrent: i == currentIndex,
                              isPlaying: playing,
                              onTap: () => cubit.playSong(i),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QueueTile extends StatelessWidget {
  final Map<String, String> song;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onTap;

  const _QueueTile({
    required this.song,
    required this.isCurrent,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.primaryRed.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: radius,
            border: Border.all(
              color: isCurrent
                  ? AppColors.primaryRed.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _CoverImage(path: song['image'], iconSize: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song['title'] ?? 'Unknown Title',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isCurrent
                                ? AppColors.primaryRed
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          song['artist'] ?? 'Unknown Artist',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 24,
                    child: isCurrent
                        ? _EqualizerBars(animate: isPlaying)
                        : const Icon(
                            Icons.play_arrow_rounded,
                            size: 22,
                            color: AppColors.textSecondary,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EqualizerBars extends StatefulWidget {
  final bool animate;

  const _EqualizerBars({required this.animate});

  @override
  State<_EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<_EqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _EqualizerBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(3, (i) {
            final phase = _controller.value + i * 0.33;
            final wave = 0.5 + 0.5 * math.sin(2 * math.pi * phase);
            final height = widget.animate ? 6 + 14 * wave : 8.0;

            return Container(
              width: 4,
              height: height,
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}