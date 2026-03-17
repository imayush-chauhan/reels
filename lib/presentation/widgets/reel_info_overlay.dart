import 'package:flutter/material.dart';
import 'package:reels/domain/entities/reel_entity.dart';
import 'package:reels/presentation/widgets/reel_avatar.dart';
import 'package:reels/presentation/widgets/scrolling_audio_label.dart';

class ReelInfoOverlay extends StatelessWidget {
  final ReelEntity reel;

  const ReelInfoOverlay({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Username row ─────────────────────────────────────────────────
          Row(
            children: [
              ReelAvatar(
                imageUrl: reel.avatarUrl,
                radius: 18,
              ),
              const SizedBox(width: 10),
              Text(
                '@${reel.username}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.2,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
                ),
              ),
              const SizedBox(width: 10),
              _FollowButton(),
            ],
          ),

          const SizedBox(height: 10),

          // ── Caption ──────────────────────────────────────────────────────
          if (reel.caption.isNotEmpty)
            _ExpandableCaption(caption: reel.caption),

          const SizedBox(height: 10),

          // ── Audio label ──────────────────────────────────────────────────
          ScrollingAudioLabel(audioName: reel.audioName),
        ],
      ),
    );
  }
}

// ─── Follow button ────────────────────────────────────────────────────────────

class _FollowButton extends StatefulWidget {
  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  bool _following = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _following = !_following),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: _following ? Colors.transparent : Colors.white,
          border: Border.all(color: Colors.white, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          _following ? 'Following' : 'Follow',
          style: TextStyle(
            color: _following ? Colors.white : Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ─── Expandable caption ───────────────────────────────────────────────────────

class _ExpandableCaption extends StatefulWidget {
  final String caption;

  const _ExpandableCaption({required this.caption});

  @override
  State<_ExpandableCaption> createState() => _ExpandableCaptionState();
}

class _ExpandableCaptionState extends State<_ExpandableCaption> {
  bool _expanded = false;
  static const int _maxLines = 2;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topLeft,
        child: RichText(
          maxLines: _expanded ? null : _maxLines,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          text: TextSpan(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.4,
              shadows: [Shadow(blurRadius: 6, color: Colors.black87)],
            ),
            children: [
              TextSpan(text: widget.caption),
              if (!_expanded && widget.caption.length > 60)
                const TextSpan(
                  text: ' more',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
