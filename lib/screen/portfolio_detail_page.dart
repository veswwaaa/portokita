import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/portofolio_model.dart';
import '../models/comment_model.dart';
import '../services/portofolio_service.dart';
import '../services/firebase_service.dart';
import '../services/comment_service.dart';
import '../services/auth_service.dart';
import '../component/portofolio_card.dart';

class PortfolioDetailPage extends StatefulWidget {
  final Portofolio portfolio;
  final bool showOtherPortfolios;

  const PortfolioDetailPage({
    super.key,
    required this.portfolio,
    this.showOtherPortfolios = true,
  });

  @override
  State<PortfolioDetailPage> createState() => _PortfolioDetailPageState();
}

class _PortfolioDetailPageState extends State<PortfolioDetailPage> {
  final PortofolioService _portofolioService = PortofolioService();
  final FirebaseService _firebaseService = FirebaseService();
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();

  String _getMonthName(int month) {
    const months = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    return months[month - 1];
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      final currentUser = await AuthService().getCurrentUserData();
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Silakan login terlebih dahulu')),
          );
        }
        return;
      }

      _commentController.clear();
      FocusScope.of(context).unfocus();

      final result = await _commentService.addComment(
        portfolioId: widget.portfolio.id,
        userId: currentUser.id,
        username: currentUser.username,
        userAvatar: currentUser.avatarUrl,
        text: text,
      );

      if (result == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim komentar')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _firebaseService.currentUserId;
    final porto = widget.portfolio;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        margin: const EdgeInsets.only(top: 80), // Menambah jarak dari atas agar terlihat seperti pop up
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            // ── Modal Handle ──
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Scrollable Content ──
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Image Header with Overlays ──
                    Stack(
                      children: [
                        // Image
                        if (porto.imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                            child: Image.network(
                              porto.imageUrl,
                              width: double.infinity,
                              height: 350,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 350,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.broken_image,
                                      size: 50, color: Colors.grey[400]),
                                );
                              },
                            ),
                          ),

                        // Back Button
                        Positioned(
                          top: 16,
                          left: 16,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back,
                                  color: Colors.white, size: 24),
                            ),
                          ),
                        ),

                        //  Button
                        Positioned(
                          top: 16,
                          right: 16,
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: currentUserId != null
                                ? _firebaseService.usersCollection.doc(currentUserId).snapshots()
                                : null,
                            builder: (context, userSnapshot) {
                              bool isSaved = false;
                              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                                final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                                final savedIds = List<String>.from(userData?['savedPortfolios'] ?? []);
                                isSaved = savedIds.contains(porto.id);
                              }

                              return Theme(
                                data: Theme.of(context).copyWith(
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                ),
                                child: PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.more_vert,
                                        color: Colors.white, size: 24),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  color: const Color(0xFF1A1A1A).withOpacity(0.95),
                                  offset: const Offset(0, 50),
                                  onSelected: (value) async {
                                    if (value == 'bagikan') {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Tautan berhasil disalin!')),
                                      );
                                    } else if (value == 'simpan') {
                                      if (currentUserId != null) {
                                        if (isSaved) {
                                          await _portofolioService.unsavePortfolio(porto.id, currentUserId);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Dihapus dari simpanan')),
                                            );
                                          }
                                        } else {
                                          await _portofolioService.savePortfolio(porto.id, currentUserId);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Portofolio berhasil disimpan')),
                                            );
                                          }
                                        }
                                      }
                                    } else if (value == 'hapus') {
                                      // Tampilkan dialog konfirmasi hapus
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Hapus Portofolio'),
                                          content: const Text('Apakah Anda yakin ingin menghapus portofolio ini?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true && currentUserId != null) {
                                        final success = await _portofolioService.deletePortfolio(porto.id, currentUserId);
                                        if (success && mounted) {
                                          Navigator.pop(context); // Tutup detail page
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Portofolio berhasil dihapus')),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'bagikan',
                                      height: 45,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Bagikan',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuDivider(height: 1),
                                    PopupMenuItem(
                                      value: 'simpan',
                                      height: 45,
                                      child: Row(
                                        children: [
                                          Icon(
                                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                                            color: isSaved ? const Color(0xFFEE7F3C) : Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            isSaved ? 'Hapus dari Simpanan' : 'Simpan',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (currentUserId == porto.userId) ...[
                                      const PopupMenuDivider(height: 1),
                                      PopupMenuItem(
                                        value: 'hapus',
                                        height: 45,
                                        child: Row(
                                          children: [
                                            const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Hapus',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: Colors.red,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // Category Tag
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEE7F3C), Color(0xFFF49B33)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              porto.kategori,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Title ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        porto.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── User Info ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildUserInfo(porto),
                    ),

                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(),
                    ),

                    // ── Likes, Comments, Date ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: _buildStats(porto, currentUserId),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(),
                    ),

                    const SizedBox(height: 20),

                    // ── Deskripsi ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deskripsi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            porto.deskripsi,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: Colors.grey[800],
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ── Tags ──
                    if (porto.tags.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Tags',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: porto.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tag,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],

                    // ── Lihat Portofolio Lainnya (hanya untuk user lain) ──
                    if (widget.showOtherPortfolios && currentUserId != porto.userId)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => _UserPortfolioPage(
                                  userId: porto.userId,
                                  username: porto.username,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.open_in_new,
                                    size: 24, color: Colors.black),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    'Lihat Portofolio ${porto.username} Lainnya',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    // ── Komentar Section ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildCommentsSection(porto),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ── Bottom Comment Input ──
            _buildCommentInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(Portofolio porto) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firebaseService.usersCollection.doc(porto.userId).snapshots(),
      builder: (context, snapshot) {
        String kategori = '';
        String kelas = '';
        String? avatarUrl = porto.userAvatar;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          kategori = data?['kategori'] ?? '';
          kelas = data?['kelas'] ?? '';
          avatarUrl = data?['avatarUrl'] ?? porto.userAvatar;
        }

        final subtitle = [kategori, kelas].where((s) => s.isNotEmpty).join(' • ');

        return Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[200],
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  porto.username,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStats(Portofolio porto, String? currentUserId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firebaseService.PortofolioCollection.doc(porto.id).snapshots(),
      builder: (context, snapshot) {
        int likes = porto.likes;
        int comments = porto.comments;
        bool isLiked = currentUserId != null && porto.likedBy.contains(currentUserId);

        return StreamBuilder<DocumentSnapshot>(
          stream: currentUserId != null 
            ? _firebaseService.usersCollection.doc(currentUserId).snapshots()
            : null,
          builder: (context, userSnapshot) {
            bool isSaved = false;
            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
              final savedIds = List<String>.from(userData?['savedPortfolios'] ?? []);
              isSaved = savedIds.contains(porto.id);
            }

            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              likes = data?['likes'] ?? porto.likes;
              comments = data?['comments'] ?? porto.comments;
              final likedBy = List<String>.from(data?['likedBy'] ?? []);
              isLiked = currentUserId != null && likedBy.contains(currentUserId);
            }

            return Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (currentUserId != null) {
                      await _portofolioService.toggleLike(porto, currentUserId);
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 22,
                        color: isLiked ? Colors.red : Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        likes.toString(),
                        style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      comments.toString(),
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${porto.createdAt.day} ${_getMonthName(porto.createdAt.month)} ${porto.createdAt.year}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildCommentsSection(Portofolio porto) {
    return StreamBuilder<List<Comment>>(
      stream: _commentService.getComments(porto.id),
      builder: (context, snapshot) {
        final comments = snapshot.data ?? [];
        final commentCount = comments.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Komentar ($commentCount)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (comments.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Belum ada komentar.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              )
            else
              ...comments.map((comment) => _buildCommentItem(comment)),
          ],
        );
      },
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[200],
            backgroundImage: comment.userAvatar != null
                ? NetworkImage(comment.userAvatar!)
                : null,
            child: comment.userAvatar == null
                ? const Icon(Icons.person, size: 18, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTimeAgo(comment.createdAt),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    final currentUserId = _firebaseService.currentUserId;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: currentUserId != null
                ? _firebaseService.usersCollection.doc(currentUserId).snapshots()
                : null,
            builder: (context, snapshot) {
              String? avatarUrl;
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                avatarUrl = data?['avatarUrl'];
              }

              return CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[200],
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 18, color: Colors.grey)
                    : null,
              );
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _commentController,
              onSubmitted: (_) => _sendComment(),
              decoration: InputDecoration(
                hintText: 'Tambah Komen....',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendComment,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFEE7F3C),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Halaman portfolio user lain ──
class _UserPortfolioPage extends StatelessWidget {
  final String userId;
  final String username;

  const _UserPortfolioPage({required this.userId, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFEE7F3C),
        foregroundColor: Colors.white,
        title: Text(
          'Portofolio $username',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService()
            .PortofolioCollection
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFEE7F3C)),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada portofolio',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs.toList();
          docs.sort((a, b) {
            final aDate = (a.data() as Map<String, dynamic>)['createdAt'];
            final bDate = (b.data() as Map<String, dynamic>)['createdAt'];
            if (aDate == null || bDate == null) return 0;
            return bDate.compareTo(aDate);
          });

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return PortofolioCard(data: docs[index]);
            },
          );
        },
      ),
    );
  }
}
