import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reels/domain/entities/reel_entity.dart';

class ReelModel extends ReelEntity {
  const ReelModel({
    required super.id,
    required super.videoUrl,
    required super.thumbnailUrl,
    required super.username,
    required super.avatarUrl,
    required super.caption,
    required super.audioName,
    required super.likesCount,
    required super.commentsCount,
    required super.sharesCount,
    super.isLiked = false,
  });

  factory ReelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReelModel(
      id: doc.id,
      videoUrl: (data['videoUrl'] as String?) ?? '',
      thumbnailUrl: (data['thumbnailUrl'] as String?) ?? '',
      username: (data['username'] as String?) ?? 'unknown',
      avatarUrl: (data['avatarUrl'] as String?) ?? '',
      caption: (data['caption'] as String?) ?? '',
      audioName: (data['audioName'] as String?) ?? 'Original Audio',
      likesCount: (data['likesCount'] as int?) ?? 0,
      commentsCount: (data['commentsCount'] as int?) ?? 0,
      sharesCount: (data['sharesCount'] as int?) ?? 0,
      isLiked: (data['isLiked'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'username': username,
      'avatarUrl': avatarUrl,
      'caption': caption,
      'audioName': audioName,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
    };
  }

  factory ReelModel.fromEntity(ReelEntity entity) {
    return ReelModel(
      id: entity.id,
      videoUrl: entity.videoUrl,
      thumbnailUrl: entity.thumbnailUrl,
      username: entity.username,
      avatarUrl: entity.avatarUrl,
      caption: entity.caption,
      audioName: entity.audioName,
      likesCount: entity.likesCount,
      commentsCount: entity.commentsCount,
      sharesCount: entity.sharesCount,
      isLiked: entity.isLiked,
    );
  }
}
