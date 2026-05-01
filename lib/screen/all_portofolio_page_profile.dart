import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../component/portofolio_card.dart';

class AllPortofolioPage extends StatelessWidget {
  const AllPortofolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseService().currentUserId ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFEE7F3C),
        foregroundColor: Colors.white,
        title: const Text(
          'Portofolio Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService()
            .PortofolioCollection
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFEE7F3C)),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada portofolio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload portofolio pertamamu!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort docs by createdAt descending (terbaru di atas)
          final docs = snapshot.data!.docs.toList();
          docs.sort((a, b) {
            final aDate = (a.data() as Map<String, dynamic>)['createdAt'];
            final bDate = (b.data() as Map<String, dynamic>)['createdAt'];
            if (aDate == null || bDate == null) return 0;
            return bDate.compareTo(aDate);
          });

          // Data state — show portfolios
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return PortofolioCard(data: docs[index], showOtherPortfolios: false);
            },
          );
        },
      ),
    );
  }
}
