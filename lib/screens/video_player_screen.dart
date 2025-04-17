import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String lessonTitle;
  final VoidCallback? onVideoCompleted;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.lessonTitle,
    this.onVideoCompleted,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  double _progress = 0.0;
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isCompleted = false;
  bool _showCheckmark = false;
  Duration? _lastPosition;

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

      // Add progress listener
      controller.addListener(_updateProgress);
      
      // Start playing
      controller.play();
      setState(() {
        _isPlaying = true;
      });

      print('Video initialized: ${widget.lessonTitle}');
      print('Duration: ${controller.value.duration}');
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

  void _updateProgress() {
    if (!mounted || _controller == null || !_controller!.value.isInitialized) return;

    final position = _controller!.value.position;
    final duration = _controller!.value.duration;

    if (duration.inMilliseconds == 0) return;

    // Check if video has moved forward
    if (_lastPosition != null && position <= _lastPosition!) {
      return; // Ignore if video hasn't moved forward
    }
    _lastPosition = position;

    final progress = position.inMilliseconds / duration.inMilliseconds;
    
    print('Video Progress: ${(progress * 100).toStringAsFixed(1)}%');
    print('Position: $position / Duration: $duration');

    setState(() {
      _progress = progress;
      
      // Check if video is completed (reached 90% or more)
      if (progress >= 0.90 && !_isCompleted) {
        _isCompleted = true;
        _showCheckmark = true;
        print('Video completed: ${widget.lessonTitle}');
      }
    });
  }

  void _handleCheckmarkPress() {
    if (widget.onVideoCompleted != null) {
      widget.onVideoCompleted!();
      setState(() {
        _showCheckmark = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video marked as completed!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_updateProgress);
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
                    _isPlaying = !_isPlaying;
                    _isPlaying ? _controller!.play() : _controller!.pause();
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),

          // Checkmark Button
          if (_showCheckmark)
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: _handleCheckmarkPress,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 30,
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

          // Progress Indicator
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isCompleted ? Colors.green : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_controller?.value.position ?? Duration.zero),
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        '${(_progress * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        _formatDuration(_controller?.value.duration ?? Duration.zero),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
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
