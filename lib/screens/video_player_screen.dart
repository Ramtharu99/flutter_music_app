import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  int currentIndex = 0;
  bool showControls = true;

  final List<String> videos = [
    'https://www.w3schools.com/html/mov_bbb.mp4',
    'https://media.w3.org/2010/05/sintel/trailer.mp4',
    'https://samplelib.com/lib/preview/mp4/sample-10s.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _controller = VideoPlayerController.network(videos[currentIndex])
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.addListener(() {
      if (_controller.value.isInitialized &&
          _controller.value.position >= _controller.value.duration &&
          currentIndex < videos.length - 1) {
        _nextVideo();
      }
    });
  }

  void _nextVideo() {
    _controller.dispose();
    setState(() => currentIndex++);
    _initializePlayer();
  }

  void _previousVideo() {
    if (currentIndex == 0) return;
    _controller.dispose();
    setState(() => currentIndex--);
    _initializePlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    return '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
        '${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => setState(() => showControls = !showControls),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : const CircularProgressIndicator(color: Colors.white),
              ),

              /// CONTROLS
              if (showControls)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// PLAY / PAUSE
                        IconButton(
                          iconSize: 64,
                          color: Colors.white,
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                          ),
                          onPressed: () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        /// SEEK BAR
                        Slider(
                          min: 0,
                          max: _controller.value.duration.inSeconds.toDouble(),
                          value: _controller.value.position.inSeconds
                              .toDouble()
                              .clamp(
                                0,
                                _controller.value.duration.inSeconds.toDouble(),
                              ),
                          onChanged: (value) {
                            _controller.seekTo(
                              Duration(seconds: value.toInt()),
                            );
                          },
                          activeColor: Colors.red,
                          inactiveColor: Colors.white38,
                        ),

                        /// TIME
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _format(_controller.value.position),
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                _format(_controller.value.duration),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// NEXT / PREVIOUS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous),
                              iconSize: 40,
                              color: Colors.white,
                              onPressed: _previousVideo,
                            ),
                            const SizedBox(width: 30),
                            IconButton(
                              icon: const Icon(Icons.skip_next),
                              iconSize: 40,
                              color: Colors.white,
                              onPressed: _nextVideo,
                            ),
                          ],
                        ),
                      ],
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
