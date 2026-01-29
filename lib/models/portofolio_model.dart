import 'package:flutter/material.dart';

class Portofolio {
  //properties (data yang disimpan)

  final String id; 
  final String imageUrl;
  final String title; 
  final String deskripsi; 
  final String kategori; 
  final List<String> tags; 
  final String? linkProject; 

  //Data dari pembuat / usernya
  final String userId; 
  final String username; 
  final String? userAvatar; 

  // statistik
  final int likes; 
  final List<String> likedBy; //id userny yang suda like
  final int views; 
  final int comments; 

  //metadata
  final DateTime createdAt; 
  final DateTime updatedAt; 

  /// Constructor = function untuk membuat object portofolio baru
  /// required = wajib di isi
  /// optional (ada tanda ?) artinya null atau boleh kosong

  Portofolio({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.deskripsi,
    required this.kategori,
    this.tags = const [],
    this.linkProject,
    required this.userId,
    required this.username,
    this.userAvatar,
    this.likes = 0,
    this.likedBy = const [],
    this.views = 0,
    this.comments = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// convert dari firestoe (map) ke portofolio objek
  factory Portofolio.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return Portofolio(
      id: documentId,
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      kategori: data['kategori'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      linkProject: data['linkProject'],
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      userAvatar: data['userAvatar'],
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      views: data['views'] ?? 0,
      comments: data['comments'] ?? 0,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  /// convert dari portofolio object ke map (untuk simpan ke firestore)

  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'tags': tags,
      'linkProject': linkProject,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'likes': likes,
      'likedBy': likedBy,
      'views': views,
      'comments': comments,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// copy portofolio dengan bebearpa perubahan
  Portofolio copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? deskripsi,
    String? kategori,
    List<String>? tags,
    String? linkProject,
    int? likes,
    List<String>? likedBy,
    int? views,
    int? comments,
    DateTime? updatedAt,
  }) {
    return Portofolio(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      deskripsi: deskripsi ?? this.deskripsi,
      kategori: kategori ?? this.kategori,
      tags: tags ?? this.tags,
      linkProject: linkProject ?? this.linkProject,
      userId: this.userId,
      username: this.username,
      userAvatar: this.userAvatar,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      views: views ?? this.views,
      comments: comments ?? this.comments,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
