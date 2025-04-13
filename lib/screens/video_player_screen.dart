import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String lessonTitle;
  final String videoUrl;

  const VideoPlayerScreen({
    super.key,
    required this.lessonTitle,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  double _progress = 0.0;
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final controller = VideoPlayerController.network(
        widget.videoUrl,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _controller = controller;
        _isInitialized = true;
      });

      controller.addListener(() {
        if (mounted && controller.value.isInitialized) {
          setState(() {
            _progress = controller.value.position.inMilliseconds /
                controller.value.duration.inMilliseconds;
          });
        }
      });

      controller.play();
    } catch (error) {
      print('Video initialization error: $error');
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading video: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Player
          Center(
            child: _isInitialized && _controller != null
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  )
                : const CircularProgressIndicator(color: Colors.white),
          ),

          // Play/Pause Button Overlay
          if (_isInitialized && _controller != null)
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),

          // Top Navigation Bar with Vertical Title
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                widget.lessonTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ),

          // Vertical Progress Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            bottom: 80,
            left: 24,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (!_isInitialized) return;
                final RenderBox box = context.findRenderObject() as RenderBox;
                final height = box.size.height - 160;
                final position = details.globalPosition.dy -
                    MediaQuery.of(context).padding.top -
                    80;
                final percentage = (height - position) / height;
                final newProgress = percentage.clamp(0.0, 1.0);
                setState(() {
                  _progress = newProgress;
                });
                final Duration newPosition = Duration(
                  milliseconds:
                      (_controller!.value.duration.inMilliseconds * newProgress)
                          .toInt(),
                );
                _controller!.seekTo(newPosition);
              },
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Stack(
                  children: [
                    // Progress Fill
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height:
                          MediaQuery.of(context).size.height * 0.6 * _progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Progress Handle
                    Positioned(
                      bottom:
                          MediaQuery.of(context).size.height * 0.6 * _progress -
                              8,
                      left: -6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Time Indicators
          if (_isInitialized) ...[
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 40,
              child: Text(
                _formatDuration(_controller!.value.position),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: 40,
              child: Text(
                _formatDuration(_controller!.value.duration),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
