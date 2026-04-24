import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import '../models/comment_model.dart';

class CommentService {
  final FirebaseService _firebaseService = FirebaseService();

  /// Reference ke collection 'comments'
  CollectionReference get _commentsCollection =>
      _firebaseService.firestore.collection('comments');

  /// Tambah komentar baru
  Future<Comment?> addComment({
    required String portfolioId,
    required String userId,
    required String username,
    String? userAvatar,
    required String text,
  }) async {
    try {
      final comment = Comment(
        id: '',
        portfolioId: portfolioId,
        userId: userId,
        username: username,
        userAvatar: userAvatar,
        text: text,
        createdAt: DateTime.now(),
      );

      final docRef = await _commentsCollection.add(comment.toFirestore());

      // Update comment count pada portfolio
      await _firebaseService.PortofolioCollection.doc(portfolioId).update({
        'comments': FieldValue.increment(1),
      });

      return Comment(
        id: docRef.id,
        portfolioId: portfolioId,
        userId: userId,
        username: username,
        userAvatar: userAvatar,
        text: text,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error adding comment: $e');
      return null;
    }
  }

  /// Stream komentar berdasarkan portfolioId (real-time)
  Stream<List<Comment>> getComments(String portfolioId) {
    return _commentsCollection
        .where('portfolioId', isEqualTo: portfolioId)
        .snapshots()
        .map((snapshot) {
      final comments = snapshot.docs.map((doc) {
        return Comment.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      // Urutkan di memori agar tidak perlu index Firestore
      // b.createdAt.compareTo(a.createdAt) untuk urutan terbaru di atas
      comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return comments;
    });
  }

  /// Hapus komentar
  Future<bool> deleteComment(String commentId, String portfolioId) async {
    try {
      await _commentsCollection.doc(commentId).delete();

      // Kurangi comment count pada portfolio
      await _firebaseService.PortofolioCollection.doc(portfolioId).update({
        'comments': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }
}
