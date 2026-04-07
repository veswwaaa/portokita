import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/portofolio_service.dart';
import '../services/firebase_service.dart';
import '../models/portofolio_model.dart';

class PortofolioCard extends StatefulWidget {
  final QueryDocumentSnapshot data;

  const PortofolioCard({super.key, required this.data});

  @override
  State<PortofolioCard> createState() => _CardPortofolioState();
}

class _CardPortofolioState extends State<PortofolioCard> {
  final PortofolioService _portofolioService = PortofolioService();
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> docData = widget.data.data() as Map<String, dynamic>;
    Portofolio porto = Portofolio.fromFirestore(docData, widget.data.id);
    String? currentUserId = _firebaseService.currentUserId;
    bool isLiked =
        currentUserId != null && porto.likedBy.contains(currentUserId);

    return GestureDetector(
      onTap: () {
        // Increment view count when opening detail
        _portofolioService.incrementViews(porto.id);

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return _buildDetailPopUp(context, porto);
          },
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              margin: EdgeInsets.only(bottom: 30.0),
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),

                ///
                borderRadius: BorderRadius.circular(20.0),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),

              width: 450,
              height: 380,
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.network(
                          porto.imageUrl.isNotEmpty
                              ? porto.imageUrl
                              : 'https://placehold.co/600x400.png',
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 250,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 15,
                        left: 20,
                        child: Container(
                          alignment: Alignment.center,
                          width: 80,
                          height: 35,
                          decoration: BoxDecoration(
                            gradient:LinearGradient( colors: [
                              Color(0xFFEE7F3C),
                              Color(0xFFF49B33)
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(50.0)),
                          ),
                          child: Text(
                            porto.kategori, // Misalnya menampilkan kategori
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                      child: Text(
                        porto.title,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 20,
                          top: 14,
                          child: Row(
                            children: [
                              Container(
                                width: 30.0,
                                height: 30.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFFFFFF),
                                ),
                                child: Icon(Icons.person_2),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(porto.username),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (currentUserId != null) {
                              await _portofolioService.toggleLike(
                                porto,
                                currentUserId,
                              );
                            }
                          },
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: isLiked ? Colors.red : Colors.black,
                          ),      
                        ),
                        SizedBox(width: 5),
                        Text(porto.likes.toString()),
                        SizedBox(width: 5),
                        Icon(Icons.chat_bubble_outline, size: 20),
                        SizedBox(width: 5),
                        Text(porto.comments.toString()),
                        SizedBox(width: 5),
                        Icon(Icons.remove_red_eye_outlined, size: 20),
                        SizedBox(width: 5),
                        Text(porto.views.toString()),
                      ],
                    ),
                  ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPopUp(BuildContext context, Portofolio porto) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),

      child: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: porto.imageUrl.isNotEmpty
                ? Image.network(
                    porto.imageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  )
                : Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  porto.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 15),
                    Text(porto.username),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(),

                // Comments Section Placeholder
                const SizedBox(height: 10),
                const Text(
                  'Komentar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Center(child: Text('Belum ada komentar.')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
