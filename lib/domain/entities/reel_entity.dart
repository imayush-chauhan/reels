import 'package:equatable/equatable.dart';

class ReelEntity extends Equatable {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String username;
  final String avatarUrl;
  final String caption;
  final String audioName;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;

  const ReelEntity({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.username,
    required this.avatarUrl,
    required this.caption,
    required this.audioName,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    this.isLiked = false,
  });

  ReelEntity copyWith({
    String? id,
    String? videoUrl,
    String? thumbnailUrl,
    String? username,
    String? avatarUrl,
    String? caption,
    String? audioName,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isLiked,
  }) {
    return ReelEntity(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      caption: caption ?? this.caption,
      audioName: audioName ?? this.audioName,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        videoUrl,
        thumbnailUrl,
        username,
        avatarUrl,
        caption,
        audioName,
        likesCount,
        commentsCount,
        sharesCount,
        isLiked,
      ];
}
