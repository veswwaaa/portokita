import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../models/portofolio_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../services/portofolio_service.dart';
import 'all_portofolio_page_profile.dart';
import 'portfolio_detail_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final PortofolioService _portofolioService = PortofolioService();

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

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

               // tutup popup
              Navigator.of(dialogContext).pop();

              // jalankan logout
              await AuthService().logout(); 
              router.go(
                // pindah ke splash
                '/splash?skip=true',
              ); 
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                height: 400,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEE7F3C), Color(0xFFF49B33)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              Positioned(
                top: 280, 
                left: 0,
                right: 0,
                bottom: -2000,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  // Judul "Profile" 
                  Padding(
                    padding: const EdgeInsets.only(top: 16, left: 40),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Profile",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  //Card profil
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        width: 330,
                        height: 320,
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
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseService()
                              .usersCollection
                              .doc(currentUserId)
                              .snapshots(),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final userData =
                                userSnapshot.data!.data()
                                    as Map<String, dynamic>?;
                            final userModel = UserModel.fromFirestore(
                              userData ?? {},
                              userSnapshot.data!.id,
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundImage: userModel.avatarUrl !=
                                              null
                                          ? NetworkImage(userModel.avatarUrl!)
                                          : const AssetImage(
                                                'assets/images/foto.jpeg',
                                              )
                                              as ImageProvider,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        height: 28,
                                        width: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            context.push(
                                              '/edit-profile',
                                              extra: userModel,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 14.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Data User
                                Text(
                                  userModel.username,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  userModel.kategori ?? '-',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  userModel.email,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black,
                                  ),
                                ),
                                const Divider(),

                                // ── STATISTIK DINAMIS ──
                                StreamBuilder<List<Portofolio>>(
                                  stream: _portofolioService
                                      .getPortofoliosByUserId(
                                        currentUserId,
                                      ),
                                  builder: (context, portoSnapshot) {
                                    if (portoSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _statItem("...", "Portofolio"),
                                          _statItem("...", "Likes"),
                                          _statItem("...", "Views"),
                                        ],
                                      );
                                    }

                                    int totalPortos = 0;
                                    int totalLikes = 0;
                                    int totalViews = 0;

                                    if (portoSnapshot.hasData) {
                                      final portos = portoSnapshot.data!;
                                      totalPortos = portos.length;
                                      for (var p in portos) {
                                        totalLikes += p.likes;
                                        totalViews += p.views;
                                      }
                                    }

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _statItem(
                                          totalPortos.toString(),
                                          "Portofolio",
                                        ),
                                        _statItem(
                                          totalLikes.toString(),
                                          "Likes",
                                        ),
                                        _statItem(
                                          totalViews.toString(),
                                          "Views",
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const Divider(),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  child: Text(
                                    '"${userModel.bio ?? "No Bio"}"',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Bagian Portofolio & Menu ──
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => const AllPortofolioPage(),
                                    transitionDuration: const Duration(
                                      milliseconds: 400,
                                    ),
                                    reverseTransitionDuration: const Duration(
                                      milliseconds: 300,
                                    ),
                                    transitionsBuilder: (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      final curvedAnimation = CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      );
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 1),
                                          end: Offset.zero,
                                        ).animate(curvedAnimation),
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Text(
                                "Lihat semua",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Grid 3 foto terbaru
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
                                    child: GestureDetector(
                                      onTap: () {
                                        _portofolioService.incrementViews(porto.id);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PortfolioDetailPage(
                                              portfolio: porto,
                                              showOtherPortfolios: false,
                                            ),
                                          ),
                                        );
                                      },
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
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Menu list (Menyatu dengan scroll utama)
                      Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom:
                              MediaQuery.of(context).padding.bottom +
                              kBottomNavigationBarHeight +
                              16,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => context.push('/saved-portfolios'),
                                child: _menuItem(
                                  Icons.bookmark_border,
                                  "Tersimpan",
                                  "",
                                  false,
                                ),
                              ),
                              Divider(height: 1),
                              GestureDetector(
                                onTap: () => context.push('/liked-portfolios'),
                                child: _menuItem(
                                  Icons.favorite_border,
                                  "Disukai",
                                  "",
                                  false,
                                ),
                              ),
                              Divider(height: 1),
                              _menuItem(Icons.settings, "Pengaturan", "", false),
                              Divider(height: 1),
                              GestureDetector(
                                onTap: _showLogoutDialog,
                                child: _menuItem(
                                  Icons.logout,
                                  "Keluar",
                                  "",
                                  true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
