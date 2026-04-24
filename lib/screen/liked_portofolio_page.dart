import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../models/portofolio_model.dart';
import '../services/portofolio_service.dart';
import '../services/firebase_service.dart';
import '../component/portofolio_card.dart';

class LikedPortofolioPage extends StatelessWidget {
  const LikedPortofolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PortofolioService _portofolioService = PortofolioService();
    final currentUserId = FirebaseService().currentUserId ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: Text(
          'Portofolio Disukai',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseService().usersCollection.doc(currentUserId).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text('User data not found'));
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final likedIds = List<String>.from(userData['likedPortfolios'] ?? []);

          if (likedIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada portofolio disukai',
                    style: GoogleFonts.plusJakartaSans(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder<List<Portofolio>>(
            future: _portofolioService.getLikedPortfolios(likedIds),
            builder: (context, portoSnapshot) {
              if (portoSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final portos = portoSnapshot.data ?? [];

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: portos.length,
                itemBuilder: (context, index) {
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseService().PortofolioCollection.doc(portos[index].id).snapshots(),
                    builder: (context, docSnapshot) {
                      if (!docSnapshot.hasData || !docSnapshot.data!.exists) {
                        return const SizedBox.shrink();
                      }
                      return PortofolioCard(
                        data: docSnapshot.data!,
                        showOtherPortfolios: true,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
