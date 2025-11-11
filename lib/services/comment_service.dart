import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentService {
  final _db = FirebaseFirestore.instance;

  // 🔹 Escuchar los comentarios en tiempo real
  Stream<List<CommentModel>> getComments(String carId) {
    return _db
        .collection('cars')
        .doc(carId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CommentModel.fromMap(d.data())).toList());
  }

  // 🔹 Enviar un nuevo comentario
  Future<void> addComment(String carId, CommentModel comment) async {
    await _db
        .collection('cars')
        .doc(carId)
        .collection('comments')
        .doc(comment.id)
        .set(comment.toMap());
  }
}
