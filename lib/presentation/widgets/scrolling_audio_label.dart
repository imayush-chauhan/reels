import 'package:flutter/material.dart';

class ScrollingAudioLabel extends StatefulWidget {
  final String audioName;

  const ScrollingAudioLabel({super.key, required this.audioName});

  @override
  State<ScrollingAudioLabel> createState() => _ScrollingAudioLabelState();
}

class _ScrollingAudioLabelState extends State<ScrollingAudioLabel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: (widget.audioName.length / 8).clamp(3, 10).toInt()),
    )..repeat();
    _animation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: const Offset(-1.2, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.music_note_rounded, color: Colors.white, size: 14,
            shadows: [Shadow(blurRadius: 4, color: Colors.black87)]),
        const SizedBox(width: 6),
        SizedBox(
          width: 160,
          child: ClipRect(
            child: SlideTransition(
              position: _animation,
              child: Text(
                widget.audioName,
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
