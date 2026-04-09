import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/portofolio_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../services/portofolio_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final PortofolioService _portofolioService = PortofolioService();

  Widget _menuItem(IconData icon, String label, String count, bool isDanger) {
    return ListTile(
      leading: Icon(icon, color: isDanger ? Colors.red : Colors.black87),
      title: Text(
        label,
        style: TextStyle(
          color: isDanger ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count.isNotEmpty)
            Text(count, style: TextStyle(color: Colors.grey)),
          SizedBox(width: 4),
          Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              // Capture router SEBELUM async, supaya context tetap valid
              final router = GoRouter.of(context);
              Navigator.of(dialogContext).pop(); // tutup popup
              await AuthService().logout();       // jalankan logout
              router.go('/login');                // redirect ke login
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseService().currentUserId ?? '';

    return Scaffold(
      backgroundColor: Color(0xFFEE7F3C),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Judul "Profile" ──
            Positioned(
              top: 16,
              left: 40,
              child: Text(
                "Profile",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),

            // ── Background putih bawah ──
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 500.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
              ),
            ),

            // ── Card profil (gradient) ──
            Align(
              alignment: Alignment(0.0, -0.7),
              child: Stack(
                children: [
                  Container(
                    width: 330,
                    height: 270,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0x66F49B33), Color(0x66FFFFFF)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),

                  Positioned(
                    left: 0,
                    top: 5,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.black,
                              ),
                            ),
                            Positioned(
                              left: 40,
                              bottom: 0,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.edit,
                                  size: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        //username masih hardcode juga
                        Text(
                          "Agung",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        //bagian jurusan masih hardcodee
                        Text(
                          "Rekayasa  Perangkat Lunak",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: Colors.black,
                          ),
                        ),
                        //bagian email profile masih hardcodee
                        Text(
                          "vanoaji402@gmail.com",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: Colors.black,
                          ),
                        ),
                        Divider(),

                        //bagian jumlah porto,like sama views masih hardcode
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                children: [Text("12"), Text("Portofolio")],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [Text("190"), Text("likes")],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [Text("2k"), Text("views")],
                              ),
                            ),
                          ],
                        ),
                        Divider(),

                        Padding(
                          padding: const EdgeInsets.only(
                            left: 12.0,
                            right: 12.0,
                            top: 10,
                          ),
                          child: Text(
                            '"Passionate developer yang suka membuat aplikas web dan mobile. Always learning, always coding! 🚀"',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Section bawah: Portofolio saya (FIX) + Menu (scrollable) ──
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 350, // sesuaikan agar mulai di bawah card profil
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── FIXED: Header "Portofolio saya" ──
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.grid_view_rounded, size: 22),
                            SizedBox(width: 8),
                            Text(
                              "Portofolio saya",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Lihat semua",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── FIXED: Grid 3 foto terbaru (dinamis) ──
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: StreamBuilder<List<Portofolio>>(
                      stream: _portofolioService.getPortofoliosByUserId(
                        currentUserId,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Container(
                            height: 110,
                            alignment: Alignment.center,
                            child: Text(
                              "Belum ada portofolio",
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        final portfolios = snapshot.data!.take(3).toList();

                        return Row(
                          children: portfolios.map((porto) {
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    porto.imageUrl,
                                    height: 110,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 110,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  // ── SCROLLABLE: Menu list ──
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        // MediaQuery.of(context).padding.bottom = tinggi safe area bawah (notch/gesture bar)
                        // kBottomNavigationBarHeight = tinggi navbar (56dp standar Flutter)
                        bottom: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 16,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _menuItem(
                              Icons.bookmark_border,
                              "Tersimpan",
                              "24",
                              false,
                            ),
                            Divider(height: 1),
                            _menuItem(
                              Icons.favorite_border,
                              "Disukai",
                              "156",
                              false,
                            ),
                            Divider(height: 1),
                            _menuItem(Icons.settings, "Pengaturan", "", false),
                            Divider(height: 1),
                            GestureDetector(
                              onTap: _showLogoutDialog,
                              child: _menuItem(Icons.logout, "Keluar", "", true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
