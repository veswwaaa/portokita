import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'firebase_service.dart';
import '../models/portofolio_model.dart';
import '../models/user_model.dart';

///porto service untuk handle semua operasi portofolio

class PortofolioService {
  final FirebaseService _firebaseService = FirebaseService();

  ///create
  Future<Portofolio?> uploadPortfolio({
    required String imageUrl,
    required String title,
    required String deskripsi,
    required String kategori,
    List<String>? tags,
    String? linkProject,
    required UserModel currentUser,
  }) async {
    try {
      // ngebuat objek porto baru

      Portofolio newPortofolio = Portofolio(
        id: '', 
        imageUrl: imageUrl,
        title: title,
        deskripsi: deskripsi,
        kategori: kategori,
        tags: tags ?? [],
        linkProject: linkProject,
        userId: currentUser.id,
        username: currentUser.username,
        userAvatar: currentUser.avatarUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      //simpan ke firestore (auto generate document id)
      print('🔥 Menyimpan ke Firestore...');
      DocumentReference docRef = await _firebaseService
          .PortofolioCollection.add(newPortofolio.toFirestore());

      print('✅ Portfolio tersimpan dengan ID: ${docRef.id}');

      String portofolioId = docRef.id;

      try {
        await _firebaseService.usersCollection.doc(currentUser.id).update({
          'myPortofolios': FieldValue.arrayUnion([portofolioId]),
        });
      } catch (e) {
        print('skip update user(testingmode) : $e');
      }

      return newPortofolio.copyWith(id: portofolioId);
    } catch (e) {
      print('error upload portofolio : $e');
      return null;
    }
  }

  Stream<List<Portofolio>> getAllPortfolios() {
    return _firebaseService.PortofolioCollection.orderBy(
      'createdAt',
      descending: true,
    ).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Portofolio.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  Stream<List<Portofolio>> getPortofoliosByKategori(String kategori) {
    if (kategori == 'Semua') {
      return getAllPortfolios();
    }

    //filter by kategori nih

    return _firebaseService.PortofolioCollection.where(
      'kategori',
      isEqualTo: kategori,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Portofolio.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  ///search protofolio by title (realtime)

  Stream<List<Portofolio>> searchPortfolios(String query) {
    return getAllPortfolios().map((portfolios) {
      return portfolios.where((portofolio) {
        return portofolio.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }


  Stream<List<Portofolio>> getPortofoliosByUserId(String userId) {
    return _firebaseService.PortofolioCollection.where(
      'userId',
      isEqualTo: userId,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Portofolio.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  //get liked portofolio (portofolio yang di like user)

  Future<List<Portofolio>> getLikedPortfolios(
    List<String> portofolioIds,
  ) async {
    try {
      if (portofolioIds.isEmpty) {
        return [];
      }

      List<Portofolio> allPortofolios = [];

      for (int i = 0; i < portofolioIds.length; i += 10) {
        int end = (i + 10 < portofolioIds.length)
            ? i + 10
            : portofolioIds.length;
        List<String> chunk = portofolioIds.sublist(i, end);

        QuerySnapshot snapshot =
            await _firebaseService.PortofolioCollection.where(
              FieldPath.documentId,
              whereIn: chunk,
            ).get();

        List<Portofolio> portfolios = snapshot.docs.map((doc) {
          return Portofolio.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();

        allPortofolios.addAll(portfolios);
      }

      return allPortofolios;
    } catch (e) {
      print('error get liked portofolios: $e');
      return [];
    }
  }

  //update

  //liked portofolio

  Future<bool> likePortofolio(String portofolioId, String userId) async {
    try {
      await _firebaseService.PortofolioCollection.doc(portofolioId).update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'likes': FieldValue.increment(1),
      });

      await _firebaseService.usersCollection.doc(userId).update({
        'likedPortfolios': FieldValue.arrayUnion([portofolioId]),
      });

      return true;
    } catch (e) {
      print('error like portofolio: $e');
      return false;
    }
  }

  //unlike
  Future<bool> unlikePortofolio(String portofolioId, String userId) async {
    try {
      await _firebaseService.PortofolioCollection.doc(portofolioId).update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'likes': FieldValue.increment(-1),
      });

      await _firebaseService.usersCollection.doc(userId).update({
        'likedPortofolios': FieldValue.arrayRemove([portofolioId]),
      });

      return true;
    } catch (e) {
      print('error unlike portofolio: $e');
      return false;
    }

    //toogle like auto like/unlike>
  }

  Future<bool> toggleLike(Portofolio portofolio, String userId) async {
    bool isLiked = portofolio.likedBy.contains(userId);

    if (isLiked) {
      await unlikePortofolio(portofolio.id, userId);
      return false;
    } else {
      await likePortofolio(portofolio.id, userId);
      return true;
    }
  }

      //hapus porto
  Future<bool> deletePortfolio(String portfolioId, String userId) async {
    try {
      
      // Hapus document portfolio di firestore
      await _firebaseService.PortofolioCollection.doc(portfolioId).delete();

      // Update user: hapus dari myPortofolios
      await _firebaseService.usersCollection.doc(userId).update({
        'myPortofolios': FieldValue.arrayRemove([portfolioId]),
      });

      return true;
    } catch (e) {
      print('Error delete portfolio: $e');
      return false;
    }
  }


  bool isLikedByUser(Portofolio portfolio, String userId) {
    return portfolio.likedBy.contains(userId);
  }

  // increment views
  Future<void> incrementViews(String portfolioId) async {
    try {
      await _firebaseService.PortofolioCollection.doc(portfolioId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error increment views: $e');
    }
  }
}
