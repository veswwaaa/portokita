import 'package:portokita/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseService _firebaseService = FirebaseService();

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    String? kategori,
  }) async {
    try {
      // buat akun di firebase auth
      UserCredential userCredential = await _firebaseService.auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // ambil user object dari hasil register
      User? firebaseUser = userCredential.user;



      if (firebaseUser == null) {
        return {
          'success': false,
          'user': null,
          'message': 'Register gagal',
        };
      }

      // buat data user untuk disimpan firestore
      UserModel newUser = UserModel(
        id: firebaseUser.uid,
        username: username,
        email: email,
        kategori: kategori,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // simpan data user ke fireStrore collection user
      await _firebaseService.usersCollection
          .doc(firebaseUser.uid)
          .set(newUser.toFirestore());


      return {
        'success': true,
        'user': newUser,
        'message': 'Register berhasil',
      };

      //handler error firebase untuk notif di UI
    } on FirebaseAuthException catch (e) {
      print('error register: ${e.code} - ${e.message}');
      if(e.code == 'email-already-in-use') {
        return {
          'success': false,
          'user': null,
          'message': 'Email sudah digunakan, silakan gunakan email lain',
        };
      } else if (e.code == 'weak-password') {
        return {
          'success': false,
          'user': null,
          'message': 'Password terlalu lemah, gunakan minimal 8 karakter',
        };
      } else if (e.code == 'invalid-email') {
        return {
          'success': false,
          'user': null,
          'message': 'Email tidak valid, silakan periksa kembali',
        };
      } else {
        return {
          'success': false,
          'user': null,
          'message': 'Gagal register: ${e.message}',
        };
      }
    } catch (e) {
      print('eror register: $e');
      return {
        'success': false,
        'user': null,
        'message': 'Terjadi kesalahan saat register, coba lagi',
      };
    }
  }

  ///login

  Future<UserModel?> login({
    required String email,
    required String password,
    required bool rememberMe
  }) async {
    print("login function calling");
    try {
      UserCredential userCredential = await _firebaseService.auth
      .signInWithEmailAndPassword(email: email, password: password);
      SharedPreferences prefs = await
      SharedPreferences.getInstance();
      if(rememberMe == true) {
        await prefs.setBool('remember_me',true);

      }else{
        await prefs.setBool('remember_me', false);
      }
      print(email);
      print(password);

      //ambil user object
      User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return null;
      }

      // ambil data user dari firestore
      DocumentSnapshot userDoc = await _firebaseService.usersCollection
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        print("login gagal");

        return null;
      }

      //convert doc firestore -> usermodel objek

      UserModel userModel = UserModel.fromFirestore(
        userDoc.data() as Map<String, dynamic>,
        userDoc.id,
      );

      //return userModel
      print("login berhasil");
      print(userModel);
      return userModel;
    } catch (e) {
      print('error login ${e} - ${e}');
      return null;
    }
  }

  //logout
  Future<void> logout() async {
    try {
      SharedPreferences prefs = await
      SharedPreferences.getInstance();
      await prefs.setBool('remember_me', false);

      await _firebaseService.auth.signOut();
    } catch (e) {
      print('eror logou: $e');
    }
  }

  //mengambil data user yang sedang login dari firebase
  Future<UserModel?> getCurrentUserData() async {
    try {
      String? userId = _firebaseService.currentUserId;

      if (userId == null) {
        return null;
      }

      DocumentSnapshot userDoc = await _firebaseService.usersCollection
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      return UserModel.fromFirestore(
        userDoc.data() as Map<String, dynamic>,
        userDoc.id,
      );
    } catch (e) {
      print('error get current user: $e');
      return null;
    }
  }

  bool isLoggedIn() {
    return _firebaseService.currentUser != null;
  }
}
