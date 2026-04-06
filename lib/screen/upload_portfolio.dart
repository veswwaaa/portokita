import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../services/portofolio_service.dart';
import '../services/image_upload_service.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../models/portofolio_model.dart';

class UploadPortfolio extends StatefulWidget {
  const UploadPortfolio({super.key});

  @override
  State<UploadPortfolio> createState() => _UploadPortfolioState();
}

class _UploadPortfolioState extends State<UploadPortfolio> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  String? _selectedKategori;
  List<String> _tags = [];

  final List<String> _kategoriList = ['RPL', 'TKJ', 'Animasi', 'TJAT', 'DKV'];

  // Tambahkan state untuk gambar - UBAH dari File? ke XFile?
  XFile? selectedImage;
  Uint8List? imageBytes;
  String? imageUrl;

  // Instance service
  final PortofolioService _portfolioService = PortofolioService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Header
          _buildHeader(),

          Positioned(
            top: 140,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),

              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGambarPortfolio(),
                      SizedBox(height: 25.0),
                      _buildJudulPortfolio(),
                      SizedBox(height: 20.0),
                      _buildDeskripsi(),
                      SizedBox(height: 20.0),
                      _buildKategori(),
                      SizedBox(height: 20.0),
                      _buildTags(),
                      SizedBox(height: 20.0),
                      _buildLinkProject(),
                      SizedBox(height: 30.0),
                      _buildUploadButton(),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF49B33), Color(0xFFEE7F3C)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/home'),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 28.0),
              ),
              SizedBox(width: 15.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload Portfolio',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Bagikan karya terbaikmu',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Area Upload Gambar - MODIFIKASI: Gunakan XFile dan static method
  Widget _buildGambarPortfolio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gambar Portfolio',
          style: GoogleFonts.plusJakartaSans(
            color: Color(0xFF000000),
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.0),
        GestureDetector(
          onTap: () async {
            // Panggil pickImage sebagai static method
            XFile? pickedImage = await ImageUploadService.pickImage();
            if (pickedImage != null) {
              // Load bytes untuk preview
              final bytes = await pickedImage.readAsBytes();
              setState(() {
                selectedImage = pickedImage;
                imageBytes = bytes;
              });
            }
          },
          child: Container(
            width: double.infinity,
            height: 150.0,
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: Color(0xFFE0E0E0),
                width: 2.0,
                style: BorderStyle.solid,
              ),
              // Jika ada gambar, tampilkan sebagai background
              image: imageBytes != null
                  ? DecorationImage(
                      image: MemoryImage(imageBytes!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: selectedImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 50.0,
                        color: Color(0xFF475B99).withOpacity(0.5),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Upload Gambar',
                        style: GoogleFonts.plusJakartaSans(
                          color: Color(0xFF000000),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'PNG, JPG maksimal 5MB',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      image: imageBytes != null
                          ? DecorationImage(
                              image: MemoryImage(imageBytes!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // Input Judul Portfolio
  Widget _buildJudulPortfolio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Judul Portfolio',
          style: GoogleFonts.plusJakartaSans(
            color: Color(0xFF000000),
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.0),
        TextField(
          controller: _judulController,
          decoration: InputDecoration(
            hintText: 'Contoh: Website E-Commerce Modern',
            hintStyle: GoogleFonts.plusJakartaSans(
              color: Colors.grey,
              fontSize: 14.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Color(0xFF000000), width: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  // Input Deskripsi
  Widget _buildDeskripsi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi',
          style: GoogleFonts.plusJakartaSans(
            color: Color(0xFF000000),
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.0),
        TextField(
          controller: _deskripsiController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Jelaskan proyek ini secara singkat...',
            hintStyle: GoogleFonts.plusJakartaSans(
              color: Colors.grey,
              fontSize: 14.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Color(0xFF000000), width: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  // Dropdown Kategori
  Widget _buildKategori() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: GoogleFonts.plusJakartaSans(
            color: Color(0xFF000000),
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.0),
        DropdownButtonFormField<String>(
          value: _selectedKategori,
          items: _kategoriList.map((String kategori) {
            return DropdownMenuItem<String>(
              value: kategori,
              child: Text(kategori),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedKategori = newValue;
            });
          },
          decoration: InputDecoration(
            hintText: 'Pilih kategori',
            hintStyle: GoogleFonts.plusJakartaSans(
              color: Colors.grey,
              fontSize: 14.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Color(0xFF000000), width: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  // Input Tags
  Widget _buildTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: GoogleFonts.plusJakartaSans(
            color: Color(0xFF000000),
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.0),
        TextField(
          controller: _tagController,
          decoration: InputDecoration(
            hintText: 'Tambahkan tag (pisahkan dengan koma)',
            hintStyle: GoogleFonts.plusJakartaSans(
              color: Colors.grey,
              fontSize: 14.0,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.add, color: Color(0xFF000000)),
              onPressed: () {
                if (_tagController.text.isNotEmpty) {
                  setState(() {
                    _tags.add(_tagController.text.trim());
                    _tagController.clear();
                  });
                }
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Color(0xFF000000), width: 2.0),
            ),
          ),
        ),
        SizedBox(height: 10.0),
        Wrap(
          spacing: 8.0,
          children: _tags.map((tag) {
            return Chip(
              label: Text(tag),
              deleteIcon: Icon(Icons.close),
              onDeleted: () {
                setState(() {
                  _tags.remove(tag);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Input Link Project
  Widget _buildLinkProject() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Link Project (Opsional)',
          style: GoogleFonts.plusJakartaSans(
            color: Color(0xFF000000),
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.0),
        TextField(
          controller: _linkController,
          decoration: InputDecoration(
            hintText: 'https://example.com',
            hintStyle: GoogleFonts.plusJakartaSans(
              color: Colors.grey,
              fontSize: 14.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Color(0xFF000000), width: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      height: 55.0,
      child: ElevatedButton(
        onPressed: () async {
          // Validasi input
          if (_judulController.text.isEmpty ||
              _deskripsiController.text.isEmpty ||
              _selectedKategori == null ||
              selectedImage == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Harap lengkapi semua field dan pilih gambar'),
              ),
            );
            return;
          }

          // Simpan BuildContext sebelum async
          final scaffoldContext = context;
          bool isDialogShowing = false;

          try {
            // Tampilkan loading dialog
            showDialog(
              context: scaffoldContext,
              barrierDismissible: false,
              builder: (dialogContext) {
                isDialogShowing = true;
                return WillPopScope(
                  onWillPop: () async => false,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            );

            // Upload gambar ke ImgBB
            print('Mulai upload gambar ke ImgBB...');
            String? uploadedUrl = await ImageUploadService.uploadImageToImgBB(
              selectedImage!,
            );

            if (uploadedUrl == null) {
              if (isDialogShowing && mounted) {
                Navigator.of(scaffoldContext, rootNavigator: true).pop();
                isDialogShowing = false;
              }
              if (mounted) {
                ScaffoldMessenger.of(
                  scaffoldContext,
                ).showSnackBar(SnackBar(content: Text('Gagal upload gambar')));
              }
              return;
            }
            print(' Gambar berhasil diupload: $uploadedUrl');

            // Ambil user yang sedang login
            final authService = AuthService();
            final currentUser = await authService.getCurrentUserData();

            if (currentUser == null) {
              if (isDialogShowing && mounted) {
                Navigator.of(scaffoldContext, rootNavigator: true).pop();
                isDialogShowing = false;
              }
              if (mounted) {
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  SnackBar(
                    content: Text('Sesi telah habis, silakan login kembali.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }

            // Upload portfolio ke Firebase
            await _portfolioService.uploadPortfolio(
              imageUrl: uploadedUrl,
              title: _judulController.text,
              deskripsi: _deskripsiController.text,
              kategori: _selectedKategori!,
              tags: _tags,
              linkProject: _linkController.text.isNotEmpty
                  ? _linkController.text
                  : null,
              currentUser: currentUser,
            );

            print(' Portfolio berhasil tersimpan!');

            if (isDialogShowing && mounted) {
              Navigator.of(scaffoldContext, rootNavigator: true).pop();
              isDialogShowing = false;
            }

            if (mounted) {
              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                SnackBar(
                  content: Text(' Portfolio berhasil diupload!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );

              await Future.delayed(Duration(milliseconds: 800));

              if (mounted) {
                scaffoldContext.go('/home');
              }
            }
          } catch (e) {
            print('❌ ERROR: $e');

            if (isDialogShowing && mounted) {
              Navigator.of(scaffoldContext, rootNavigator: true).pop();
              isDialogShowing = false;
            }

            if (mounted) {
              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF475B99),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload, color: Colors.white),
            SizedBox(width: 10.0),
            Text(
              'Upload Portfolio',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _tagController.dispose();
    _linkController.dispose();
    super.dispose();
  }
}
