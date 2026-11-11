import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../data/song_data.dart';

class MusicState {
  final int? currentIndex;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;

  const MusicState({
    this.currentIndex,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  MusicState copyWith({
    int? currentIndex,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
  }) {
    return MusicState(
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class MusicCubit extends Cubit<MusicState> {
  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _advancing = false;
  bool _switching = false;
  int _requestId = 0;

  MusicCubit() : super(const MusicState()) {
    _subscriptions.addAll([
      _player.playerStateStream.listen(_onPlayerState),
      _player.positionStream.listen(_onPosition),
      _player.durationStream.listen(_onDuration),
    ]);
  }

  void _safeEmit(MusicState next) {
    if (!isClosed) emit(next);
  }

  void _onPlayerState(PlayerState playerState) {
    final processing = playerState.processingState;
    final completed = processing == ProcessingState.completed;

    _safeEmit(
      state.copyWith(
        isPlaying: completed ? false : playerState.playing,
        isLoading: _switching ||
            processing == ProcessingState.loading ||
            processing == ProcessingState.buffering,
        position: completed ? state.duration : state.position,
      ),
    );

    if (completed) {
      if (!_advancing) {
        _advancing = true;
        unawaited(playNext());
      }
    } else {
      _advancing = false;
    }
  }

  void _onPosition(Duration position) {
    if (_switching) return;

    final total = state.duration;
    if (total > Duration.zero && position > total) return;

    _safeEmit(state.copyWith(position: position));
  }

  void _onDuration(Duration? duration) {
    if (duration != null) {
      _safeEmit(state.copyWith(duration: duration));
    }
  }

  Future<void> playSong(int index) async {
    if (index < 0 || index >= songs.length) return;

    final assetPath = songs[index]['asset'];
    if (assetPath == null) return;

    final request = ++_requestId;
    _switching = true;

    _safeEmit(
      state.copyWith(
        currentIndex: index,
        isLoading: true,
        position: Duration.zero,
        duration: Duration.zero,
      ),
    );

    try {
      await _player.pause();
      if (request != _requestId || isClosed) return;

      final loadedDuration = await _player.setAsset(assetPath);
      if (request != _requestId || isClosed) return;

      _switching = false;

      _safeEmit(
        state.copyWith(
          isLoading: false,
          position: Duration.zero,
          duration: loadedDuration ?? _player.duration ?? Duration.zero,
        ),
      );

      unawaited(_player.play());
    } catch (error) {
      if (request == _requestId) {
        _switching = false;
        _safeEmit(state.copyWith(isPlaying: false, isLoading: false));
      }
    }
  }

  Future<void> togglePlayPause() async {
    if (state.currentIndex == null) return;

    if (_player.playing) {
      await _player.pause();
    } else {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }

      unawaited(_player.play());
    }
  }

  Future<void> playNext() async {
    if (songs.isEmpty) return;

    final start = state.currentIndex ?? -1;

    for (var step = 1; step <= songs.length; step++) {
      final candidate = (start + step) % songs.length;

      if (songs[candidate]['asset'] != null) {
        await playSong(candidate);
        return;
      }
    }
  }

  Future<void> playPrevious() async {
    if (songs.isEmpty) return;

    if (state.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }

    final start = state.currentIndex ?? 0;

    for (var step = 1; step <= songs.length; step++) {
      final candidate = (start - step + songs.length * 2) % songs.length;

      if (songs[candidate]['asset'] != null) {
        await playSong(candidate);
        return;
      }
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _player.dispose();
    return super.close();
  }
}