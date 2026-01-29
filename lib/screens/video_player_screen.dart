import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/video_controller.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final int index;

  const VideoPlayerScreen({super.key, required this.index});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _showControls = true;
  bool _isFullScreen = false;
  Timer? _hideControlsTimer;
  final controller = Get.find<VideoController>();
  bool _isDisposed = false;

  // Skip overlay
  int _skipSeconds = 0;
  AnimationController? _skipAnimController;
  Animation<double>? _skipAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();

    _skipAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _skipAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_skipAnimController!);
  }

  Future<void> _initializeVideo() async {
    await controller.initializePlayer(widget.index);
    if (_isDisposed) return;

    _videoController = controller.player;

    if (_videoController != null && _videoController!.value.isInitialized) {
      try {
        await _videoController!.play();
      } catch (_) {}
    }

    if (!_isDisposed) setState(() {});
    _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showControls && !_isDisposed) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    if (_isDisposed) return;
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideControlsTimer();
  }

  Future<void> _toggleFullScreen() async {
    if (_isDisposed) return;
    if (_isFullScreen) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      await Future.delayed(const Duration(milliseconds: 200));
      if (!_isDisposed) setState(() => _isFullScreen = false);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      if (!_isDisposed) setState(() => _isFullScreen = true);
    }
    _startHideControlsTimer();
  }

  void _skip(int seconds) {
    if (_isDisposed ||
        _videoController == null ||
        !_videoController!.value.isInitialized)
      return;

    _skipSeconds += seconds;

    try {
      final newPos =
          _videoController!.value.position + Duration(seconds: seconds);
      _videoController!.seekTo(newPos);
    } catch (_) {}

    if (!_isDisposed && _skipAnimController != null) {
      _skipAnimController!.reset();
      _skipAnimController!.forward();
    }

    if (!_isDisposed) setState(() {});
  }

  void _seekToRelative(double fraction) {
    if (_isDisposed ||
        _videoController == null ||
        !_videoController!.value.isInitialized)
      return;

    final durationMs = _videoController!.value.duration.inMilliseconds;
    final seekToMs = (fraction * durationMs).toInt();
    try {
      _videoController!.seekTo(Duration(milliseconds: seekToMs));
    } catch (_) {}
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    if (duration.inHours == 0) return '$minutes:$seconds';
    return '$hours:$minutes:$seconds';
  }

  double _getProgressPercentage() {
    if (_videoController == null ||
        _videoController!.value.duration.inMilliseconds == 0)
      return 0.0;
    return (_videoController!.value.position.inMilliseconds /
            _videoController!.value.duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;
    if (state == AppLifecycleState.paused && _videoController != null) {
      _videoController!.pause();
    }
  }

  Future<void> _safeExit() async {
    if (_isDisposed) return;

    if (_isFullScreen) await _toggleFullScreen();
    _isDisposed = true;

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    if (mounted) Get.back();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _isDisposed = true;

    if (_videoController != null) {
      try {
        _videoController!.pause();
        _videoController!.dispose();
      } catch (_) {}
    }

    _skipAnimController?.dispose();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _safeExit();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          if (!controller.isInitialized.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            );
          }

          return GestureDetector(
            onTap: _toggleControls,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // VIDEO
                Center(
                  child: _videoController != null
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : const SizedBox.shrink(),
                ),

                // DOUBLE TAP SKIP
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onDoubleTap: () => _skip(-5),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onDoubleTap: () => _skip(5),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ],
                ),

                // CONTROLS
                if (_showControls) ...[
                  Positioned(top: 0, left: 0, right: 0, child: _buildHeader()),
                  Positioned.fill(child: Center(child: _buildCenterControls())),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildBottomControls(),
                  ),
                ],

                // BUFFERING
                if (_videoController != null &&
                    _videoController!.value.isBuffering)
                  const Center(
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white70,
                        ),
                        strokeWidth: 5,
                      ),
                    ),
                  ),

                // SKIP OVERLAY
                if (_skipSeconds != 0)
                  Center(
                    child: FadeTransition(
                      opacity: _skipAnimation!,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _skipSeconds > 0
                              ? '+${_skipSeconds}s'
                              : '${_skipSeconds}s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // --- UI COMPONENTS --- //

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _safeExit,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              controller.videos[controller.currentIndex.value].title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: _toggleFullScreen,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: controller.previousVideo,
          child: _controlButton(Icons.skip_previous),
        ),
        GestureDetector(
          onTap: () => _skip(-10),
          child: _controlButton(Icons.replay_10),
        ),
        GestureDetector(
          onTap: controller.togglePlay,
          child: _playPauseButton(),
        ),
        GestureDetector(
          onTap: () => _skip(10),
          child: _controlButton(Icons.forward_10),
        ),
        GestureDetector(
          onTap: controller.nextVideo,
          child: _controlButton(Icons.skip_next),
        ),
      ],
    );
  }

  Widget _controlButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 36),
    );
  }

  Widget _playPauseButton() {
    return Obx(() {
      final isPlaying = controller.isPlaying.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPlaying ? Colors.blueAccent : Colors.black45,
          shape: BoxShape.circle,
          boxShadow: [
            if (isPlaying)
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.7),
                blurRadius: 12,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
          color: Colors.white,
          size: 64,
        ),
      );
    });
  }

  Widget _buildBottomControls() {
    final progress = _getProgressPercentage();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.black.withOpacity(0.6),
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTapDown: (details) {
              final box = context.findRenderObject() as RenderBox;
              final local = box.globalToLocal(details.globalPosition);
              _seekToRelative((local.dx / box.size.width).clamp(0.0, 1.0));
            },
            onHorizontalDragUpdate: (details) {
              final box = context.findRenderObject() as RenderBox;
              final local = box.globalToLocal(details.globalPosition);
              _seekToRelative((local.dx / box.size.width).clamp(0.0, 1.0));
            },
            child: SizedBox(
              height: 30,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  if (_videoController != null &&
                      _videoController!.value.buffered.isNotEmpty)
                    Container(
                      height: 6,
                      width:
                          _videoController!
                              .value
                              .buffered
                              .last
                              .end
                              .inMilliseconds /
                          _videoController!.value.duration.inMilliseconds *
                          MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  Container(
                    height: 6,
                    width: progress * MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Positioned(
                    left: (progress * MediaQuery.of(context).size.width) - 10,
                    top: -7,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.7),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _videoController != null
                    ? _formatDuration(_videoController!.value.position)
                    : '00:00',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                _videoController != null
                    ? _formatDuration(_videoController!.value.duration)
                    : '00:00',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
