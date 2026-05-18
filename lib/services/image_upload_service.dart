import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:imgbb/imgbb.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
class ImageUploadService {
  static const String _apiKey = '0d9ce7f81c1fa57cd2850485c63df52d';

  //fungsi untuk pick gambar dari galeri

  static Future<XFile?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image;
  }



  static Future<String?> uploadImageToImgBB(XFile imageFile) async {
    try {
      var compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        quality: 70,
      );
      
      File fileToUpload = File(imageFile.path);
      if (compressedBytes != null) {
        final dir = await Directory.systemTemp.createTemp();
        final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
        fileToUpload = await File(targetPath).writeAsBytes(compressedBytes);
      }

      print('>>> [DEBUG ImgBB] Memulai upload ke server ImgBB via HTTP (Bypass package imgbb)...');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=$_apiKey'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', fileToUpload.path));
      
      var res = await request.send();
      var responseString = await res.stream.bytesToString();
      
      print('>>> [DEBUG ImgBB] Status Code: ${res.statusCode}');
      print('>>> [DEBUG ImgBB] Response Body: $responseString');
      
      if (res.statusCode == 200) {
        var json = jsonDecode(responseString);
        if (json['data'] != null && json['data']['url'] != null) {
          String originalUrl = json['data']['url'];
          print('>>> [DEBUG ImgBB] Upload SUKSES! URL Asli: $originalUrl');
          String newUrl = originalUrl.replaceAll('.co/', '.co.com/');
          return newUrl;
        } else {
          print('>>> [DEBUG ImgBB] Response JSON tidak memiliki data URL yang valid.');
          return null;
        }
      } else {
        print('>>> [DEBUG ImgBB] Upload GAGAL! Status ${res.statusCode}. Kemungkinan Rate-Limit.');
        return null;
      }
    } catch (e) {
      print('>>> [DEBUG ImgBB] ERROR TERJADi: $e (Ini bisa jadi karena koneksi ditolak atau diblokir sementara)');
      return null;
    }
  }
}