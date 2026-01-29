import 'dart:io';
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


  //untuk upload gambar ke imgBB dan dapat urlnya

  static Future<String?> uploadImageToImgBB(XFile imageFile) async {
    try{

  var compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        quality: 70,
      );
      final imgbb = Imgbb(_apiKey);

      final response = await imgbb.uploadImageFile(
        imageFile: File(imageFile.path),
        expiration: 999999,
      );

      if (response != null && response.url != null) {
        String newUrl = response.url.replaceAll('.co/', '.co.com/');
        return newUrl;
      } else {
        print('Upload gagal: response null');
        return null;
      }
    } catch (e) {
      print('eror upload ke imageBB: $e');
      return null;
    }
  }
}