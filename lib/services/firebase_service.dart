import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:portokita/models/portofolio_model.dart';

class FirebaseService {

  FirebaseService._();

  static final FirebaseService _instance = FirebaseService._();

  factory FirebaseService() => _instance;

  //firabase instances
  //firbaseAuth = untuk authentication(login,registeer,logout)

  final FirebaseAuth auth = FirebaseAuth.instance;

  ///FirebaseFirestore = untuk database (crud data)
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //Collections
  /// Reference ke collection 'portofolios' di firestore
  CollectionReference get PortofolioCollection =>
      firestore.collection('portofolios');
  
  /// reference ke collection 'user' 
  CollectionReference get usersCollection =>
      firestore.collection('users');

  // current user
  /// mendapatkan user yang sedang login
  /// return null jika lom login
  User? get currentUser => auth.currentUser;

  ///mendapatkan userId dari user yang sedang login
  /// return null jika belum login
  String? get currentUserId => auth.currentUser?.uid;

  //stream untuk dengar perubahan authentikasi
  ///berugna untuk: auto logout, auto redirect, dll
  Stream<User?> get authStateChanges => auth.authStateChanges();

}