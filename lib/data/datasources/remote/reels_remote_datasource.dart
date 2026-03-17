import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reels/core/constants/app_constants.dart';
import 'package:reels/core/errors/exceptions.dart';
import 'package:reels/core/utils/app_logger.dart';
import 'package:reels/data/models/reel_model.dart';

abstract class ReelsRemoteDataSource {
  Future<List<ReelModel>> fetchReels({int limit, String? lastDocumentId});
  Future<ReelModel> toggleLike(String reelId, bool isLiked);
}

class ReelsRemoteDataSourceImpl implements ReelsRemoteDataSource {
  final FirebaseFirestore _firestore;

  ReelsRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<List<ReelModel>> fetchReels({
    int limit = AppConstants.reelsPageSize,
    String? lastDocumentId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(AppConstants.reelsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocumentId != null) {
        final lastDoc = await _firestore
            .collection(AppConstants.reelsCollection)
            .doc(lastDocumentId)
            .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      AppLogger.info('Fetched ${snapshot.docs.length} reels from Firestore.');
      return snapshot.docs.map(ReelModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      AppLogger.error('Firestore error fetching reels', e);
      throw FirestoreException(e.message ?? 'Firestore error.');
    } catch (e) {
      AppLogger.error('Unknown error fetching reels', e);
      throw FirestoreException('Unexpected error: $e');
    }
  }

  @override
  Future<ReelModel> toggleLike(String reelId, bool isLiked) async {
    try {
      final docRef =
          _firestore.collection(AppConstants.reelsCollection).doc(reelId);

      await docRef.update({
        'likesCount': FieldValue.increment(isLiked ? -1 : 1),
      });

      final updated = await docRef.get();
      return ReelModel.fromFirestore(updated);
    } on FirebaseException catch (e) {
      AppLogger.error('Firestore error toggling like', e);
      throw FirestoreException(e.message ?? 'Could not toggle like.');
    }
  }
}
