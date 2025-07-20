import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/meditation_session.dart';
import '../providers/meditation_provider.dart';

class MeditationSessionScreen extends StatefulWidget {
  final MeditationSession session;

  const MeditationSessionScreen({super.key, required this.session});

  @override
  State<MeditationSessionScreen> createState() => _MeditationSessionScreenState();
}

class _MeditationSessionScreenState extends State<MeditationSessionScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isPlaying = false;
  bool _isCompleted = false;
  int? _userRating;
  bool _showControls = true;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.session.durationMinutes * 60;
    // Auto-hide controls after 3 seconds of inactivity
    _startControlsTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controlsTimer?.cancel();
    super.dispose();
  }

  Timer? _controlsTimer;
  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying && !_isCompleted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _resetControlsTimer() {
    setState(() => _showControls = true);
    _startControlsTimer();
  }

  void _startTimer() {
    if (_timer != null) return;

    setState(() {
      _isPlaying = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeSession();
          timer.cancel();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() => _isPlaying = false);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isPlaying = false;
      _remainingSeconds = widget.session.durationMinutes * 60;
    });
  }

  Future<void> _completeSession() async {
    setState(() {
      _isCompleted = true;
      _isPlaying = false;
      _showControls = true;
    });

    try {
      await Provider.of<MeditationProvider>(context, listen: false)
          .completeSession(widget.session.id, rating: _userRating);
    } catch (e) {
      debugPrint('Error completing meditation session: $e');
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Your Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How was your meditation experience?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() => _userRating = index + 1);
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.star,
                    color: _userRating != null && _userRating! > index
                        ? const Color(0xFFD2B48C) // Tan color for stars
                        : Colors.grey[400],
                    size: 36,
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32), // Dark chocolate
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    _resetControlsTimer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = 1 - (_remainingSeconds / (widget.session.durationMinutes * 60));
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _isFullscreen ? null : AppBar(
        backgroundColor: const Color(0xFF2E7D32), // Dark chocolate
        foregroundColor: Colors.white,
        title: Text(widget.session.title),
        elevation: 0,
        actions: [
          if (_isCompleted)
            IconButton(
              onPressed: _showRatingDialog,
              icon: const Icon(Icons.star_outline),
              tooltip: 'Rate Session',
            ),
          IconButton(
            onPressed: _toggleFullscreen,
            icon: Icon(_isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _resetControlsTimer,
        child: Stack(
          children: [
            // Background with subtle pattern
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/meditation_bg.png'), // Add your own asset
                  fit: BoxFit.cover,
                  opacity: 0.05,
                ),
              ),
            ),

            Column(
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  minHeight: 4,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                ),

                Expanded(
                  child: Padding(
                    padding: _isFullscreen
                        ? const EdgeInsets.all(40.0)
                        : const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Session content
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: _isFullscreen
                              ? const EdgeInsets.all(40)
                              : const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(_isFullscreen ? 30 : 24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.brown.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Timer display
                              Text(
                                _formatTime(_remainingSeconds),
                                style: theme.textTheme.displayLarge?.copyWith(
                                  color: const Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                  fontSize: _isFullscreen ? 64 : 48,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Session info
                              Text(
                                widget.session.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: const Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),

                              if (!_isFullscreen) ...[
                                Text(
                                  widget.session.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),

                                // Category chip
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.session.category,
                                    style: const TextStyle(
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Spacer to push controls down in fullscreen mode
                        if (_isFullscreen) const Spacer(),

                        // Control buttons (shown based on state)
                        if (_showControls || _isCompleted) ...[
                          const SizedBox(height: 40),
                          if (!_isCompleted) ...[
                            // Playback controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Skip back
                                IconButton(
                                  onPressed: () {
                                    setState(() => _remainingSeconds =
                                        (_remainingSeconds - 30).clamp(0, widget.session.durationMinutes * 60));
                                    _resetControlsTimer();
                                  },
                                  icon: const Icon(Icons.replay_30, size: 32),
                                  color: const Color(0xFF2E7D32),
                                ),

                                // Stop button
                                IconButton(
                                  onPressed: () {
                                    _stopTimer();
                                    _resetControlsTimer();
                                  },
                                  icon: const Icon(Icons.stop, size: 40),
                                  color: Colors.red[400],
                                ),

                                // Play/Pause button
                                IconButton(
                                  onPressed: () {
                                    _isPlaying ? _pauseTimer() : _startTimer();
                                    _resetControlsTimer();
                                  },
                                  iconSize: 64,
                                  icon: Icon(
                                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),

                                // Skip forward
                                IconButton(
                                  onPressed: () {
                                    setState(() => _remainingSeconds =
                                        (_remainingSeconds + 30).clamp(0, widget.session.durationMinutes * 60));
                                    _resetControlsTimer();
                                  },
                                  icon: const Icon(Icons.forward_30, size: 32),
                                  color: const Color(0xFF2E7D32),
                                ),
                              ],
                            ),
                          ] else ...[
                            // Completion message
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Session Completed!',
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (_userRating != null) ...[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(5, (index) => Icon(
                                            Icons.star,
                                            size: 20,
                                            color: index < _userRating!
                                                ? const Color(0xFFD2B48C)
                                                : Colors.grey[300],
                                          )),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF2E7D32),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                        ),
                                        child: const Text('Finish Session'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Fullscreen toggle button (floating)
            if (!_isFullscreen && !_isCompleted && _showControls)
              Positioned(
                top: 16,
                right: 16,
                child: FloatingActionButton.small(
                  onPressed: _toggleFullscreen,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.fullscreen, color: Color(0xFF2E7D32)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}