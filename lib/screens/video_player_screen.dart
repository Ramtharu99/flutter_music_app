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
    with WidgetsBindingObserver {
  late VideoPlayerController _videoController;
  bool _showControls = true;
  bool _isFullScreen = false;
  Timer? _hideControlsTimer;
  final controller = Get.find<VideoController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    await controller.initializePlayer(widget.index);
    _videoController = controller.player;

    if (controller.isInitialized.value) {
      _videoController.play();
    }

    setState(() {});
    _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showControls) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  Future<void> _toggleFullScreen() async {
    if (_isFullScreen) {
      // Exit fullscreen
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => _isFullScreen = false);
    } else {
      // Enter fullscreen
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      setState(() => _isFullScreen = true);
    }
    _startHideControlsTimer();
  }

  void _seekRelative(int seconds) {
    final newPosition =
        _videoController.value.position + Duration(seconds: seconds);
    _videoController.seekTo(newPosition);
    _startHideControlsTimer();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    if (duration.inHours == 0) return '$minutes:$seconds';
    return '$hours:$minutes:$seconds';
  }

  double _getProgressPercentage() {
    if (_videoController.value.duration.inMilliseconds == 0) return 0.0;
    return (_videoController.value.position.inMilliseconds /
            _videoController.value.duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _videoController.pause();
    }
  }

  // Safe exit: force portrait → delay → back
  Future<void> _safeExit() async {
    // If in fullscreen → exit first
    if (_isFullScreen) {
      await _toggleFullScreen();
      await Future.delayed(const Duration(milliseconds: 400));
    }

    // Force portrait
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await Future.delayed(const Duration(milliseconds: 300));

    // Exit screen
    Get.back();
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
                // Video content
                Center(
                  child: AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  ),
                ),

                // Controls overlay
                if (_showControls) ...[
                  // Header (back + title + fullscreen)
                  Positioned(top: 0, left: 0, right: 0, child: _buildHeader()),

                  // Center play/pause/rewind/forward
                  Positioned.fill(child: Center(child: _buildCenterControls())),

                  // Bottom progress bar + time
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildBottomControls(),
                  ),
                ],

                // Buffering indicator
                if (_videoController.value.isBuffering)
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
              ],
            ),
          );
        }),
      ),
    );
  }

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
              controller.videos[widget.index].title,
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
          onTap: () => _seekRelative(-10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.replay_10, color: Colors.white, size: 40),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (_videoController.value.isPlaying) {
              _videoController.pause();
            } else {
              _videoController.play();
            }
            setState(() {});
            _startHideControlsTimer();
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _videoController.value.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
              color: Colors.white,
              size: 64,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _seekRelative(10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.forward_10, color: Colors.white, size: 40),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
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
          // Progress bar – clickable & draggable
          GestureDetector(
            // Tap to seek
            onTapDown: (details) {
              final renderBox = context.findRenderObject() as RenderBox;
              final local = renderBox.globalToLocal(details.globalPosition);
              var progress = local.dx / renderBox.size.width;
              progress = progress.clamp(0.0, 1.0);
              final durationMs = _videoController.value.duration.inMilliseconds;
              final seekToMs = (progress * durationMs).toInt();
              _videoController.seekTo(Duration(milliseconds: seekToMs));
              _startHideControlsTimer();
            },
            // Drag to scrub
            onHorizontalDragUpdate: (details) {
              final renderBox = context.findRenderObject() as RenderBox;
              final local = renderBox.globalToLocal(details.globalPosition);
              var progress = local.dx / renderBox.size.width;
              progress = progress.clamp(0.0, 1.0);
              final durationMs = _videoController.value.duration.inMilliseconds;
              final seekToMs = (progress * durationMs).toInt();
              _videoController.seekTo(Duration(milliseconds: seekToMs));
              _startHideControlsTimer();
            },
            child: SizedBox(
              height: 30,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  // Background track
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Buffered range
                  if (_videoController.value.buffered.isNotEmpty)
                    Container(
                      height: 6,
                      width:
                          _videoController
                              .value
                              .buffered
                              .last
                              .end
                              .inMilliseconds /
                          _videoController.value.duration.inMilliseconds *
                          MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  // Played progress
                  Container(
                    height: 6,
                    width:
                        _getProgressPercentage() *
                        MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Thumb (larger for better touch)
                  Positioned(
                    left:
                        (_getProgressPercentage() *
                            MediaQuery.of(context).size.width) -
                        10,
                    top: -7,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.7),
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

          // Time labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_videoController.value.position),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                _formatDuration(_videoController.value.duration),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
